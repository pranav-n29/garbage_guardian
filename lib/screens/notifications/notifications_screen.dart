import 'package:flutter/material.dart';

import '../../models/bin.dart';
import '../../services/bin_store.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  int selectedTab = 0;

  // Keeps track of Smart Bin notifications the citizen has read.
  final Set<String> _readBinNotifications = {};

  // Keeps track of report activity notifications the citizen has read.
  final Set<String> _readActivityNotifications = {};

  // Real report activity from backend.
  List<Map<String, dynamic>> activityNotifications = [];

  bool _activityLoading = false;
  String? _activityError;

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
    if (mounted) {
      setState(() {});
    }
  }

  // -------------------------------------------------------------------
  // LOAD REPORT ACTIVITY FROM BACKEND
  // -------------------------------------------------------------------

  Future<void> _loadActivityNotifications() async {
    setState(() {
      _activityLoading = true;
      _activityError = null;
    });

    try {
      final result =
          await ApiService.instance.getMyReports();

      if (!mounted) return;

      final reports = result['reports'];

      if (reports is List) {
        final List<Map<String, dynamic>> notifications = [];

        for (final item in reports) {
          if (item is! Map) continue;

          final report =
              Map<String, dynamic>.from(item);

          final reportId =
              report['reportId']?.toString() ??
                  report['id']?.toString() ??
                  'Report';

          final status =
              report['status']?.toString() ??
                  'Pending';

          final issueType =
              report['issueType']?.toString() ??
                  'Reported Issue';

          final binId =
              report['binId']?.toString() ??
                  'Smart Bin';

          notifications.add({
            'id': reportId,
            'type': _activityType(status),
            'icon': _activityIcon(status),
            'title': '$reportId • $status',
            'message':
                '$issueType reported for $binId.',
            'location':
                report['location']?.toString() ?? '',
            'time': _activityTime(report),
            'read':
                _readActivityNotifications
                    .contains(reportId),
          });
        }

        setState(() {
          activityNotifications = notifications;
          _activityLoading = false;
        });
      } else {
        setState(() {
          activityNotifications = [];
          _activityLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _activityLoading = false;
        _activityError =
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    }
  }

  String _activityType(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return 'success';

      case 'in progress':
      case 'processing':
        return 'info';

      case 'rejected':
        return 'critical';

      default:
        return 'warning';
    }
  }

  IconData _activityIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return Icons.check_circle_outline;

      case 'in progress':
      case 'processing':
        return Icons.sync;

      case 'rejected':
        return Icons.cancel_outlined;

      default:
        return Icons.pending_actions_outlined;
    }
  }

  String _activityTime(
    Map<String, dynamic> report,
  ) {
    final rawDate =
        report['createdAt']?.toString();

    if (rawDate == null || rawDate.isEmpty) {
      return 'Recently';
    }

    final date = DateTime.tryParse(rawDate);

    if (date == null) {
      return 'Recently';
    }

    return _formatLastUpdated(date);
  }

  // -------------------------------------------------------------------
  // CREATE LIVE BIN NOTIFICATIONS
  // -------------------------------------------------------------------

  List<Map<String, dynamic>> getBinNotifications() {
    final bins = BinStore.instance.bins;

    final List<Map<String, dynamic>> notifications = [];

    for (final Bin bin in bins) {
      final int fill =
          bin.fillLevel.round().clamp(0, 100);

      // Only create citizen alerts for bins at 80% or above.
      if (fill < 80) {
        continue;
      }

      final bool critical = fill >= 90;

      notifications.add({
        'id': '${bin.id}_$fill',
        'type': critical ? 'critical' : 'warning',
        'icon': critical
            ? Icons.warning_amber_rounded
            : Icons.delete_outline,
        'title': critical
            ? '${bin.id} is Nearly Full'
            : '${bin.id} is Filling Up',
        'message': critical
            ? 'This smart bin is $fill% full. Consider using another available bin.'
            : 'This smart bin is currently $fill% full. Please consider another bin if possible.',
        'location': bin.location,
        'time': _formatLastUpdated(
          bin.lastUpdated,
        ),
        'read': _readBinNotifications.contains(
          '${bin.id}_$fill',
        ),
      });
    }

    // Highest fill level first.
    notifications.sort(
      (a, b) {
        final String aId =
            a['id'].toString();

        final String bId =
            b['id'].toString();

        final int aFill =
            _extractFillFromId(aId);

        final int bFill =
            _extractFillFromId(bId);

        return bFill.compareTo(aFill);
      },
    );

    return notifications;
  }

  int _extractFillFromId(String id) {
    final parts = id.split('_');

    if (parts.isEmpty) {
      return 0;
    }

    return int.tryParse(parts.last) ?? 0;
  }

  // -------------------------------------------------------------------
  // MARK AS READ
  // -------------------------------------------------------------------

  void _markNotificationAsRead(
    Map<String, dynamic> notification,
  ) {
    final id =
        notification['id']?.toString();

    if (id == null) {
      return;
    }

    setState(() {
      if (selectedTab == 0) {
        _readBinNotifications.add(id);
      } else {
        _readActivityNotifications.add(id);
      }
    });
  }

  void _markAllAsRead(
    List<Map<String, dynamic>> notifications,
  ) {
    setState(() {
      for (final notification in notifications) {
        final id =
            notification['id']?.toString();

        if (id == null) {
          continue;
        }

        if (selectedTab == 0) {
          _readBinNotifications.add(id);
        } else {
          _readActivityNotifications.add(id);
        }
      }
    });
  }

  // -------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications =
        selectedTab == 0
            ? getBinNotifications()
            : activityNotifications;

    final int unreadCount = notifications
        .where(
          (notification) =>
              notification['read'] != true,
        )
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          if (selectedTab == 1)
            IconButton(
              onPressed:
                  _activityLoading
                      ? null
                      : _loadActivityNotifications,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh activity',
            ),

          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                _markAllAsRead(notifications);
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          // -----------------------------------------------------------
          // HEADER
          // -----------------------------------------------------------

          Container(
            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              18,
            ),

            color: Colors.white,

            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFF2E7D32),
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Stay informed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        selectedTab == 0
                            ? 'Live updates from smart bins'
                            : 'Updates about your reports',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------
          // TABS
          // -----------------------------------------------------------

          Container(
            color: Colors.white,

            padding: const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              12,
            ),

            child: Row(
              children: [
                Expanded(
                  child: _tabButton(
                    title: 'Smart Bins',
                    icon: Icons.delete_outline,
                    index: 0,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _tabButton(
                    title: 'My Activity',
                    icon: Icons.assignment_outlined,
                    index: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // -----------------------------------------------------------
          // NOTIFICATION LIST
          // -----------------------------------------------------------

          Expanded(
            child: selectedTab == 1 &&
                    _activityLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                    ),
                  )
                : selectedTab == 1 &&
                        _activityError != null
                    ? _activityErrorState()
                    : notifications.isEmpty
                        ? _emptyState()
                        : RefreshIndicator(
                            onRefresh:
                                selectedTab == 1
                                    ? _loadActivityNotifications
                                    : () async {
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                            color:
                                const Color(0xFF2E7D32),
                            child: ListView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.all(16),
                              itemCount:
                                  notifications.length,
                              itemBuilder:
                                  (context, index) {
                                return _notificationCard(
                                  notifications[index],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // TAB BUTTON
  // -------------------------------------------------------------------

  Widget _tabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final bool selected =
        selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
        });

        if (index == 1 &&
            activityNotifications.isEmpty) {
          _loadActivityNotifications();
        }
      },

      borderRadius:
          BorderRadius.circular(12),

      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE8F5E9)
              : Colors.grey.shade100,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: selected
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade200,
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 18,

              color: selected
                  ? const Color(0xFF2E7D32)
                  : Colors.grey,
            ),

            const SizedBox(width: 6),

            Text(
              title,

              style: TextStyle(
                fontSize: 12,

                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.w500,

                color: selected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // NOTIFICATION CARD
  // -------------------------------------------------------------------

  Widget _notificationCard(
    Map<String, dynamic> notification,
  ) {
    final bool isRead =
        notification['read'] == true;

    final Color color =
        _getNotificationColor(
      notification['type']?.toString(),
    );

    return InkWell(
      onTap: () {
        _markNotificationAsRead(
          notification,
        );
      },

      borderRadius:
          BorderRadius.circular(18),

      child: Container(
        margin:
            const EdgeInsets.only(bottom: 12),

        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : const Color(0xFFF1F8F2),

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: isRead
                ? Colors.grey.shade200
                : const Color(0xFFB7DDBA),
          ),
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ICON
            Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color:
                    color.withValues(alpha: 0.10),

                borderRadius:
                    BorderRadius.circular(13),
              ),

              child: Icon(
                notification['icon'],
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Expanded(
                        child: Text(
                          notification['title']
                              ?.toString() ??
                              'Notification',

                          style: TextStyle(
                            fontSize: 15,

                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                          ),
                        ),
                      ),

                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,

                          margin:
                              const EdgeInsets.only(
                            top: 5,
                            left: 8,
                          ),

                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xFF2E7D32),
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    notification['message']
                            ?.toString() ??
                        '',

                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 12,
                    runSpacing: 5,

                    children: [
                      // LOCATION
                      if (notification['location']
                              ?.toString()
                              .isNotEmpty ==
                          true)
                        Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            const Icon(
                              Icons
                                  .location_on_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 3),

                            Text(
                              notification['location']
                                  .toString(),

                              style:
                                  const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                      // TIME
                      Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 3),

                          Text(
                            notification['time']
                                    ?.toString() ??
                                'Recently',

                            style:
                                const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ACTIVITY ERROR STATE
  // -------------------------------------------------------------------

  Widget _activityErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 60,
              color: Colors.grey,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load activity',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _activityError ??
                  'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed:
                  _loadActivityNotifications,

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

  // -------------------------------------------------------------------
  // EMPTY STATE
  // -------------------------------------------------------------------

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFE8F5E9),
                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons.notifications_none,
                color:
                    Color(0xFF2E7D32),
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              selectedTab == 0
                  ? 'No notifications'
                  : 'No activity yet',

              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              selectedTab == 0
                  ? 'There are no high-fill smart bin alerts right now.'
                  : 'Your submitted reports will appear here.',

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // NOTIFICATION COLOR
  // -------------------------------------------------------------------

  Color _getNotificationColor(
    String? type,
  ) {
    switch (type) {
      case 'critical':
        return Colors.red;

      case 'warning':
        return Colors.orange;

      case 'success':
        return const Color(0xFF2E7D32);

      case 'info':
        return Colors.blue;

      default:
        return Colors.blue;
    }
  }

  // -------------------------------------------------------------------
  // LAST UPDATED
  // -------------------------------------------------------------------

  String _formatLastUpdated(
    DateTime dateTime,
  ) {
    final difference =
        DateTime.now().toUtc().difference(
              dateTime.toUtc(),
            );

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    return '${difference.inDays} days ago';
  }
}