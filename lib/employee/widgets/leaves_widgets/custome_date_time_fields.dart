import 'package:AttendanceApp/employee/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class CustomDateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData icon;

  const CustomDateField({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.icon = Icons.calendar_today,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.textHint.shade300, width: 1),
          ),
          // Add gray background when disabled
          color: onTap == null
              ? AppColors.textHint.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: onTap == null ? AppColors.textHint : AppColors.error,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: onTap == null
                          ? AppColors.textHint.withOpacity(0.7)
                          : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: onTap == null ? AppColors.textHint : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '–',
              style: TextStyle(fontSize: 18, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}


class CustomTimeField extends StatelessWidget {
  final String value;
  final VoidCallback? onTap;
  final IconData icon;

  const CustomTimeField({
    super.key,
    required this.value,
    this.onTap,
    this.icon = Icons.access_time,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.textHint.shade300,
              width: 1,
            ),
          ),
          // Add gray background when disabled
          color: onTap == null
              ? AppColors.textHint.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: onTap == null ? AppColors.textHint : AppColors.error,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: onTap == null ? AppColors.textHint : AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(
              '–',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
