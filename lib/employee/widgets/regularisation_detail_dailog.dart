import 'package:AttendanceApp/employee/models/attendance_model.dart';
import 'package:AttendanceApp/employee/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/app_helpers.dart';
import '../utils/app_styles.dart';
import '../widgets/date_time_utils.dart';

class RegularisationDetailDialog extends StatefulWidget {
  final String dateStr;
  final DateTime actualDate;
  final String projectName;
  final List<AttendanceModel> projectRecords;
  final String status;
  final bool isEditable;
  final Function(String, String, TimeOfDay, String, DateTime) onSubmit;

  const RegularisationDetailDialog({
    super.key,
    required this.dateStr,
    required this.actualDate,
    required this.projectName,
    required this.projectRecords,
    required this.status,
    required this.isEditable,
    required this.onSubmit,
  });

  @override
  State<RegularisationDetailDialog> createState() =>
      _RegularisationDetailDialogState();
}

class _RegularisationDetailDialogState
    extends State<RegularisationDetailDialog> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late TextEditingController justificationController;

  @override
  void initState() {
    super.initState();
    final checkOut = widget.projectRecords.lastWhere(
          (r) => r.type == AttendanceType.checkOut,
      orElse: () => widget.projectRecords.last,
    );
    selectedDate = checkOut.timestamp;
    selectedTime = TimeOfDay.fromDateTime(checkOut.timestamp);
    justificationController = TextEditingController();
  }

  @override
  void dispose() {
    justificationController.dispose();
    super.dispose();
  }

  String _getManagerComment(String status) {
    if (status == 'Pending') {
      return 'Your request is under review by the manager.';
    } else if (status == 'Rejected') {
      return 'Insufficient justification provided. Please provide more details about the reason for late check-out.';
    } else if (status == 'Approved') {
      return 'Request approved successfully. Your attendance hours have been regularized.';
    }
    return '';
  }

  Widget _summaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppStyles.text)),
          Text(value, style: AppStyles.heading, maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildManagerCommentSection(String status, String comment) {
    Color bgColor, borderColor, iconColor, textColor;

    if (status == 'Approved') {
      bgColor = AppColors.success.shade50;
      borderColor = AppColors.success.shade200;
      iconColor = AppColors.success.shade700;
      textColor = AppColors.success.shade900;
    } else if (status == 'Rejected') {
      bgColor = AppColors.error.shade50;
      borderColor = AppColors.error.shade200;
      iconColor = AppColors.error.shade700;
      textColor = AppColors.error.shade900;
    } else {
      bgColor = AppColors.warning.shade50;
      borderColor = AppColors.warning.shade200;
      iconColor = AppColors.warning.shade700;
      textColor = AppColors.warning.shade900;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status == 'Approved'
                    ? Icons.check_circle
                    : status == 'Rejected'
                    ? Icons.cancel
                    : Icons.info,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Manager Comment',
                style: AppStyles.heading.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: AppStyles.text.copyWith(height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submittedDate = DateFormat('dd MMM yyyy').format(selectedDate);
    final submittedTime = selectedTime.format(context);
    final checkIn = widget.projectRecords.firstWhere(
          (r) => r.type == AttendanceType.checkIn,
      orElse: () => widget.projectRecords.first,
    );
    final checkOut = widget.projectRecords.lastWhere(
          (r) => r.type == AttendanceType.checkOut,
      orElse: () => widget.projectRecords.last,
    );
    final managerComment = _getManagerComment(widget.status);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const Icon(Icons.edit_calendar,
                      color: AppColors.primaryBlue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isEditable
                          ? 'Regularization Request'
                          : 'Request Details',
                      style: AppStyles.headingLarge,
                    ),
                  ),
                  StatusBadge(status: widget.status, fontSize: 11),
                ],
              ),

              const SizedBox(height: 24),

              // ATTENDANCE SUMMARY CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Attendance Summary", style: AppStyles.heading),
                    const SizedBox(height: 12),
                    _summaryRow("Date", widget.dateStr, Icons.calendar_today),
                    _summaryRow(
                        "Project", widget.projectName, Icons.folder_open),
                    _summaryRow(
                      "Check-in",
                      DateFormat('hh:mm a').format(checkIn.timestamp),
                      Icons.login,
                    ),
                    _summaryRow(
                      "Check-out",
                      DateFormat('hh:mm a').format(checkOut.timestamp),
                      Icons.logout,
                    ),
                    _summaryRow(
                      "Worked Hours",
                      AppHelpers.formatDuration(
                        checkOut.timestamp.difference(checkIn.timestamp),
                      ),
                      Icons.access_time,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // EDITABLE SECTION (Justification + Time)
              if (widget.isEditable) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Shortfall Time", style: AppStyles.heading),
                      const SizedBox(height: 12),
                      InkWell(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule,
                                  color: AppColors.primaryBlue),
                              const SizedBox(width: 12),
                              Text(selectedTime.format(context),
                                  style: AppStyles.heading),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text("Justification *", style: AppStyles.heading),
                      const SizedBox(height: 8),
                      TextField(
                        controller: justificationController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Explain the reason...',
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.grey300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // NON-EDITABLE SECTION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryRow(
                        "Submitted Date",
                        widget.dateStr,
                        Icons.schedule,
                      ),

                      _summaryRow(
                        "Submitted Time",
                        submittedTime,
                        Icons.schedule,
                      ),
                      const SizedBox(height: 12),
                      Text("Justification", style: AppStyles.heading),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Text(
                          'Forgot to check out. Was working till late.',
                          style: AppStyles.text.copyWith(height: 1.5),
                        ),
                      )
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // MANAGER COMMENT
              if (widget.status != 'Apply')
                _buildManagerCommentSection(widget.status, managerComment),

              const SizedBox(height: 24),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close", style: AppStyles.textMedium),
                    ),
                  ),
                  if (widget.isEditable) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (justificationController.text.trim().isEmpty) {
                            AppHelpers.showErrorSnackbar(
                              context,
                              'Please provide justification',
                            );
                            return;
                          }
                          widget.onSubmit(
                            widget.dateStr,
                            widget.projectName,
                            selectedTime,
                            justificationController.text.trim(),
                            widget.actualDate,
                          );
                          Navigator.pop(context);
                        },
                        child: Text("Submit Request",
                            style: AppStyles.textMedium),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}