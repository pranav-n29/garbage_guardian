import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> nearbyNotifications = [
    {
      'type': 'critical',
      'icon': Icons.warning_amber_rounded,
      'title': 'GG-103 is Almost Full',
      'message':
          'The smart bin at Market Area is 92% full. Consider using another nearby bin.',
      'location': 'Market Area',
      'distance': '650 m away',
      'time': '10 min ago',
      'read': false,
    },
    {
      'type': 'warning',
      'icon': Icons.delete_outline,
      'title': 'GG-101 is Filling Up',
      'message':
          'The smart bin at Park Street is currently 78% full.',
      'location': 'Park Street',
      'distance': '400 m away',
      'time': '35 min ago',
      'read': false,
    },
    {
      'type': 'success',
      'icon': Icons.check_circle_outline,
      'title': 'Collection Completed',
      'message':
          'GG-102 at Main Road has been emptied successfully.',
      'location': 'Main Road',
      'distance': '700 m away',
      'time': '2 hrs ago',
      'read': true,
    },
    {
      'type': 'info',
      'icon': Icons.info_outline,
      'title': 'GG-104 Available',
      'message':
          'A nearby smart bin currently has plenty of available capacity.',
      'location': 'School Zone',
      'distance': '900 m away',
      'time': '3 hrs ago',
      'read': true,
    },
  ];

  final List<Map<String, dynamic>> activityNotifications = [
    {
      'type': 'success',
      'icon': Icons.check_circle_outline,
      'title': 'Report Submitted',
      'message':
          'Your report RPT-001 has been successfully submitted.',
      'time': 'Today, 10:30 AM',
      'read': true,
    },
    {
      'type': 'info',
      'icon': Icons.assignment_outlined,
      'title': 'Report Under Review',
      'message':
          'Your report RPT-002 is being reviewed by the collection team.',
      'time': 'Yesterday, 4:15 PM',
      'read': false,
    },
    {
      'type': 'success',
      'icon': Icons.task_alt,
      'title': 'Report Resolved',
      'message':
          'Your report RPT-003 has been resolved.',
      'time': '12 Aug 2026',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final notifications = selectedTab == 0
        ? nearbyNotifications
        : activityNotifications;

    final unreadCount = notifications
        .where((notification) => notification['read'] == false)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
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
                setState(() {
                  for (final notification in notifications) {
                    notification['read'] = true;
                  }
                });
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
          // Header
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
                    borderRadius: BorderRadius.circular(14),
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
                            ? 'Updates from smart bins near you'
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

          // Tabs
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
                    title: 'Nearby Bins',
                    icon: Icons.location_on_outlined,
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

          // Notifications list
          Expanded(
            child: notifications.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
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

  Widget _tabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final bool selected = selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE8F5E9)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
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

  Widget _notificationCard(
    Map<String, dynamic> notification,
  ) {
    final bool isRead = notification['read'] == true;

    final Color color =
        _getNotificationColor(notification['type']);

    return InkWell(
      onTap: () {
        setState(() {
          notification['read'] = true;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : const Color(0xFFF1F8F2),
          borderRadius: BorderRadius.circular(18),
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
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                notification['icon'],
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

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
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
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
                      if (notification['location'] != null)
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
                              notification['location'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                      if (notification['distance'] != null)
                        Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              notification['distance'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

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
                            style: const TextStyle(
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

  Widget _emptyState() {
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
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Color(0xFF2E7D32),
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'You are all caught up. We will notify you '
              'when there is an important update.',
              textAlign: TextAlign.center,
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

  Color _getNotificationColor(String type) {
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
}