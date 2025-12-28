import 'package:flutter/material.dart';

class DonutChartPlaceholder extends StatelessWidget {
  const DonutChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text('Clothing Type'),
      ),
    );
  }
}
