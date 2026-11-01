
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _reports = [];
  final Set<String> _readReports = {};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.instance.getMyReports();
      final data = result['reports'];

      if (!mounted) return;

      setState(() {
        _reports = data is List
            ? data
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
            : [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _value(Map<String, dynamic> report, String key) {
    return report[key]?.toString().trim() ?? '';
  }

  String _reportId(Map<String, dynamic> report) {
    final id = _value(report, 'reportId');
    return id.isNotEmpty ? id : _value(report, 'id');
  }

  String _status(Map<String, dynamic> report) {
    final raw = _value(report, 'status').toLowerCase();

    switch (raw) {
      case 'reported':
      case 'pending':
        return 'Reported';
      case 'processing':
      case 'in progress':
      case 'in_progress':
        return 'Processing';
      case 'resolved':
      case 'completed':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return raw.isEmpty
            ? 'Reported'
            : raw[0].toUpperCase() + raw.substring(1);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFF2E7D32);
      case 'Processing':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Resolved':
        return Icons.check_circle_outline;
      case 'Processing':
        return Icons.sync;
      case 'Rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  String _formatTime(Map<String, dynamic> report) {
    final raw = _value(report, 'updatedAt').isNotEmpty
        ? _value(report, 'updatedAt')
        : _value(report, 'createdAt');

    if (raw.isEmpty) return 'Time unavailable';

    final date = DateTime.tryParse(raw);
    if (date == null) return 'Time unavailable';

    final difference = DateTime.now().difference(date.toLocal());

    if (difference.isNegative || difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }
    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _message(String status) {
    switch (status) {
      case 'Resolved':
        return 'Your reported issue has been resolved.';
      case 'Processing':
        return 'Your report is being processed by the team.';
      case 'Rejected':
        return 'Your report was rejected. Check the report details for more information.';
      default:
        return 'Your report has been received.';
    }
  }

  void _markAsRead(String id) {
    if (id.isEmpty) return;
    setState(() => _readReports.add(id));
  }

  void _showReportDetails(Map<String, dynamic> report) {
    final status = _status(report);
    final color = _statusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Report Update',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _detailRow('Report ID', _reportId(report)),
              _detailRow(
                'Issue',
                _value(report, 'issueType').isEmpty
                    ? 'Reported issue'
                    : _value(report, 'issueType'),
              ),
              _detailRow(
                'Bin ID',
                _value(report, 'binId').isEmpty
                    ? 'Not specified'
                    : _value(report, 'binId'),
              ),
              _detailRow(
                'Location',
                _value(report, 'location').isEmpty
                    ? 'Location unavailable'
                    : _value(report, 'location'),
              ),
              _detailRow('Last updated', _formatTime(report)),
              const SizedBox(height: 8),
              Text(
                _message(status),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not available' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _reports.where((report) {
      final id = _reportId(report);
      return id.isNotEmpty && !_readReports.contains(id);
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Report Updates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _readReports.addAll(
                    _reports
                        .map(_reportId)
                        .where((id) => id.isNotEmpty),
                  );
                });
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  color: const Color(0xFF2E7D32),
                  child: _reports.isEmpty
                      ? _buildEmpty()
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Track your reports',
                                          style: TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'See the latest status of issues you reported.',
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
                            const SizedBox(height: 20),
                            Text(
                              'Your Reports (${_reports.length})',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._reports.map(_buildReportCard),
                          ],
                        ),
                ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final id = _reportId(report);
    final status = _status(report);
    final color = _statusColor(status);
    final isRead = _readReports.contains(id);

    final issue = _value(report, 'issueType');
    final binId = _value(report, 'binId');
    final location = _value(report, 'location');

    return InkWell(
      onTap: () {
        _markAsRead(id);
        _showReportDetails(report);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF1F8F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? Colors.grey.shade200
                : const Color(0xFFB7DDBA),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(_statusIcon(status), color: color, size: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id.isEmpty ? 'Your Report' : id,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        issue.isEmpty ? 'Reported issue' : issue,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 5, left: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  icon: Icons.circle,
                  text: status,
                  color: color,
                ),
                if (binId.isNotEmpty)
                  _infoChip(
                    icon: Icons.delete_outline,
                    text: binId,
                    color: Colors.grey.shade700,
                  ),
              ],
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 15,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _formatTime(report),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Text(
                  'View details',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.cloud_off_outlined, size: 62, color: Colors.grey),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Unable to load your reports',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _error ?? 'Something went wrong.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 18),
        Center(
          child: ElevatedButton.icon(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 85),
        Container(
          width: 90,
          height: 90,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.assignment_outlined,
            color: Color(0xFF2E7D32),
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'No report updates yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'When you report a smart-bin issue, its status and updates will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/report-issue')
                  .then((_) => _loadReports());
            },
            icon: const Icon(Icons.add),
            label: const Text('Report an Issue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
