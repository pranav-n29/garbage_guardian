
import 'package:flutter/material.dart';

import '../../models/bin.dart';
import '../../services/bin_store.dart';

class BinDetailsScreen extends StatefulWidget {
  const BinDetailsScreen({super.key});

  @override
  State<BinDetailsScreen> createState() => _BinDetailsScreenState();
}

class _BinDetailsScreenState extends State<BinDetailsScreen> {
  String? _binId;

  @override
  void initState() {
    super.initState();
    BinStore.instance.addListener(_onBinUpdated);
  }

  @override
  void dispose() {
    BinStore.instance.removeListener(_onBinUpdated);
    super.dispose();
  }

  void _onBinUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    Bin? initialBin;

    if (arguments is Bin) {
      initialBin = arguments;
    } else if (arguments is Map) {
      final id = arguments['binId']?.toString();

      if (id != null && id.isNotEmpty) {
        for (final item in BinStore.instance.bins) {
          if (item.id == id) {
            initialBin = item;
            break;
          }
        }
      }
    }

    _binId ??= initialBin?.id;

    Bin? bin;

    if (_binId != null) {
      for (final item in BinStore.instance.bins) {
        if (item.id == _binId) {
          bin = item;
          break;
        }
      }
    }

    bin ??= initialBin;

    if (bin == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          title: const Text('Bin Details'),
        ),
        body: const Center(
          child: Text(
            'Bin information is unavailable.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final fill = bin.hasSensorData
        ? bin.fillLevel.round().clamp(0, 100)
        : 0;

    final statusColor = _getStatusColor(fill);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bin Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MAIN STATUS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 52,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    bin.id,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          bin.location.isEmpty
                              ? 'Location unavailable'
                              : bin.location,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    bin.displayFillLevel,
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const Text(
                    'Current Fill Level',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: bin.hasSensorData ? fill / 100 : 0,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      bin.displayStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BIN INFORMATION
            const Text(
              'Bin Information',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _infoRow(
                    icon: Icons.badge_outlined,
                    title: 'Bin ID',
                    value: bin.id,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    value: bin.location.isEmpty
                        ? 'Location unavailable'
                        : bin.location,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.delete_outline,
                    title: 'Fill Level',
                    value: bin.displayFillLevel,
                    valueColor: statusColor,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.info_outline,
                    title: 'Status',
                    value: bin.displayStatus,
                    valueColor: statusColor,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    icon: Icons.update,
                    title: 'Last Updated',
                    value: bin.displayLastUpdated,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // IN-APP NAVIGATION
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: bin.hasLocation
                    ? () => _navigateToBin(bin!)
                    : null,
                icon: const Icon(Icons.navigation_outlined),
                label: const Text(
                  'Navigate to Bin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // REPORT ISSUE
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/report-issue',
                 arguments: {
  'binId': bin!.id,
  'location': bin!.location,
},
                  );
                },
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text(
                  'Report an Issue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // OPEN THE LOCAL FLUTTER MAP
  void _navigateToBin(Bin bin) {
    if (!bin.hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valid bin coordinates are unavailable.'),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/map',
      arguments: bin,
    );
  }

  static Color _getStatusColor(int fill) {
    if (fill >= 81) {
      return Colors.red;
    }

    if (fill >= 51) {
      return Colors.orange;
    }

    return const Color(0xFF2E7D32);
  }

  static Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
