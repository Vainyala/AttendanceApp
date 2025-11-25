import 'package:AttendanceApp/employee/utils/app_colors.dart';
import 'package:flutter/material.dart';

class LeaveTypeDropdown extends StatelessWidget {
  final String selectedValue;
  final List<String> leaveTypes;
  final Function(String?)? onChanged; // Made nullable

  const LeaveTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.leaveTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;

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
              // Add gray background when disabled
              color: isEnabled ? Colors.transparent : AppColors.textHint.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.textHint.shade300,
                  width: 1,
                ),
              ),
            ),
            child: isEnabled
                ? DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: onChanged,
                items: leaveTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedValue,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textHint,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}