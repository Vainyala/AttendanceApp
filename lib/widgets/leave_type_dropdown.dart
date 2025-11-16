import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LeaveTypeDropdown extends StatelessWidget {
  final String selectedValue;
  final List<String> leaveTypes;
  final Function(String?) onChanged;

  const LeaveTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.leaveTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Leave Type :-',
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.textHint.shade300,
                  width: 1,
                ),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: leaveTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
