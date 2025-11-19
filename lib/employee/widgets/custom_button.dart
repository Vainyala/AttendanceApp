import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
        ),
      )
          : Icon(icon, color: AppColors.textLight),
      label: Text(
        loading ? '$text...' : text,
        style: const TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: AppColors.textHint.shade400,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }
}
