import 'package:flutter/material.dart';

class ClothingPropertyRow extends StatelessWidget {
  final String label;
  final String value;
  final String? secondaryValue;
  final bool isColor;
  final bool hasCounter;

  const ClothingPropertyRow({
    super.key,
    required this.label,
    required this.value,
    this.secondaryValue,
    this.isColor = false,
    this.hasCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(label),
          const Spacer(),

          if (isColor) ...[
            _Pill(text: value),
            const SizedBox(width: 8),
            if (secondaryValue != null) _Pill(text: secondaryValue!),
          ] else if (hasCounter) ...[
            _Counter(value: value),
          ] else
            _Pill(text: value),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}

class _Counter extends StatelessWidget {
  final String value;
  const _Counter({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {},
        ),
        Text(value),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {},
        ),
      ],
    );
  }
}
