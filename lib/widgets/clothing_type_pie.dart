import 'package:flutter/material.dart';
import 'package:my_app/widgets/card_decoration.dart';

import 'package:fl_chart/fl_chart.dart';

class ClothingTypePie extends StatelessWidget {
  const ClothingTypePie({super.key});

  @override
  Widget build(BuildContext context) {
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
                sections: [
                  _section(40, Colors.purple),
                  _section(30, Colors.blue),
                  _section(20, Colors.orange),
                  _section(10, Colors.green),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          _legend('Tops', Colors.purple),
          _legend('Bottoms', Colors.blue),
          _legend('Shoes', Colors.orange),
          _legend('Accessories', Colors.green),
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
