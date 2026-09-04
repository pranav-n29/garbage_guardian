import 'package:flutter/material.dart';
import '../../models/bin.dart';
import '../../services/bin_store.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Bin? _selectedBin;

  @override
  void initState() {
    super.initState();
    BinStore.instance.addListener(_onBinsUpdated);
  }

  @override
  void dispose() {
    BinStore.instance.removeListener(_onBinsUpdated);
    super.dispose();
  }

  void _onBinsUpdated() {
    if (!mounted) return;

    final bins = BinStore.instance.bins;

    // Keep selected bin synchronized with the latest live data.
    if (_selectedBin != null) {
      try {
        _selectedBin = bins.firstWhere(
          (bin) => bin.id == _selectedBin!.id,
        );
      } catch (_) {
        _selectedBin = null;
      }
    }

    setState(() {});
  }

  Color _getStatusColor(int fill) {
    if (fill >= 81) {
      return Colors.red;
    }

    if (fill >= 51) {
      return Colors.orange;
    }

    return const Color(0xFF2E7D32);
  }

  String _getStatusText(Bin bin) {
    final fill = bin.fillLevel.round().clamp(0, 100);

    if (fill >= 81) {
      return 'High Fill Level';
    }

    if (fill >= 51) {
      return 'Moderate Fill Level';
    }

    return 'Normal Fill Level';
  }

  void _selectBin(Bin bin) {
    setState(() {
      _selectedBin = bin;
    });
  }

  void _openDetails(Bin bin) {
    Navigator.pushNamed(
      context,
      '/bin-details',
      arguments: bin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bins = BinStore.instance.bins;

    final criticalBins = bins.where(
      (bin) => bin.fillLevel >= 81,
    ).length;

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
            onPressed: () {
              setState(() {
                _selectedBin = null;
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: bins.isEmpty
          ? _buildLoadingState()
          : Column(
              children: [

                // -----------------------------------------------------
                // SUMMARY
                // -----------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    12,
                  ),

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
                          icon: Icons.warning_amber_outlined,
                          title: 'High Fill',
                          value: '$criticalBins',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                // -----------------------------------------------------
                // INFORMATION
                // -----------------------------------------------------

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    8,
                  ),

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF2E7D32),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Live smart bin locations are not available yet. '
                          'The list below shows bins received from the '
                          'monitoring system.',
                          style: TextStyle(
                            color: Color(0xFF285D2B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // -----------------------------------------------------
                // BIN LIST
                // -----------------------------------------------------

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),

                    itemCount: bins.length,

                    itemBuilder: (context, index) {
                      final bin = bins[index];

                      return _buildBinCard(bin);
                    },
                  ),
                ),

                // -----------------------------------------------------
                // SELECTED BIN
                // -----------------------------------------------------

                if (_selectedBin != null)
                  _buildSelectedBinCard(_selectedBin!),
              ],
            ),
    );
  }

  // -------------------------------------------------------------------
  // LOADING
  // -------------------------------------------------------------------

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
              'Live bins will appear here when data is received.',
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

  // -------------------------------------------------------------------
  // SUMMARY CARD
  // -------------------------------------------------------------------

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // BIN CARD
  // -------------------------------------------------------------------

  Widget _buildBinCard(Bin bin) {
    final fill = bin.fillLevel.round().clamp(0, 100);

    final statusColor = _getStatusColor(fill);

    final isSelected =
        _selectedBin?.id == bin.id;

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

                // BIN ICON
                Container(
                  width: 50,
                  height: 50,

                  decoration: BoxDecoration(
                    color:
                        statusColor.withValues(alpha: 0.1),

                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.delete_outline,
                    color: statusColor,
                    size: 29,
                  ),
                ),

                const SizedBox(width: 13),

                // BIN DETAILS
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

                // FILL
                Text(
                  '$fill%',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            // PROGRESS
            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: LinearProgressIndicator(
                value: fill / 100,
                minHeight: 8,

                backgroundColor:
                    Colors.grey.shade200,

                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  statusColor,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color:
                        statusColor.withValues(alpha: 0.1),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    bin.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  bin.location.isEmpty
                      ? 'Location unavailable'
                      : bin.location,

                  style: const TextStyle(
                    color: Colors.grey,
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

  // -------------------------------------------------------------------
  // SELECTED BIN CARD
  // -------------------------------------------------------------------

  Widget _buildSelectedBinCard(Bin bin) {
    final fill = bin.fillLevel.round().clamp(0, 100);

    final statusColor = _getStatusColor(fill);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        18,
      ),

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

      child: Column(
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
                  '$fill%',
                  statusColor,
                ),
              ),

              Expanded(
                child: _selectedInfo(
                  'Status',
                  bin.status,
                  statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,

            child: ElevatedButton.icon(
              onPressed: () => _openDetails(bin),

              icon: const Icon(
                Icons.visibility_outlined,
              ),

              label: const Text(
                'View Bin Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2E7D32),

                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedInfo(
    String title,
    String value,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

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