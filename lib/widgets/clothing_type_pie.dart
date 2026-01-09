import 'package:flutter/material.dart';
import 'package:my_app/widgets/card_decoration.dart';

import 'package:fl_chart/fl_chart.dart';

class ClothingTypePie extends StatelessWidget {
  final Map<String, int> categoryCounts;

  const ClothingTypePie({super.key, this.categoryCounts = const {}});

  @override
  Widget build(BuildContext context) {
    // Colors map for consistency
    final Map<String, Color> catColors = {
      'Pants': Colors.blue,
      'T-Shirts': Colors.purple,
      'Hoodies': Colors.indigo,
      'Jackets': Colors.teal,
      'Shoes': Colors.orange,
      'Socks': Colors.brown,
      'Accessories': Colors.green,
    };

    // Generate sections
    List<PieChartSectionData> sections = [];
    int total = categoryCounts.values.fold(0, (sum, count) => sum + count);

    categoryCounts.forEach((cat, count) {
      if (count > 0) {
        final color = catColors[cat] ?? Colors.grey;
        final percentage = (count / total) * 100;
        sections.add(_section(percentage, color));
      }
    });

    if (sections.isEmpty) {
      // Fallback if no data
       sections.add(_section(100, Colors.grey.shade300));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Clothing Type',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          SizedBox(
            height: 140,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 45,
                sectionsSpace: 2,
                sections: sections,
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Dynamic Legends
          if (categoryCounts.isEmpty)
             const Text('No data', style: TextStyle(color: Colors.grey)),

          ...categoryCounts.entries.where((e) => e.value > 0).map((e) {
             final color = catColors[e.key] ?? Colors.grey;
             return _legend('${e.key} (${e.value})', color);
          }).toList(),
        ],
      ),
    );
  }

  PieChartSectionData _section(double value, Color color) =>
      PieChartSectionData(
        value: value,
        color: color,
        radius: 18,
        showTitle: false,
      );

  Widget _legend(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      );
}
