import 'package:flutter/material.dart';
import 'card_decoration.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String? value;
  final bool big;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.title,
    this.value,
    this.big = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 24, color: Colors.grey),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (value != null) const SizedBox(height: 4),
                if (value != null)
                  Text(
                    value!,
                    style: TextStyle(
                      fontSize: big ? 28 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
