import 'package:flutter/material.dart';
import '../../services/report_store.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();

    ReportStore.instance.addListener(_onReportsUpdated);
  }

  @override
  void dispose() {
    ReportStore.instance.removeListener(_onReportsUpdated);
    super.dispose();
  }

  void _onReportsUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = ReportStore.instance.reports;

    final totalReports = reports.length;

    final pendingReports = reports
        .where((report) => report.status == 'Pending')
        .length;

    final resolvedReports = reports
        .where((report) => report.status == 'Resolved')
        .length;

    final inProgressReports = reports
        .where((report) => report.status == 'In Progress')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'My Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          // ---------------------------------------------------------
          // HEADER
          // ---------------------------------------------------------

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8,
            ),
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
                  size: 30,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                          color: Color(0xFF4F6651),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------------------
          // SUMMARY
          // ---------------------------------------------------------

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),

            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    icon: Icons.assignment_outlined,
                    title: 'Total',
                    value: '$totalReports',
                    color: const Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _summaryCard(
                    icon: Icons.pending_actions_outlined,
                    title: 'Pending',
                    value: '$pendingReports',
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _summaryCard(
                    icon: Icons.sync,
                    title: 'In Progress',
                    value: '$inProgressReports',
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _summaryCard(
                    icon: Icons.check_circle_outline,
                    title: 'Resolved',
                    value: '$resolvedReports',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ---------------------------------------------------------
          // TITLE
          // ---------------------------------------------------------

          if (reports.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ---------------------------------------------------------
          // REPORT LIST
          // ---------------------------------------------------------

          Expanded(
            child: reports.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      24,
                    ),

                    itemCount: reports.length,

                    itemBuilder: (context, index) {
                      return _buildReportCard(
                        reports[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // SUMMARY CARD
  // -----------------------------------------------------------------

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // REPORT CARD
  // -----------------------------------------------------------------

  Widget _buildReportCard(
    CitizenReport report,
  ) {
    final statusColor =
        _getStatusColor(report.status);

    return InkWell(
      onTap: () {
        _showReportDetails(report);
      },

      borderRadius: BorderRadius.circular(18),

      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // -------------------------------------------------------
            // TOP
            // -------------------------------------------------------

            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius:
                        BorderRadius.circular(13),
                  ),

                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF2E7D32),
                    size: 27,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        report.id,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Bin ${report.binId}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.1,
                    ),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    report.status,
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

            // -------------------------------------------------------
            // ISSUE
            // -------------------------------------------------------

            Text(
              report.issueType,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // LOCATION
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Colors.grey,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    report.location.isEmpty
                        ? 'Location unavailable'
                        : report.location,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // TIME
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 17,
                  color: Colors.grey,
                ),

                const SizedBox(width: 6),

                Text(
                  _formatDate(report.createdAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(),

            const SizedBox(height: 4),

            const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 17,
                  color: Color(0xFF2E7D32),
                ),

                SizedBox(width: 7),

                Text(
                  'View Report Details',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // EMPTY STATE
  // -----------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.assignment_outlined,
                color: Color(0xFF2E7D32),
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No reports yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'When you report an issue with a smart bin, '
              'your report will appear here.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/report-issue',
                );
              },

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Report an Issue',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2E7D32),

                foregroundColor:
                    Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // REPORT DETAILS
  // -----------------------------------------------------------------

  void _showReportDetails(
    CitizenReport report,
  ) {
    final statusColor =
        _getStatusColor(report.status);

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            30,
          ),

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),

          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Center(
                  child: Container(
                    width: 45,
                    height: 5,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Report Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: statusColor
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),

                      child: Text(
                        report.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _detailRow(
                  'Report ID',
                  report.id,
                ),

                _detailRow(
                  'Smart Bin',
                  report.binId,
                ),

                _detailRow(
                  'Issue',
                  report.issueType,
                ),

                _detailRow(
                  'Location',
                  report.location.isEmpty
                      ? 'Location unavailable'
                      : report.location,
                ),

                _detailRow(
                  'Submitted',
                  _formatDate(
                    report.createdAt,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Description',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2E7D32),

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------
  // DETAIL ROW
  // -----------------------------------------------------------------

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 90,

            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // STATUS COLOR
  // -----------------------------------------------------------------

  Color _getStatusColor(
    String status,
  ) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFF2E7D32);

      case 'In Progress':
        return Colors.blue;

      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  // -----------------------------------------------------------------
  // DATE
  // -----------------------------------------------------------------

  String _formatDate(
    DateTime dateTime,
  ) {
    final day =
        dateTime.day.toString().padLeft(2, '0');

    final month =
        dateTime.month.toString().padLeft(2, '0');

    final year =
        dateTime.year.toString();

    final hour =
        dateTime.hour % 12 == 0
            ? 12
            : dateTime.hour % 12;

    final minute =
        dateTime.minute
            .toString()
            .padLeft(2, '0');

    final period =
        dateTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '$day/$month/$year, '
        '$hour:$minute $period';
  }
}