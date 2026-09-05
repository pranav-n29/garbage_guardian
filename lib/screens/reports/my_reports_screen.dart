import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // -----------------------------------------------------------------
  // LOAD REPORTS FROM BACKEND
  // -----------------------------------------------------------------

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService.instance.getMyReports();

      final reports = result['reports'];

      if (reports is List) {
        setState(() {
          _reports = reports
              .map(
                (report) =>
                    Map<String, dynamic>.from(report as Map),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _reports = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // -----------------------------------------------------------------
  // HELPERS
  // -----------------------------------------------------------------

  String _stringValue(
    Map<String, dynamic> report,
    String key,
  ) {
    return report[key]?.toString() ?? '';
  }

  DateTime _parseDate(
    Map<String, dynamic> report,
  ) {
    return DateTime.tryParse(
          _stringValue(report, 'createdAt'),
        ) ??
        DateTime.now();
  }

  // -----------------------------------------------------------------
  // BUILD
  // -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final totalReports = _reports.length;

    final pendingReports = _reports
        .where(
          (report) =>
              _stringValue(report, 'status') == 'Pending',
        )
        .length;

    final resolvedReports = _reports
        .where(
          (report) =>
              _stringValue(report, 'status') == 'Resolved',
        )
        .length;

    final inProgressReports = _reports
        .where(
          (report) =>
              _stringValue(report, 'status') ==
              'In Progress',
        )
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

        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadReports,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh reports',
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // -------------------------------------------------
                    // HEADER
                    // -------------------------------------------------

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
                        borderRadius:
                            BorderRadius.circular(18),
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
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Color(0xFF1B5E20),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Track the issues you have reported.',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF4F6651),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // -------------------------------------------------
                    // SUMMARY
                    // -------------------------------------------------

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              icon:
                                  Icons.assignment_outlined,
                              title: 'Total',
                              value: '$totalReports',
                              color:
                                  const Color(0xFF2E7D32),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _summaryCard(
                              icon: Icons
                                  .pending_actions_outlined,
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
                              value:
                                  '$inProgressReports',
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _summaryCard(
                              icon:
                                  Icons.check_circle_outline,
                              title: 'Resolved',
                              value:
                                  '$resolvedReports',
                              color:
                                  const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_reports.isNotEmpty)
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

                    // -------------------------------------------------
                    // REPORT LIST
                    // -------------------------------------------------

                    Expanded(
                      child: _reports.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadReports,
                              color:
                                  const Color(0xFF2E7D32),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  24,
                                ),
                                itemCount: _reports.length,
                                itemBuilder:
                                    (context, index) {
                                  return _buildReportCard(
                                    _reports[index],
                                  );
                                },
                              ),
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
            style: const TextStyle(
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
    Map<String, dynamic> report,
  ) {
    final status = _stringValue(report, 'status');
    final statusColor = _getStatusColor(status);

    final reportId =
        _stringValue(report, 'reportId');

    final binId =
        _stringValue(report, 'binId');

    final issueType =
        _stringValue(report, 'issueType');

    final location =
        _stringValue(report, 'location');

    final createdAt =
        _parseDate(report);

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
                        reportId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Bin $binId',
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

            Text(
              issueType,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

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
                    location.isEmpty
                        ? 'Location unavailable'
                        : location,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 17,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(createdAt),
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
  // ERROR STATE
  // -----------------------------------------------------------------

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 65,
              color: Colors.grey,
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ??
                  'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
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
                ).then((_) {
                  _loadReports();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Report an Issue'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
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
    Map<String, dynamic> report,
  ) {
    final status =
        _stringValue(report, 'status');

    final statusColor =
        _getStatusColor(status);

    final reportId =
        _stringValue(report, 'reportId');

    final binId =
        _stringValue(report, 'binId');

    final issueType =
        _stringValue(report, 'issueType');

    final location =
        _stringValue(report, 'location');

    final description =
        _stringValue(report, 'description');

    final createdAt =
        _parseDate(report);

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
                        status,
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
                  reportId,
                ),

                _detailRow(
                  'Smart Bin',
                  binId,
                ),

                _detailRow(
                  'Issue',
                  issueType,
                ),

                _detailRow(
                  'Location',
                  location.isEmpty
                      ? 'Location unavailable'
                      : location,
                ),

                _detailRow(
                  'Submitted',
                  _formatDate(createdAt),
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
                  description,
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

  String _formatDate(DateTime dateTime) {
  final localDateTime = dateTime.toLocal();

  final day =
      localDateTime.day.toString().padLeft(2, '0');

  final month =
      localDateTime.month.toString().padLeft(2, '0');

  final year =
      localDateTime.year.toString();

  final hour =
      localDateTime.hour % 12 == 0
          ? 12
          : localDateTime.hour % 12;

  final minute =
      localDateTime.minute
          .toString()
          .padLeft(2, '0');

  final period =
      localDateTime.hour >= 12
          ? 'PM'
          : 'AM';

  return '$day/$month/$year, '
      '$hour:$minute $period';
}
}