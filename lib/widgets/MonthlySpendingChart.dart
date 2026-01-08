import 'package:flutter/material.dart';
import 'package:my_app/widgets/card_decoration.dart';
import 'package:fl_chart/fl_chart.dart';


class MonthlySpendChart extends StatelessWidget {
  const MonthlySpendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.purple,
              barWidth: 3,
              dotData: FlDotData(show: true),
              spots: const [
                FlSpot(0, 60),
                FlSpot(1, 80),
                FlSpot(2, 120),
                FlSpot(3, 100),
                FlSpot(4, 140),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

