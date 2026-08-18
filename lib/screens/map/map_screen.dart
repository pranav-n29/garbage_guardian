import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Map<String, dynamic>> bins = [
    {
      'id': 'GG-101',
      'location': 'Park Street',
      'fill': 78,
      'distance': '400 m',
    },
    {
      'id': 'GG-102',
      'location': 'Main Road',
      'fill': 45,
      'distance': '700 m',
    },
    {
      'id': 'GG-103',
      'location': 'Market Area',
      'fill': 92,
      'distance': '650 m',
    },
    {
      'id': 'GG-104',
      'location': 'School Zone',
      'fill': 30,
      'distance': '900 m',
    },
  ];

  int? selectedBinIndex;

  Color _getBinColor(int fill) {
    if (fill >= 81) {
      return Colors.red;
    }

    if (fill >= 51) {
      return Colors.orange;
    }

    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        title: const Text(
          'Nearby Smart Bins',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Your location will be detected here.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.my_location,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          // Temporary map area
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE7ECE7),
              child: CustomPaint(
                painter: _MapBackgroundPainter(),
                child: Stack(
                  children: [
                    _mapMarker(
                      index: 0,
                      left: 75,
                      top: 130,
                    ),
                    _mapMarker(
                      index: 1,
                      left: 250,
                      top: 190,
                    ),
                    _mapMarker(
                      index: 2,
                      left: 155,
                      top: 310,
                    ),
                    _mapMarker(
                      index: 3,
                      left: 310,
                      top: 100,
                    ),

                    // Current location
                    Positioned(
                      left: 185,
                      top: 205,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.blue,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map label
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFF2E7D32),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing smart bins near your location',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected bin
          if (selectedBinIndex != null)
            Positioned(
              left: 15,
              right: 15,
              bottom: 15,
              child: _selectedBinCard(
                bins[selectedBinIndex!],
              ),
            ),
        ],
      ),
    );
  }

  Widget _mapMarker({
    required int index,
    required double left,
    required double top,
  }) {
    final bin = bins[index];
    final Color color = _getBinColor(bin['fill']);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedBinIndex = index;
          });
        },
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 25,
              ),
            ),
            CustomPaint(
              size: const Size(12, 8),
              painter: _MarkerTrianglePainter(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedBinCard(
    Map<String, dynamic> bin,
  ) {
    final Color color = _getBinColor(bin['fill']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.delete_outline,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  bin['id'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bin['location'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${bin['distance']} • ${bin['fill']}% full',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/bin-details',
                arguments: bin,
              );
            },
            icon: const Icon(
              Icons.chevron_right,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    // Horizontal roads
    for (double y = 70; y < size.height; y += 90) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical roads
    for (double x = 60; x < size.width; x += 100) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Main diagonal roads
    paint.strokeWidth = 5;

    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.25),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.15, 0),
      Offset(size.width * 0.85, size.height),
      paint,
    );

    // Parks
    paint
      ..color = const Color(0xFFDDEEDB)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.65),
      60,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.35),
      45,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

class _MarkerTrianglePainter extends CustomPainter {
  final Color color;

  _MarkerTrianglePainter(this.color);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}