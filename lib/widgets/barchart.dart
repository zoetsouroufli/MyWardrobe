import 'package:flutter/material.dart';
import 'package:my_app/widgets/card_decoration.dart';
import 'package:fl_chart/fl_chart.dart';


class ClothesByColorBarChart extends StatelessWidget {
  final Map<String, int> colorCounts;

  const ClothesByColorBarChart({super.key, required this.colorCounts});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text('Items by Color', 
             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
           const SizedBox(height: 16),
           Expanded(
             child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Sort colors by count descending
                          final sortedEntries = colorCounts.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));
                          final topEntries = sortedEntries.take(5).toList();

                          if (value.toInt() >= 0 && value.toInt() < topEntries.length) {
                             final colorName = topEntries[value.toInt()].key;
                             return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(
                                 colorName, 
                                 style: const TextStyle(fontSize: 10, color: Colors.grey)
                               ),
                             );
                          }
                          return const Text('');
                        },
                        reservedSize: 25,
                      ),
                    ),
                  ),
                  barGroups: _generateBars(),
                ),
             ),
           ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBars() {
    // Sort colors by count descending
    final sortedEntries = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5
    final topEntries = sortedEntries.take(5).toList();

    return List.generate(topEntries.length, (index) {
      final entry = topEntries[index];
      return _bar(index, entry.value.toDouble(), _getColor(entry.key));
    });
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'black': return Colors.black;
      case 'white': return Colors.grey.shade400; // Use grey for visibility
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'grey': return Colors.grey;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      case 'orange': return Colors.orange;
      case 'brown': return Colors.brown;
      default: return Colors.grey;
    }
  }

  BarChartGroupData _bar(int x, double y, Color color) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            width: 18,
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
}
