import 'package:flutter/material.dart';
import 'card_decoration.dart';

import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:io';

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

  Widget _buildImage(String path) {
    if (path.isEmpty) return const SizedBox();
    
    // Normalize path just in case
    // If it's a URL (Firebase Storage)
    if (path.startsWith('http')) {
       return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
       );
    }
    // If it's an Asset
    if (path.startsWith('assets/')) {
       return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
       );
    }
    // If it's a Local File (Mobile)
    if (!kIsWeb && File(path).existsSync()) {
       return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.error),
       );
    }
    // Fallback for Web if it's not HTTP/Asset? Or weird path.
    return const Icon(Icons.image, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// IMAGE
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias, // Clip inner image
            child: _buildImage(imagePath),
          ),

          const SizedBox(width: 10),

          /// TEXT
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
                const SizedBox(height: 2),
                Text(
                  item,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$times times',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
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
