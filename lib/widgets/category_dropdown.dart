import 'package:flutter/material.dart';

class CategoryDropdownTile extends StatelessWidget {
  final String title;

  const CategoryDropdownTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurpleAccent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: title,
          items: [
            DropdownMenuItem(value: title, child: Text(title)),
          ],
          onChanged: (_) {},
          icon: const Icon(Icons.expand_more),
        ),
      ),
    );
  }
}
