import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class HalfDayCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String label;

  const HalfDayCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Half Day',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4A90E2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
