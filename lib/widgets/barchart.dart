import 'package:flutter/material.dart';
import 'package:my_app/widgets/card_decoration.dart';
import 'package:fl_chart/fl_chart.dart';


class ClothesByColorBarChart extends StatelessWidget {
  const ClothesByColorBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          barGroups: [
            _bar(0, 10, Colors.blue),
            _bar(1, 14, Colors.purple),
            _bar(2, 8, Colors.black),
            _bar(3, 12, Colors.red),
            _bar(4, 9, Colors.green),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            width: 14,
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
}
