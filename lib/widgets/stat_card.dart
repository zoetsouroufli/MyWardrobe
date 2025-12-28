import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final bool big;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.title,
    this.value = '',
    this.big = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, size: 16),
              if (icon != null) const SizedBox(width: 8),
              Text(title),
            ],
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: big ? 32 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
