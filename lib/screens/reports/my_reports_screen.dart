import 'package:flutter/material.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'id': 'RPT-001',
        'binId': 'GG-103',
        'issue': 'Bin is full / overflowing',
        'location': 'Market Street',
        'date': 'Today, 10:30 AM',
        'status': 'Pending',
      },
      {
        'id': 'RPT-002',
        'binId': 'GG-101',
        'issue': 'Bin is damaged',
        'location': 'Green Park',
        'date': 'Yesterday, 4:15 PM',
        'status': 'In Progress',
      },
      {
        'id': 'RPT-003',
        'binId': 'GG-107',
        'issue': 'Bin was not collected',
        'location': 'City Center',
        'date': '12 Aug 2026, 9:20 AM',
        'status': 'Resolved',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: Color(0xFF2E7D32),
                  size: 32,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Track the issues you have reported.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4F6F52),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Summary
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  icon: Icons.pending_actions,
                  title: 'Pending',
                  value: '1',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  icon: Icons.autorenew,
                  title: 'Progress',
                  value: '1',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  icon: Icons.check_circle_outline,
                  title: 'Resolved',
                  value: '1',
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'Recent Reports',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...reports.map(
            (report) => _reportCard(
              context,
              report,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(
    BuildContext context,
    Map<String, String> report,
  ) {
    final status = report['status']!;

    Color statusColor;

    if (status == 'Resolved') {
      statusColor = const Color(0xFF2E7D32);
    } else if (status == 'In Progress') {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['id']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Bin ${report['binId']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Issue
            Text(
              report['issue']!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    report['location']!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            // Date
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  report['date']!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Divider(),

            const SizedBox(height: 4),

            // Details button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  _showReportDetails(
                    context,
                    report,
                  );
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                ),
                label: const Text(
                  'View Report Details',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(
    BuildContext context,
    Map<String, String> report,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                report['id']!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              _detailRow(
                'Bin',
                report['binId']!,
              ),

              _detailRow(
                'Issue',
                report['issue']!,
              ),

              _detailRow(
                'Location',
                report['location']!,
              ),

              _detailRow(
                'Submitted',
                report['date']!,
              ),

              _detailRow(
                'Status',
                report['status']!,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}