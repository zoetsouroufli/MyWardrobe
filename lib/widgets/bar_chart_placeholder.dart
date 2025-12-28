import 'package:flutter/material.dart';

class BarChartPlaceholder extends StatelessWidget {
  const BarChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Bar chart'),
      ),
    );
  }
}
