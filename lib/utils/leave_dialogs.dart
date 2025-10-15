import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/detail_row.dart';

class LeaveDialogs {
  // Edit Leave Confirmation Dialog
  static void showEditLeaveDialog({
    required BuildContext context,
    required bool isApproved,
    required int originalDays,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproved ? 'Edit Approved Leave' : 'Edit Leave'),
        content: Text(
          isApproved
              ? 'You can only decrease the number of days for an approved leave. '
              'Current days: $originalDays'
              : 'Do you want to Update your Details?',
        ),
        actions: [
          TextButton(
            onPressed: onCancel,
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // Cancel Leave Confirmation Dialog
  static void showCancelLeaveDialog({
    required BuildContext context,
    required bool isPartialCancel,
    required int remainingDays,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Leave'),
        content: Text(
          isPartialCancel
              ? 'You have $remainingDays remaining day(s) for this leave. '
              'Cancel the remaining days?'
              : 'Are you sure you want to cancel this leave application?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete Leave Confirmation Dialog
  static void showDeleteLeaveDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leave'),
        content: const Text(
          'Are you sure you want to permanently delete this leave? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );
  }

  // Leave Details Dialog
  static void showLeaveDetailsDialog({
    required BuildContext context,
    required Map<String, dynamic> leave,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(leave['type']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DetailRow(label: 'Status', value: leave['status']),
              DetailRow(
                label: 'From Date',
                value: DateFormat('dd MMM yyyy').format(leave['fromDate']),
              ),
              DetailRow(
                label: 'To Date',
                value: DateFormat('dd MMM yyyy').format(leave['toDate']),
              ),
              DetailRow(
                label: 'Duration',
                value: '${leave['days']} day${leave['days'] > 1 ? 's' : ''}',
              ),
              DetailRow(label: 'Reason', value: leave['reason']),
              DetailRow(
                label: 'Applied On',
                value: DateFormat('dd MMM yyyy').format(leave['appliedOn']),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}