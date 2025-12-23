import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;

  const BottomNav({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _icon(Icons.group, 0),
          _icon(Icons.tune, 1),
          _icon(Icons.favorite, 2),
          _icon(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selectedIndex == index ? Colors.purple.shade100 : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}
