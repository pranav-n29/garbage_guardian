import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Profile',
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

            // =========================================================
            // PROFILE HEADER
            // =========================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [

                  // Avatar
                  Container(
                    width: 82,
                    height: 82,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,

                      border: Border.all(
                        color: const Color(0xFF2E7D32),
                        width: 2,
                      ),
                    ),

                    child: const Icon(
                      Icons.person_outline,
                      size: 45,
                      color: Color(0xFF2E7D32),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Citizen',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Garbage Guardian Citizen',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Account badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),

                        SizedBox(width: 6),

                        Text(
                          'Citizen Account',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================================================
            // ACCOUNT
            // =========================================================

            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),

                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),

              child: Column(
                children: [

                  _menuItem(
                    icon: Icons.assignment_outlined,
                    title: 'My Reports',
                    subtitle:
                        'Track issues reported by you',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/my-reports',
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                    indent: 68,
                  ),

                  _menuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle:
                        'View smart bin alerts and updates',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/notifications',
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                    indent: 68,
                  ),

                  _menuItem(
                    icon: Icons.recycling_outlined,
                    title: 'Waste Awareness',
                    subtitle:
                        'Learn about proper waste disposal',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/awareness',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================================================
            // APP INFORMATION
            // =========================================================

            const Text(
              'Application',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),

                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),

              child: Column(
                children: [

                  _infoItem(
                    icon: Icons.person_outline,
                    title: 'Account Type',
                    value: 'Citizen',
                  ),

                  const Divider(
                    height: 1,
                    indent: 68,
                  ),

                  _infoItem(
                    icon: Icons.delete_outline,
                    title: 'Service',
                    value: 'Garbage Guardian',
                  ),

                  const Divider(
                    height: 1,
                    indent: 68,
                  ),

                  _infoItem(
                    icon: Icons.cloud_done_outlined,
                    title: 'System',
                    value: 'Smart Bin Monitoring',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================================================
            // LOGOUT
            // =========================================================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: OutlinedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },

                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),

                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: OutlinedButton.styleFrom(
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

            // =========================================================
            // FOOTER
            // =========================================================

            const Center(
              child: Column(
                children: [
                  Text(
                    'Garbage Guardian',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Smart Waste Management',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // MENU ITEM
  // ================================================================

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        child: Row(
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

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // INFORMATION ITEM
  // ================================================================

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),

      child: Row(
        children: [

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: Colors.grey.shade700,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LOGOUT DIALOG
  // ================================================================

  void _showLogoutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            'Are you sure you want to logout?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }
}