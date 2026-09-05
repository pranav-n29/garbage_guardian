import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.instance.getMe();

      if (!mounted) return;

      final userData = result['user'];

      setState(() {
        if (userData is Map) {
          _user = Map<String, dynamic>.from(userData);
        } else {
          _user = null;
        }

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

  String get _userName {
    final name = _user?['name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'Citizen';
  }

  String get _userEmail {
    final email = _user?['email']?.toString().trim();

    if (email != null && email.isNotEmpty) {
      return email;
    }

    return 'Email not available';
  }

  String get _userPhone {
    final phone = _user?['phone']?.toString().trim();

    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return 'Not provided';
  }

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

        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadProfile,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh profile',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // PROFILE ICON
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

                    // NAME
                    if (_isLoading)
                      const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF2E7D32),
                        ),
                      )
                    else
                      Text(
                        _userName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 5),

                    // EMAIL
                    Text(
                      _userEmail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ACCOUNT BADGE
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

                    // ERROR MESSAGE
                    if (_error != null) ...[
                      const SizedBox(height: 12),

                      Text(
                        'Unable to load profile data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 5),

                      TextButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ACCOUNT
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
                      subtitle: 'Track issues reported by you',
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
                      subtitle: 'View smart bin alerts and updates',
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
                      subtitle: 'Learn about proper waste disposal',
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

              // USER INFORMATION
              const Text(
                'Personal Information',
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
                      title: 'Name',
                      value: _userName,
                    ),

                    const Divider(
                      height: 1,
                      indent: 68,
                    ),

                    _infoItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: _userEmail,
                    ),

                    const Divider(
                      height: 1,
                      indent: 68,
                    ),

                    _infoItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: _userPhone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // APPLICATION
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

              // LOGOUT
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
      ),
    );
  }

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
                crossAxisAlignment: CrossAxisAlignment.start,

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
              crossAxisAlignment: CrossAxisAlignment.start,

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

  void _showLogoutDialog(BuildContext context) {
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
              onPressed: () async {
                await ApiService.instance.clearToken();

                if (!context.mounted) return;

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