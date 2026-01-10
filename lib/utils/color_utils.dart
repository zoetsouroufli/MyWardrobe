import 'package:flutter/material.dart';
import 'dart:math';

class ColorUtils {
  static const Map<String, Color> _namedColors = {
    'Black': Color(0xFF000000),
    'White': Color(0xFFFFFFFF),
    'Grey': Color(0xFF808080),
    'Red': Color(0xFFFF0000),
    'Blue': Color(0xFF0000FF),
    'Green': Color(0xFF008000),
    'Yellow': Color(0xFFFFFF00),
    'Purple': Color(0xFF800080),
    'Orange': Color(0xFFFFA500),
    'Pink': Color(0xFFFFC0CB),
    'Brown': Color(0xFFA52A2A),
    'Cyan': Color(0xFF00FFFF),
    'Navy': Color(0xFF000080),
    'Maroon': Color(0xFF800000),
    'Olive': Color(0xFF808000),
    'Teal': Color(0xFF008080),
    'Beige': Color(0xFFF5F5DC),
    'Lavender': Color(0xFFE6E6FA),
    'Violet': Color(0xFFEE82EE),
    'Gold': Color(0xFFFFD700),
    'Silver': Color(0xFFC0C0C0),
    'Mint': Color(0xFF98FF98),
    'Coral': Color(0xFFFF7F50),
    'Mustard': Color(0xFFFFDB58),
    'Khaki': Color(0xFFF0E68C),
    'Cream': Color(0xFFFFFDD0),
    'Charcoal': Color(0xFF36454F),
    'Burgundy': Color(0xFF800020),
    'Indigo': Color(0xFF4B0082),
    'Turquoise': Color(0xFF40E0D0),
    'Peach': Color(0xFFFFE5B4),
    'Tan': Color(0xFFD2B48C),
  };

  static String getColorName(Color color) {
    String closestName = 'Unknown';
    double minDistance = double.infinity;

    _namedColors.forEach((name, namedColor) {
      final distance = _calculateDistance(color, namedColor);
      if (distance < minDistance) {
        minDistance = distance;
        closestName = name;
      }
    });

    return closestName;
  }

  static double _calculateDistance(Color c1, Color c2) {
    final rDiff = c1.red - c2.red;
    final gDiff = c1.green - c2.green;
    final bDiff = c1.blue - c2.blue;
    return sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);
  }
}
