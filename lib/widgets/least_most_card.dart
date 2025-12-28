import 'package:flutter/material.dart';

class LeastMostCard extends StatelessWidget {
  final String title;
  final String item;
  final int times;
  final String imagePath;

  const LeastMostCard({
    super.key,
    required this.title,
    required this.item,
    required this.times,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, height: 48),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(item),
              Text('$times times', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
