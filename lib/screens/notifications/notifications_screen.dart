import 'package:flutter/material.dart';
import '../../models/bin.dart';
import '../../services/bin_store.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  int selectedTab = 0;

  // Keeps track of notifications the citizen has read.
  final Set<String> _readBinNotifications = {};

  // Temporary report activity.
  // This will later be replaced by real backend report data.
  final List<Map<String, dynamic>> activityNotifications = [
    {
      'type': 'info',
      'icon': Icons.assignment_outlined,
      'title': 'Report Activity',
      'message':
          'Your submitted reports will appear here with their latest status.',
      'time': 'Available after report submission',
      'read': true,
    },
  ];

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
        'time': _formatLastUpdated(bin.lastUpdated),
        'read': _readBinNotifications.contains(
          '${bin.id}_$fill',
        ),
      });
    }

    // Highest fill level first.
    notifications.sort(
      (a, b) {
        final String aId = a['id'].toString();
        final String bId = b['id'].toString();

        final int aFill = _extractFillFromId(aId);
        final int bFill = _extractFillFromId(bId);

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
    final id = notification['id']?.toString();

    if (id == null) {
      return;
    }

    setState(() {
      _readBinNotifications.add(id);
    });
  }

  void _markAllAsRead(
    List<Map<String, dynamic>> notifications,
  ) {
    setState(() {
      for (final notification in notifications) {
        final id = notification['id']?.toString();

        if (id != null) {
          _readBinNotifications.add(id);
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
            child: notifications.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount:
                        notifications.length,

                    itemBuilder: (context, index) {
                      return _notificationCard(
                        notifications[index],
                      );
                    },
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
      notification['type'],
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
                          notification['title'],

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
                    notification['message'],

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

                      // BIN ID / LOCATION
                      if (notification['location']
                          ?.toString()
                          .isNotEmpty ==
                          true)
                        Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 3),

                            Text(
                              notification[
                                  'location'],

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
                            notification['time'],

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

            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'There are no high-fill smart bin alerts right now.',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
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