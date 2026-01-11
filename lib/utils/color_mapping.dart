import 'package:flutter/material.dart';

/// Maps specific color shades to base color categories for analytics
class ColorMapping {
  // Color definitions with display names and base categories
  static const Map<String, Map<String, dynamic>> colorMap = {
    // Blacks & Whites
    'Black': {'color': Colors.black, 'base': 'Black'},
    'White': {'color': Colors.white, 'base': 'White'},
    
    // Greys
    'Light Grey': {'color': Color(0xFFBDBDBD), 'base': 'Grey'},
    'Grey': {'color': Colors.grey, 'base': 'Grey'},
    'Dark Grey': {'color': Color(0xFF616161), 'base': 'Grey'},
    
    // Blues
    'Light Blue': {'color': Color(0xFF81D4FA), 'base': 'Blue'},
    'Sky Blue': {'color': Color(0xFF4FC3F7), 'base': 'Blue'},
    'Blue': {'color': Colors.blue, 'base': 'Blue'},
    'Navy': {'color': Color(0xFF1565C0), 'base': 'Blue'},
    'Indigo': {'color': Colors.indigo, 'base': 'Blue'},
    
    // Greens
    'Light Green': {'color': Color(0xFF81C784), 'base': 'Green'},
    'Green': {'color': Colors.green, 'base': 'Green'},
    'Dark Green': {'color': Color(0xFF2E7D32), 'base': 'Green'},
    'Lime': {'color': Color(0xFFCDDC39), 'base': 'Green'},
    'Teal': {'color': Colors.teal, 'base': 'Green'},
    
    // Reds
    'Light Red': {'color': Color(0xFFE57373), 'base': 'Red'},
    'Red': {'color': Colors.red, 'base': 'Red'},
    'Dark Red': {'color': Color(0xFFC62828), 'base': 'Red'},
    
    // Pinks
    'Light Pink': {'color': Color(0xFFF48FB1), 'base': 'Pink'},
    'Pink': {'color': Colors.pink, 'base': 'Pink'},
    'Hot Pink': {'color': Color(0xFFE91E63), 'base': 'Pink'},
    
    // Purples
    'Lavender': {'color': Color(0xFFCE93D8), 'base': 'Purple'},
    'Purple': {'color': Color(0xFF9C27B0), 'base': 'Purple'},
    'Deep Purple': {'color': Color(0xFF6A1B9A), 'base': 'Purple'},
    
    // Yellows & Oranges
    'Yellow': {'color': Colors.yellow, 'base': 'Yellow'},
    'Orange': {'color': Colors.orange, 'base': 'Orange'},
    
    // Browns & Beiges
    'Beige': {'color': Color(0xFFD7CCC8), 'base': 'Brown'},
    'Brown': {'color': Colors.brown, 'base': 'Brown'},
  };

  /// Get base color name for analytics (e.g., "Light Blue" → "Blue")
  static String getBaseColorName(String colorName) {
    final mapping = colorMap[colorName];
    if (mapping != null) {
      return mapping['base'] as String;
    }
    // Fallback for old colors or unknown colors
    return colorName;
  }

  /// Get Color object from color name
  static Color? getColor(String colorName) {
    final mapping = colorMap[colorName];
    if (mapping != null) {
      return mapping['color'] as Color;
    }
    return null;
  }

  /// Get all available color names
  static List<String> getAllColorNames() {
    return colorMap.keys.toList();
  }

  /// Get all Color objects for picker
  static List<Color> getAllColors() {
    return colorMap.values.map((m) => m['color'] as Color).toList();
  }

  /// Find color name from Color object (for backward compatibility)
  static String? findColorName(Color color) {
    for (final entry in colorMap.entries) {
      if ((entry.value['color'] as Color).value == color.value) {
        return entry.key;
      }
    }
    return null;
  }
}
