import 'package:flutter/material.dart';

class ClothingImageCard extends StatelessWidget {
  final String imagePath;

  const ClothingImageCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
