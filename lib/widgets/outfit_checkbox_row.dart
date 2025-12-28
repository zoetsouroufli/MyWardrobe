import 'package:flutter/material.dart';

class OutfitCheckboxRow extends StatelessWidget {
  final String title;

  const OutfitCheckboxRow({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Checkbox(
            value: false,
            onChanged: null,
          ),
        ],
      ),
    );
  }
}
