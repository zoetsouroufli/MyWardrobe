import 'package:flutter/material.dart';
import 'package:my_app/widgets/card_decoration.dart';
import 'package:fl_chart/fl_chart.dart';


class MonthlySpendChart extends StatelessWidget {
  final Map<int, double> monthlySpending;

  const MonthlySpendChart({super.key, required this.monthlySpending});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Spending', 
             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  horizontalInterval: 40,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Clean look
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1, 
                      getTitlesWidget: (value, meta) {
                         const months = ['-', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                         if (value.toInt() >= 1 && value.toInt() < months.length) {
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(months[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                           );
                         }
                         return const Text('');
                      },
                      reservedSize: 22,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 12,
                minY: 0,
                maxY: (monthlySpending.values.isEmpty ? 100 : monthlySpending.values.reduce((a, b) => a > b ? a : b)) * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF6C63FF), // Modern Purple
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF6C63FF),
                        ),
                    ), 
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF).withOpacity(0.3),
                          const Color(0xFF6C63FF).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    spots: List.generate(12, (index) {
                      final month = index + 1;
                      return FlSpot(month.toDouble(), monthlySpending[month] ?? 0);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

