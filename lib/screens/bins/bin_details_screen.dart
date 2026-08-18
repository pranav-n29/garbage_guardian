import 'package:flutter/material.dart';

class BinDetailsScreen extends StatelessWidget {
  const BinDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    final bin = arguments is Map<String, dynamic>
        ? arguments
        : <String, dynamic>{
            'id': 'GG-101',
            'location': 'Park Street',
            'fill': 78,
            'lastUpdated': '2 min ago',
          };

    final String binId = bin['id'] ?? 'GG-101';
    final String location = bin['location'] ?? 'Park Street';
    final int fill = (bin['fill'] as num?)?.toInt() ?? 78;
    final String lastUpdated = bin['lastUpdated'] ?? '2 min ago';

    final Color statusColor = _getStatusColor(fill);
    final String statusText = _getStatusText(fill);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bin Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Main status card
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

                  // Bin icon
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
                    binId,
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
                      Text(
                        location,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Fill percentage
                  Text(
                    '$fill%',
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

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: fill / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        statusColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Status badge
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
                      statusText,
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

            const Text(
              'Bin Information',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Information card
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
                    value: binId,
                  ),

                  const Divider(height: 24),

                  _infoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    value: location,
                  ),

                  const Divider(height: 24),

                  _infoRow(
                    icon: Icons.access_time,
                    title: 'Last Updated',
                    value: lastUpdated,
                  ),

                  const Divider(height: 24),

                  _infoRow(
                    icon: Icons.sensors_outlined,
                    title: 'Sensor Status',
                    value: 'Active',
                    valueColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Navigate button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Navigation will be connected to Maps.',
                      ),
                    ),
                  );
                },
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Report button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/report-issue',
                    arguments: {
                      'binId': binId,
                      'location': location,
                    },
                  );
                },
                icon: const Icon(
                  Icons.report_problem_outlined,
                ),
                label: const Text(
                  'Report an Issue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Information note
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bin information is updated automatically '
                      'from the smart waste monitoring system.',
                      style: TextStyle(
                        color: Color(0xFF285D2B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  static String _getStatusText(int fill) {
    if (fill >= 81) {
      return 'Almost Full — Collection Recommended';
    }

    if (fill >= 51) {
      return 'Moderately Filled';
    }

    return 'Normal — Plenty of Space';
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