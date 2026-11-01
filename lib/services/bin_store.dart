
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/bin.dart';
import 'api_service.dart';

class BinStore extends ChangeNotifier {
  BinStore._();

  static final BinStore instance = BinStore._();

  final Map<String, Bin> _bins = {};
  final Map<String, Map<String, dynamic>> _locations = {};

  Timer? _locationRefreshTimer;
  bool _isLoadingLocations = false;
  bool _hasLoadedLocations = false;

  List<Bin> get bins => List.unmodifiable(_bins.values);

  bool get hasLoadedLocations => _hasLoadedLocations;

  // Call this when live sensor data arrives from Socket.IO.
  void updateFromSensorData(Map<String, dynamic> json) {
    final deviceId =
        (json['deviceId'] ?? json['id'] ?? '').toString().trim();

    if (deviceId.isEmpty) return;

    final previous = _bins[deviceId];

    // Preserve the last known GPS location when the live
    // sensor payload doesn't contain coordinates.
    final locationData = _locations[deviceId];

    final merged = <String, dynamic>{
      if (previous != null) ...{
        'deviceId': previous.id,
        'location': previous.location,
        'fillPercentage': previous.fillLevel,
        'status': previous.status,
        'latitude': previous.latitude,
        'longitude': previous.longitude,
        'lastUpdated': previous.lastUpdated.millisecondsSinceEpoch == 0
            ? null
            : previous.lastUpdated.toIso8601String(),
        'uptime': previous.uptime,
        'online': previous.online,
        'distance': previous.distance,
      },
      ...?locationData,
      ...json,
      'deviceId': deviceId,
    };

    // Sensor data should not erase coordinates when its
    // payload has no latitude or longitude.
    if (json['latitude'] == null && previous != null) {
      merged['latitude'] = locationData?['latitude'] ??
          previous.latitude;
    }

    if (json['longitude'] == null && previous != null) {
      merged['longitude'] = locationData?['longitude'] ??
          previous.longitude;
    }

    if (json['location'] == null &&
        (locationData?['location'] != null ||
            previous != null)) {
      merged['location'] =
          locationData?['location'] ?? previous!.location;
    }

    _bins[deviceId] = Bin.fromJson(merged);
    notifyListeners();
  }

  // Fetch the saved GPS coordinates from the backend.
  Future<void> loadBinLocations() async {
    if (_isLoadingLocations) return;

    _isLoadingLocations = true;

    try {
      final response =
          await ApiService.instance.getBinLocations();

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Could not load bin locations',
        );
      }

      final rawBins = response['bins'];

      if (rawBins is! List) {
        throw const FormatException(
          'The bin-locations response has no bins list.',
        );
      }

      for (final item in rawBins) {
        if (item is! Map) continue;

        final location = Map<String, dynamic>.from(item);
        final id =
            (location['deviceId'] ?? location['id'] ?? '')
                .toString()
                .trim();

        if (id.isEmpty) continue;

        _locations[id] = {
          ...?_locations[id],
          ...location,
          'deviceId': id,
        };

        final previous = _bins[id];

        if (previous != null) {
          // Keep live sensor readings; add GPS and location.
          final merged = <String, dynamic>{
            'deviceId': previous.id,
            'fillPercentage': previous.fillLevel,
            'status': previous.status,
            'lastUpdated':
                previous.lastUpdated.millisecondsSinceEpoch == 0
                    ? null
                    : previous.lastUpdated.toIso8601String(),
            'uptime': previous.uptime,
            'online': previous.online,
            'distance': previous.distance,
            ..._locations[id]!,
          };

          _bins[id] = Bin.fromJson(merged);
        } else {
          // Create a bin entry even if its sensor event
          // hasn't arrived yet.
          _bins[id] = Bin.fromJson({
            ..._locations[id]!,
            'deviceId': id,
            'status': 'UNKNOWN',
            'fillPercentage': 0,
            'uptime': 0,
            'online': false,
            'distance': 0,
          });
        }
      }

      _hasLoadedLocations = true;
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to load bin locations: $error');
    } finally {
      _isLoadingLocations = false;
    }
  }

  // Start fetching coordinates and refresh them periodically.
  void startLocationUpdates({
    Duration interval = const Duration(minutes: 5),
  }) {
    _locationRefreshTimer?.cancel();

    unawaited(loadBinLocations());

    _locationRefreshTimer = Timer.periodic(
      interval,
      (_) => unawaited(loadBinLocations()),
    );
  }

  void stopLocationUpdates() {
    _locationRefreshTimer?.cancel();
    _locationRefreshTimer = null;
  }

  // Optional cleanup when the app no longer needs live bin data.
  void clear() {
    _bins.clear();
    _locations.clear();
    _hasLoadedLocations = false;
    notifyListeners();
  }

  // Keep compatibility with existing app.dart
void updateFromSocket(dynamic data) {
  if (data is! Map) return;

  updateFromSensorData(
    Map<String, dynamic>.from(data),
  );
}

// Keep compatibility with existing main.dart
Future<void> loadSavedLocations() async {
  await loadBinLocations();
}
}
