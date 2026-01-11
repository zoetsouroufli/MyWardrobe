import 'package:flutter/material.dart';
import '../utils/color_mapping.dart';

class ColorPalettePicker extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;
  final Color selectedColor;

  const ColorPalettePicker({
    super.key,
    required this.onColorSelected,
    required this.selectedColor,
  });

  // Use ColorMapping for all available colors
  static final List<Color> _colors = ColorMapping.getAllColors();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Colors', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _colors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, // Increased to fit more colors
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final color = _colors[index];
              final isSelected = color == selectedColor;

              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.black12,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
