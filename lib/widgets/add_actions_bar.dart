import 'package:flutter/material.dart';

class AddActionsBar extends StatelessWidget {
  const AddActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(text: 'Add to outfit'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(text: 'Add to new outfit'),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  const _ActionButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
