
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../models/bin.dart';
import '../../services/bin_store.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  Bin? _selectedBin;

  bool _hasCenteredOnLocation = false;
  bool _isNavigating = false;
  bool _isLoadingRoute = false;

  LatLng? _userLocation;

  List<LatLng> _routePoints = [];

  double? _routeDistance;
  double? _routeDuration;

  StreamSubscription<Position>? _positionSubscription;

  static const LatLng _fallbackCenter =
      LatLng(20.5937, 78.9629);

@override
@override
void initState() {
  super.initState();

  BinStore.instance.addListener(_onBinsUpdated);

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Bin) {
      // Select the bin received from Bin Details.
      _selectBin(arguments);

      // Automatically calculate and display its route.
      await _navigateToBin(arguments);
    }
  });
}

  @override
  void dispose() {
    BinStore.instance.removeListener(_onBinsUpdated);
    _positionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // BIN LOCATION
  // --------------------------------------------------

  LatLng? _getLocation(Bin bin) {
    if (!bin.hasLocation) return null;

    return LatLng(
      bin.latitude,
      bin.longitude,
    );
  }

  LatLng? _firstValidLocation(List<Bin> bins) {
    for (final bin in bins) {
      final location = _getLocation(bin);
      if (location != null) return location;
    }

    return null;
  }

  void _onBinsUpdated() {
    if (!mounted) return;

    final bins = BinStore.instance.bins;
    LatLng? newLocation;

    if (_selectedBin != null) {
      final updatedBins = bins.where(
        (bin) => bin.id == _selectedBin!.id,
      );

      if (updatedBins.isNotEmpty) {
        _selectedBin = updatedBins.first;
      } else {
        _selectedBin = null;
      }
    }

    if (!_hasCenteredOnLocation) {
      newLocation = _firstValidLocation(bins);
    }

    setState(() {});

    if (newLocation != null) {
      _hasCenteredOnLocation = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        try {
          _mapController.move(newLocation!, 15);
        } catch (_) {}
      });
    }
  }

  // --------------------------------------------------
  // BIN STATUS
  // --------------------------------------------------

  Color _getStatusColor(num fill) {
    if (fill >= 81) return Colors.red;

    if (fill >= 51) {
      return const Color.fromARGB(255, 215, 164, 89);
    }

    return const Color(0xFF2E7D32);
  }

  String _getStatusText(Bin bin) {
    if (!bin.hasSensorData) {
      return 'Awaiting Sensor Data';
    }

    if (bin.fillLevel >= 81) {
      return 'High Fill Level';
    }

    if (bin.fillLevel >= 51) {
      return 'Moderate Fill Level';
    }

    return 'Normal Fill Level';
  }

  // --------------------------------------------------
  // SELECT BIN
  // --------------------------------------------------

  void _selectBin(Bin bin) {
    setState(() {
      _selectedBin = bin;
    });

    final location = _getLocation(bin);

    if (location != null) {
      _mapController.move(location, 16);
    }
  }

  void _openDetails(Bin bin) {
    Navigator.pushNamed(
      context,
      '/bin-details',
      arguments: bin,
    );
  }

  void _reportIssue(Bin bin) {
    Navigator.pushNamed(
      context,
      '/report-issue',
      arguments: {
        'binId': bin.id,
        'location': bin.location,
      },
    );
  }

  // --------------------------------------------------
  // LOCATION PERMISSION
  // --------------------------------------------------

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Please enable your device location services.',
      );
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission was denied.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it in browser or device settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  // --------------------------------------------------
  // CALCULATE IN-APP ROUTE
  // --------------------------------------------------

  Future<void> _navigateToBin(Bin bin) async {
    final destination = _getLocation(bin);

    if (destination == null) {
      _showMessage(
        'Valid GPS coordinates are unavailable for this bin.',
      );
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _selectedBin = bin;
    });

    try {
      // Get current user position.
      final position = await _getCurrentPosition();

      final origin = LatLng(
        position.latitude,
        position.longitude,
      );

      // OSRM expects longitude,latitude.
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'The routing service is currently unavailable.',
        );
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok' ||
          (data['routes'] as List).isEmpty) {
        throw Exception(
          'No driving route was found to this bin.',
        );
      }

      final route = data['routes'][0];

      final coordinates =
          route['geometry']['coordinates'] as List;

      final points = coordinates.map<LatLng>((coordinate) {
        return LatLng(
          (coordinate[1] as num).toDouble(),
          (coordinate[0] as num).toDouble(),
        );
      }).toList();

      if (!mounted) return;

      await _positionSubscription?.cancel();

      setState(() {
        _userLocation = origin;
        _routePoints = points;

        _routeDistance =
            (route['distance'] as num).toDouble();

        _routeDuration =
            (route['duration'] as num).toDouble();

        _isNavigating = true;
      });

      // Display the complete route.
      if (points.length >= 2) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.all(55),
          ),
        );
      }

      // Start live GPS updates.
      _startLocationTracking();

    } catch (e) {
      if (mounted) {
        _showMessage(
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // LIVE GPS TRACKING
  // --------------------------------------------------

  void _startLocationTracking() {
    _positionSubscription?.cancel();

    _positionSubscription =
        Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (position) {
        if (!mounted) return;

        setState(() {
          _userLocation = LatLng(
            position.latitude,
            position.longitude,
          );
        });
      },
      onError: (error) {
        if (mounted) {
          _showMessage(
            'GPS tracking error: $error',
          );
        }
      },
    );
  }

  // --------------------------------------------------
  // STOP NAVIGATION
  // --------------------------------------------------

  Future<void> _stopNavigation() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    if (!mounted) return;

    setState(() {
      _isNavigating = false;

      _userLocation = null;
      _routePoints = [];

      _routeDistance = null;
      _routeDuration = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // --------------------------------------------------
  // CENTER MAP
  // --------------------------------------------------

  void _centerMap() {
    if (_isNavigating && _userLocation != null) {
      _mapController.move(_userLocation!, 17);
      return;
    }

    final location = _firstValidLocation(
      BinStore.instance.bins,
    );

    if (location != null) {
      _mapController.move(location, 15);
    } else {
      _showMessage(
        'No verified bin locations are available.',
      );
    }
  }

  // --------------------------------------------------
  // BUILD SCREEN
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bins = BinStore.instance.bins;

    final mappedBins = bins
        .where((bin) => bin.hasLocation)
        .toList();

    final criticalBins =
        bins.where((bin) => bin.fillLevel >= 81).length;

    final firstLocation = _firstValidLocation(bins);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Smart Bin Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _centerMap,
            icon: const Icon(Icons.my_location),
            tooltip: 'Center map',
          ),
        ],
      ),

      body: bins.isEmpty
          ? _buildLoadingState()
          : Column(
              children: [
                // SUMMARY CARDS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,

                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.delete_outline,
                          title: 'Smart Bins',
                          value: '${bins.length}',
                          color: const Color(0xFF2E7D32),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _summaryCard(
                          icon: Icons.location_on_outlined,
                          title: 'Located Bins',
                          value: '${mappedBins.length}',
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _summaryCard(
                          icon: Icons.warning_amber_outlined,
                          title: 'High Fill',
                          value: '$criticalBins',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                // MAP
               SizedBox(
  height: _selectedBin != null || _isNavigating
      ? 240
      : 310,

                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,

                        options: MapOptions(
                          initialCenter:
                              firstLocation ?? _fallbackCenter,

                          initialZoom:
                              firstLocation == null ? 4 : 15,

                          interactionOptions:
                              const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),

                        children: [
                          // MAP TILES
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                            userAgentPackageName:
                                'com.garbageguardian.app',
                          ),

                          // ROUTE POLYLINE
                          if (_routePoints.length >= 2)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _routePoints,
                                  strokeWidth: 6,
                                  color: Colors.blue,
                                  borderStrokeWidth: 2,
                                  borderColor: Colors.white,
                                ),
                              ],
                            ),

                          // BIN MARKERS
                          MarkerLayer(
                            markers: mappedBins.map((bin) {
                              final location =
                                  _getLocation(bin)!;

                              return Marker(
                                point: location,
                                width: 58,
                                height: 70,

                                child: GestureDetector(
                                  onTap: () => _selectBin(bin),
                                  child: _buildMarker(bin),
                                ),
                              );
                            }).toList(),
                          ),

                          // USER LOCATION MARKER
                          if (_userLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _userLocation!,
                                  width: 46,
                                  height: 46,

                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),

                                    child: const Icon(
                                      Icons.navigation,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          // OPENSTREETMAP ATTRIBUTION
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                                onTap: () => launchUrl(
                                  Uri.parse(
                                    'https://www.openstreetmap.org/copyright',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // MAP STATUS
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,

                        child: Container(
                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.95),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),

                          child: Text(
                            _isNavigating
                                ? 'Navigation active • ${_selectedBin?.id ?? ''}'
                                : mappedBins.isEmpty
                                    ? 'Real bin locations are unavailable.'
                                    : 'Showing ${mappedBins.length} bins with GPS coordinates.',

                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // ROUTE LOADING
                      if (_isLoadingRoute)
                        Container(
                          color: Colors.black26,

                          child: const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 12),
                                    Text(
                                      'Calculating route...',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // NAVIGATION INFORMATION
                if (_isNavigating)
                  _buildNavigationPanel(),
                // SENSOR INFORMATION
                if (!_isNavigating && _selectedBin == null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(
                      16, 12, 16, 8,
                    ),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.sensors_outlined,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            mappedBins.isEmpty
                                ? 'Live bin readings are available, but GPS coordinates are needed to show locations.'
                                : 'Bin fill levels update from the monitoring system. Select a bin to view details or navigate.',
                            style: const TextStyle(
                              color: Color(0xFF285D2B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // BIN LIST - HIDE WHEN A BIN IS SELECTED
                if (!_isNavigating && _selectedBin == null)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16, 6, 16, 24,
                      ),
                      itemCount: bins.length,
                      itemBuilder: (context, index) {
                        return _buildBinCard(bins[index]);
                      },
                    ),
                  ),

                // SELECTED BIN DETAILS
                if (!_isNavigating && _selectedBin != null)
                  _buildSelectedBinCard(_selectedBin!),

            ]),
    );
  }

  // --------------------------------------------------
  // NAVIGATION PANEL
  // --------------------------------------------------

  Widget _buildNavigationPanel() {
    final distance = _routeDistance ?? 0;
    final duration = _routeDuration ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.navigation,
                color: Colors.blue,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Navigation Active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              IconButton(
                onPressed: _stopNavigation,
                icon: const Icon(Icons.close),
                tooltip: 'Stop navigation',
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _selectedInfo(
                  'Distance',
                  '${(distance / 1000).toStringAsFixed(2)} km',
                  Colors.blue,
                ),
              ),

              Expanded(
                child: _selectedInfo(
                  'Estimated time',
                  '${(duration / 60).ceil()} min',
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Destination: ${_selectedBin?.location ?? ''}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,

            child: OutlinedButton.icon(
              onPressed: _centerMap,
              icon: const Icon(Icons.my_location),
              label: const Text('Center on my location'),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // BIN MARKER
  // --------------------------------------------------

  Widget _buildMarker(Bin bin) {
    final fill = bin.fillLevel.round().clamp(0, 100);
    final color = _getStatusColor(fill);

    return Column(
      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,

            border: Border.all(
              color: Colors.white,
              width: 3,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),

          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 23,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 2,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),

          child: Text(
            '$fill%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // LOADING STATE
  // --------------------------------------------------

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.location_searching,
              size: 60,
              color: Color(0xFF2E7D32),
            ),

            SizedBox(height: 18),

            CircularProgressIndicator(
              color: Color(0xFF2E7D32),
            ),

            SizedBox(height: 16),

            Text(
              'Waiting for smart bin data...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'Live bins will appear when data is received.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SUMMARY CARD
  // --------------------------------------------------

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color, size: 24),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // BIN CARD
  // --------------------------------------------------

  Widget _buildBinCard(Bin bin) {
    final fill = bin.fillLevel.round().clamp(0, 100);
    final statusColor = _getStatusColor(fill);

    final isSelected = _selectedBin?.id == bin.id;

    return InkWell(
      onTap: () => _selectBin(bin),
      borderRadius: BorderRadius.circular(18),

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          border: isSelected
              ? Border.all(
                  color: const Color(0xFF2E7D32),
                  width: 2,
                )
              : null,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,

                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.delete_outline,
                    color: statusColor,
                    size: 29,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        bin.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _getStatusText(bin),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  bin.hasSensorData ? '$fill%' : '--',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: LinearProgressIndicator(
                value: bin.hasSensorData ? fill / 100 : 0,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Text(
                    bin.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  bin.hasLocation
                      ? Icons.location_on
                      : Icons.location_off_outlined,
                  size: 16,
                  color: bin.hasLocation
                      ? const Color(0xFF2E7D32)
                      : Colors.grey,
                ),

                const SizedBox(width: 4),

                Text(
                  bin.hasLocation ? 'Located' : 'No GPS',
                  style: TextStyle(
                    color: bin.hasLocation
                        ? const Color(0xFF2E7D32)
                        : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SELECTED BIN PANEL
  // --------------------------------------------------

  Widget _buildSelectedBinCard(Bin bin) {
    final fill = bin.fillLevel.round().clamp(0, 100);
    final statusColor = _getStatusColor(fill);

    return SafeArea(
      top: false,

      child: Container(
        width: double.infinity,

        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.42,
        ),

        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),

        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],

          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Selected Smart Bin',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          bin.id,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    visualDensity: VisualDensity.compact,

                    onPressed: () {
                      setState(() {
                        _selectedBin = null;
                      });
                    },

                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _selectedInfo(
                      'Fill Level',
                      bin.hasSensorData ? '$fill%' : '--',
                      statusColor,
                    ),
                  ),

                  Expanded(
                    child: _selectedInfo(
                      'Status',
                      _getStatusText(bin),
                      statusColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openDetails(bin),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Details'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed: () => _reportIssue(bin),
                    icon: const Icon(Icons.report_problem_outlined),
                    label: const Text('Report'),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),

                  FilledButton.icon(
                    onPressed: bin.hasLocation && !_isLoadingRoute
                        ? () => _navigateToBin(bin)
                        : null,

                    icon: const Icon(Icons.navigation_outlined),

                    label: Text(
                      _isLoadingRoute
                          ? 'Calculating...'
                          : 'Navigate',
                    ),

                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              if (!bin.hasLocation) ...[
                const SizedBox(height: 8),

                const Text(
                  'Navigation requires verified GPS coordinates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SELECTED INFORMATION
  // --------------------------------------------------

  Widget _selectedInfo(
    String title,
    String value,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
