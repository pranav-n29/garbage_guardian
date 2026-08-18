import 'package:flutter/material.dart';

class AwarenessScreen extends StatelessWidget {
  const AwarenessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Wet Waste',
        'subtitle': 'Kitchen and biodegradable waste',
        'icon': Icons.eco_outlined,
        'color': const Color(0xFF2E7D32),
        'examples': 'Food scraps, vegetables, fruits, tea leaves',
        'tip': 'Keep wet waste separate and use a compost bin when possible.',
      },
      {
        'title': 'Dry Waste',
        'subtitle': 'Clean recyclable materials',
        'icon': Icons.inventory_2_outlined,
        'color': Colors.blue,
        'examples': 'Paper, cardboard, clean packaging, newspapers',
        'tip': 'Keep recyclable materials clean and dry before disposal.',
      },
      {
        'title': 'Plastic',
        'subtitle': 'Plastic containers and packaging',
        'icon': Icons.local_drink_outlined,
        'color': Colors.orange,
        'examples': 'Bottles, containers, wrappers, plastic packaging',
        'tip': 'Avoid single-use plastic and reuse containers whenever possible.',
      },
      {
        'title': 'Metal',
        'subtitle': 'Metal items suitable for recycling',
        'icon': Icons.build_outlined,
        'color': Colors.blueGrey,
        'examples': 'Cans, tins, metal containers, aluminium items',
        'tip': 'Clean metal containers before placing them with recyclables.',
      },
      {
        'title': 'E-Waste',
        'subtitle': 'Electronic and electrical waste',
        'icon': Icons.devices_outlined,
        'color': Colors.deepPurple,
        'examples': 'Phones, chargers, batteries, keyboards, electronics',
        'tip': 'Never throw e-waste into normal household waste. Use authorized collection points.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: const Text(
          'Waste Awareness',
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.recycling,
                    color: Color(0xFF2E7D32),
                    size: 38,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Segregate Right. Recycle More.',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Proper waste segregation helps keep our city '
                    'clean and makes recycling more effective.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4F6F52),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Know Your Waste',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Learn where different types of waste belong.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 15),

            ...categories.map(
              (category) => _wasteCard(
                context,
                category,
              ),
            ),

            const SizedBox(height: 10),

            // Golden rule
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Remember',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Reduce what you consume, reuse what you can, '
                    'and recycle what is suitable for recycling.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.5,
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

  Widget _wasteCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final Color color = category['color'];

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          backgroundColor: Colors.white,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                5,
                20,
                30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Icon(
                          category['icon'],
                          color: color,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category['title'],
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Examples',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    category['examples'],
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Tip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    category['tip'],
                    style: const TextStyle(
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                category['icon'],
                color: color,
                size: 29,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['subtitle'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}