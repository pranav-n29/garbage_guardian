import 'package:flutter/material.dart';
import '../../models/bin.dart';
import '../../services/bin_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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

  Color getStatusColor(int fill) {
    if (fill >= 81) {
      return Colors.red;
    } else if (fill >= 51) {
      return Colors.orange;
    } else {
      return const Color(0xFF2E7D32);
    }
  }

  void _onBottomNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/map');
        break;

      case 2:
        Navigator.pushNamed(context, '/report-issue');
        break;

      case 3:
        Navigator.pushNamed(context, '/notifications');
        break;

      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _openBinDetails(Bin bin) {
    Navigator.pushNamed(
      context,
      '/bin-details',
      arguments: bin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bins = BinStore.instance.bins;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.recycling,
                color: Color(0xFF2E7D32),
                size: 25,
              ),
            ),

            const SizedBox(width: 12),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garbage Guardian',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Smart Waste Management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // -------------------------------------------------------
              // GREETING
              // -------------------------------------------------------

              const Text(
                'Hello, Citizen 👋',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Help keep your neighborhood clean.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------
              // SEARCH
              // -------------------------------------------------------

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search smart bins...',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF2E7D32),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // -------------------------------------------------------
              // QUICK ACTIONS
              // -------------------------------------------------------

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      icon: Icons.map_outlined,
                      title: 'Map',
                      color: const Color(0xFF2E7D32),
                      onTap: () {
                        Navigator.pushNamed(context, '/map');
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _quickAction(
                      icon: Icons.report_problem_outlined,
                      title: 'Report Issues',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/report-issue',
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      icon: Icons.recycling,
                      title: 'Waste Guide',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/awareness',
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _quickAction(
                      icon: Icons.notifications_outlined,
                      title: 'Alerts',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/notifications',
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // -------------------------------------------------------
              // SMART BINS
              // -------------------------------------------------------

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Smart Bins',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (bins.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/map',
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // -------------------------------------------------------
              // LIVE BIN DATA
              // -------------------------------------------------------

              if (bins.isEmpty)
                _buildEmptyBinsState()
              else
                ...bins.map(
                  (bin) => _buildBinCard(bin),
                ),
            ],
          ),
        ),
      ),

      // -------------------------------------------------------------
      // BOTTOM NAVIGATION
      // -------------------------------------------------------------

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationTap,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,

        backgroundColor: Colors.white,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Report Issues',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // EMPTY STATE
  // -----------------------------------------------------------------

  Widget _buildEmptyBinsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),

          SizedBox(height: 14),

          Text(
            'Waiting for smart bin data...',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Live bin information will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // QUICK ACTION
  // -----------------------------------------------------------------

  Widget _quickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Container(
        height: 100,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // BIN CARD
  // -----------------------------------------------------------------

  Widget _buildBinCard(Bin bin) {
    final int fill = bin.fillLevel.round().clamp(0, 100);

    final Color statusColor = getStatusColor(fill);

    return InkWell(
      onTap: () => _openBinDetails(bin),
      borderRadius: BorderRadius.circular(18),

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [

            Row(
              children: [

                // BIN ICON
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.delete_outline,
                    color: statusColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                // BIN INFORMATION
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        bin.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 3),

                          Expanded(
                            child: Text(
                              bin.location.isEmpty
                                  ? 'Location unavailable'
                                  : bin.location,

                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // PERCENTAGE
                Text(
                  '$fill%',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(10),

              child: LinearProgressIndicator(
                value: (fill / 100).clamp(0.0, 1.0),
                minHeight: 8,

                backgroundColor:
                    Colors.grey.shade200,

                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  statusColor,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                // STATUS
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color:
                        statusColor.withValues(alpha: 0.1),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    bin.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

                // UPDATED
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      'Updated ${_formatLastUpdated(bin.lastUpdated)}',
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
    );
  }

  // -----------------------------------------------------------------
  // LAST UPDATED
  // -----------------------------------------------------------------

  String _formatLastUpdated(DateTime dateTime) {
    final difference = DateTime.now().toUtc().difference(
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