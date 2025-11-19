import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LeaveUtils {
  // Show Success Message
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show Error Message
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show Info Banner
  static void showInfoBanner(BuildContext context, String message, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? Icons.check_circle, color: AppColors.textLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.textLight),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4A90E2),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Get Status Color
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  // Get Status Icon
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Pending':
      default:
        return Icons.schedule;
    }
  }

  // Scroll to Widget
  static void scrollToWidget(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}