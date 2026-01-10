import 'package:flutter/material.dart';

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12), // Darker shadow
        blurRadius: 12,
        offset: const Offset(4, 6), // More 3D offset
      ),
      BoxShadow(
        color: Colors.white,
        blurRadius: 10,
        offset: const Offset(-4, -4), // Highlight for depth
      ),
    ],
  );
}
