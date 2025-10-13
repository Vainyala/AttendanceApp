import 'package:flutter/material.dart';

class CustomStatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;

  const CustomStatRow({
    super.key,
    required this.label,
    required this.value,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isGood ? Colors.green.shade100 : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isGood ? Icons.thumb_up : Icons.warning,
                color: isGood ? Colors.green.shade700 : Colors.orange.shade700,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                isGood ? 'GOOD' : 'IMPROVE',
                style: TextStyle(
                  color: isGood ? Colors.green.shade700 : Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}