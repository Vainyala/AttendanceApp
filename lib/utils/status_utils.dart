import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class StatusUtils {
  static Color getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return AppColors.success;
      case "Rejected":
        return AppColors.error;
      case "Pending":
        return Colors.orange;
      case "Apply":
        return const Color(0xFF4A90E2);
      default:
        return Colors.blue;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Pending':
        return Icons.schedule;
      case 'Apply':
        return Icons.edit;
      default:
        return Icons.help;
    }
  }

  static Icon getStatusIconWidget(String status, {double size = 12}) {
    return Icon(
      getStatusIcon(status),
      size: size,
      color: AppColors.textLight,
    );
  }

  static Color getLeaveStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      default:
        return Colors.orange;
    }
  }

  static IconData getLeaveStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }
}