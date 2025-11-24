// views/leave_detail_screen.dart
import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/models/leavemodels/leave_model.dart';
import 'package:attendanceapp/manager/view_models/leaveviewmodels/leave_view_model.dart';
import 'package:attendanceapp/manager/widgets/fakewidgets/fakedashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaveDetailScreen extends StatefulWidget {
  final LeaveApplication application;
  final VoidCallback onStatusUpdated;

  const LeaveDetailScreen({
    super.key,
    required this.application,
    required this.onStatusUpdated,
  });

  @override
  State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
  final TextEditingController _commentsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill comments if manager remarks already exist
    if (widget.application.managerRemarks != null &&
        widget.application.managerRemarks!.isNotEmpty) {
      _commentsController.text = widget.application.managerRemarks!;
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        title: const Text('Leave Request Details'),
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            MonthlyOverviewWidget(isDarkMode: isDarkMode),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Employee Information
                    _buildEmployeeSection(isDarkMode),
                    const SizedBox(height: 5),

                    // Leave Details & Duration
                    _buildOverviewSection(isDarkMode),
                    const SizedBox(height: 5),

                    // Handover Details
                    // _buildHandoverSection(isDarkMode),
                    // const SizedBox(height: 5),

                    // Reason Section
                    _buildReasonSection(isDarkMode),
                    const SizedBox(height: 5),

                    // Previous Manager Comments (if any)
                    _buildCommentsSection(isDarkMode),
                    if (widget.application.status == LeaveStatus.pending ||
                        widget.application.status == LeaveStatus.query)
                      const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Action Buttons
            if (widget.application.status == LeaveStatus.pending ||
                widget.application.status == LeaveStatus.query)
              _buildActionButtons(isDarkMode),
          ],
        ),
      ),
    );
  }

  // ✅ SIMPLIFIED: Employee Section (Regularisation Style)
  Widget _buildEmployeeSection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Employee Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getColorFromName(widget.application.employeeName),
                  shape: BoxShape.circle,
                  image: widget.application.employeePhoto.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.application.employeePhoto),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.application.employeePhoto.isEmpty
                    ? Center(
                        child: Text(
                          _getInitials(widget.application.employeeName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.application.employeeName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.application.employeeRole,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? AppColors.grey400
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    widget.application.status,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(
                      widget.application.status,
                    ).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.application.statusString.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(widget.application.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Project and Contact Info
          // Row(
          //   children: [
          //     _buildInfoChip(
          //       Icons.work_outline,
          //       widget.application.projectName,
          //       AppColors.primary,
          //       isDarkMode,
          //     ),
          //     const SizedBox(width: 8),
          //     _buildInfoChip(
          //       Icons.calendar_today,
          //       widget.application.formattedDates.split(' - ').first,
          //       AppColors.secondary,
          //       isDarkMode,
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 12),

          // // Contact Information
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildContactInfo(
          //         Icons.email,
          //         widget.application.employeeEmail,
          //         isDarkMode,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildContactInfo(
          //         Icons.phone,
          //         widget.application.employeePhone,
          //         isDarkMode,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  // ✅ SIMPLIFIED: Overview Section (Leave Details + Duration)
  Widget _buildOverviewSection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
      ),
      child: Column(
        children: [
          // Leave Type and Duration
          Row(
            children: [
              Icon(
                Icons.beach_access,
                size: 18,
                color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Leave Details:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                widget.application.leaveTypeString,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Duration and Total Days
          Row(
            children: [
              Expanded(
                child: _buildLeaveDetailItem(
                  'Duration',
                  widget.application.duration,
                  Colors.orange,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLeaveDetailItem(
                  'Total Days',
                  '${widget.application.totalDays} days',
                  Colors.green,
                  isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Applied Date
          if (widget.application.appliedDateTime.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(isDarkMode ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applied On',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? AppColors.textInverse
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.application.appliedDateTime,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ✅ SIMPLIFIED: Handover Section
  Widget _buildHandoverSection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Handover Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getColorFromName(
                    widget.application.handoverPersonName,
                  ),
                  shape: BoxShape.circle,
                  image: widget.application.handoverPersonPhoto.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            widget.application.handoverPersonPhoto,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.application.handoverPersonPhoto.isEmpty
                    ? Center(
                        child: Text(
                          _getInitials(widget.application.handoverPersonName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.application.handoverPersonName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '📧 ${widget.application.handoverPersonEmail}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? AppColors.grey400
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '📞 ${widget.application.handoverPersonPhone}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? AppColors.grey400
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ SIMPLIFIED: Reason Section
  Widget _buildReasonSection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Reason',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.grey800 : AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.application.reason,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.grey300 : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // // ✅ SIMPLIFIED: Previous Comments Section
  // Widget _buildPreviousCommentsSection(bool isDarkMode) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: isDarkMode ? Colors.transparent : Colors.white,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.history,
  //               size: 18,
  //               color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
  //             ),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Remarked *',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w700,
  //                 color: isDarkMode
  //                     ? AppColors.textInverse
  //                     : AppColors.textPrimary,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Container(
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: isDarkMode ? AppColors.grey800 : AppColors.grey50,
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(
  //               color: isDarkMode ? AppColors.grey700 : AppColors.grey300,
  //             ),
  //           ),
  //           child: Text(
  //             widget.application.managerRemarks!,
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: isDarkMode ? AppColors.grey300 : AppColors.textSecondary,
  //               height: 1.5,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // ✅ SIMPLIFIED: Comments Section
  // Widget _buildCommentsSection(bool isDarkMode) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: isDarkMode ? Colors.transparent : Colors.white,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.edit_note,
  //               size: 18,
  //               color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
  //             ),
  //             const SizedBox(width: 8),
  //             Text(
  //               'Remark *',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w700,
  //                 color: isDarkMode
  //                     ? AppColors.textInverse
  //                     : AppColors.textPrimary,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           'Please provide detailed comments for your decision (minimum 200 characters)',
  //           style: TextStyle(
  //             fontSize: 13,
  //             color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         TextFormField(
  //           controller: _commentsController,
  //           maxLines: 5,
  //           style: TextStyle(
  //             color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
  //           ),
  //           decoration: InputDecoration(
  //             hintText: 'Enter your detailed comments here...',
  //             hintStyle: TextStyle(
  //               color: isDarkMode ? AppColors.grey500 : AppColors.textDisabled,
  //             ),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               borderSide: BorderSide.none,
  //             ),
  //             filled: true,
  //             fillColor: isDarkMode ? AppColors.grey800 : AppColors.grey50,
  //             contentPadding: const EdgeInsets.all(16),
  //           ),
  //           validator: (value) {
  //             if (value == null || value.isEmpty) {
  //               return 'Comments are required';
  //             }
  //             if (value.length < 200) {
  //               return 'Comments must be at least 200 characters (${value.length}/200)';
  //             }
  //             return null;
  //           },
  //           onChanged: (value) => setState(() {}),
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Minimum 200 characters required',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 color: isDarkMode
  //                     ? AppColors.grey500
  //                     : AppColors.textDisabled,
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: _commentsController.text.length >= 200
  //                     ? AppColors.success.withOpacity(0.1)
  //                     : AppColors.warning.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //               child: Text(
  //                 '${_commentsController.text.length}/200',
  //                 style: TextStyle(
  //                   color: _commentsController.text.length >= 200
  //                       ? AppColors.success
  //                       : AppColors.warning,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ✅ SIMPLIFIED: Previous Comments Section - ONLY SHOW IF REMARKS EXIST
  Widget _buildPreviousCommentsSection(bool isDarkMode) {
    // Condition check karo - sirf tabhi show karo jab remarks hain
    if (widget.application.managerRemarks == null ||
        widget.application.managerRemarks!.isEmpty) {
      return const SizedBox.shrink(); // Empty widget return karo
    }

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Previous Remarks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.grey800 : AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppColors.grey700 : AppColors.grey300,
              ),
            ),
            child: Text(
              widget.application.managerRemarks!,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.grey300 : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ SIMPLIFIED: Comments Section - ONLY SHOW FOR PENDING/QUERY APPLICATIONS
  Widget _buildCommentsSection(bool isDarkMode) {
    // Condition check karo - sirf pending/query applications ke liye
    if (widget.application.status != LeaveStatus.pending &&
        widget.application.status != LeaveStatus.query) {
      return const SizedBox.shrink(); // Empty widget return karo
    }

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note,
                size: 18,
                color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Remarks *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide detailed comments for your decision (minimum 200 characters)',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            // controller: _commentsController,
            maxLines: 5,
            style: TextStyle(
              color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your detailed comments here...',
              hintStyle: TextStyle(
                color: isDarkMode ? AppColors.grey500 : AppColors.textDisabled,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode ? AppColors.grey800 : AppColors.grey50,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Comments are required';
              }
              if (value.length < 200) {
                return 'Comments must be at least 200 characters (${value.length}/200)';
              }
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum 200 characters required',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? AppColors.grey500
                      : AppColors.textDisabled,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _commentsController.text.length >= 200
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_commentsController.text.length}/200',
                  style: TextStyle(
                    color: _commentsController.text.length >= 200
                        ? AppColors.success
                        : AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ IMPROVED: Action Buttons (Regularisation Style)
  Widget _buildActionButtons(bool isDarkMode) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.grey700 : AppColors.grey200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () => _handleAction(LeaveStatus.rejected),
              icon: Icon(Icons.close, size: 18),
              label: Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () => _handleAction(LeaveStatus.query),
              icon: Icon(Icons.help_outline, size: 18),
              label: Text('Query'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () => _handleAction(LeaveStatus.approved),
              icon: Icon(Icons.check, size: 18),
              label: Text('Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.grey800 : AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? AppColors.grey300 : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveDetailItem(
    String title,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Action Handler
  Future<void> _handleAction(LeaveStatus status) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill manager comments with minimum 200 characters',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final viewModel = context.read<LeaveViewModel>();
    final success = await viewModel.updateLeaveStatus(
      widget.application.id!,
      status,
      _commentsController.text,
      'Manager User',
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _showSuccessMessage(
        'Leave application ${status.toString().split('.').last} successfully',
      );
      widget.onStatusUpdated();
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update leave status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Existing Helper Methods
  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.query:
        return Colors.orange;
      case LeaveStatus.cancelled:
        return Colors.grey;
      case LeaveStatus.pending:
      default:
        return Colors.blue;
    }
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final index = name.length % colors.length;
    return colors[index];
  }

  String _getInitials(String name) {
    return name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }
}

// // views/leave_detail_screen.dart
// import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/manager/models/leavemodels/leave_model.dart';
// import 'package:attendanceapp/manager/view_models/leaveviewmodels/leave_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class LeaveDetailScreen extends StatefulWidget {
//   final LeaveApplication application;
//   final VoidCallback onStatusUpdated;

//   const LeaveDetailScreen({
//     super.key,
//     required this.application,
//     required this.onStatusUpdated,
//   });

//   @override
//   State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
// }

// class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
//   final TextEditingController _commentsController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill comments if manager remarks already exist
//     if (widget.application.managerRemarks != null &&
//         widget.application.managerRemarks!.isNotEmpty) {
//       _commentsController.text = widget.application.managerRemarks!;
//     }
//   }

//   @override
//   void dispose() {
//     _commentsController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final isDarkMode = theme.isDarkMode;

//     // Color definitions based on theme
//     final textColor = isDarkMode ? AppColors.white : AppColors.textPrimary;
//     final secondaryTextColor = isDarkMode
//         ? AppColors.white.withOpacity(0.8)
//         : AppColors.textSecondary;
//     final backgroundColor = isDarkMode
//         ? AppColors.backgroundDark
//         : AppColors.backgroundLight;
//     final surfaceColor = isDarkMode
//         ? AppColors.surfaceDark
//         : AppColors.surfaceLight;
//     final borderColor = isDarkMode ? AppColors.grey700 : AppColors.grey300;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         title: Text(
//           'Leave Application Details',
//           style: TextStyle(color: textColor),
//         ),
//         backgroundColor: surfaceColor,
//         elevation: 1,
//         iconTheme: IconThemeData(color: textColor),
//         actions: [
//           if (widget.application.status != LeaveStatus.pending)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: _getStatusColor(
//                   widget.application.status,
//                 ).withOpacity(isDarkMode ? 0.2 : 0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: _getStatusColor(
//                     widget.application.status,
//                   ).withOpacity(isDarkMode ? 0.4 : 0.3),
//                 ),
//               ),
//               child: Text(
//                 widget.application.statusString.toUpperCase(),
//                 style: TextStyle(
//                   color: _getStatusColor(widget.application.status),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Employee Information Card
//             _buildEmployeeInfoCard(
//               isDarkMode,
//               surfaceColor,
//               textColor,
//               secondaryTextColor,
//             ),
//             const SizedBox(height: 16),

//             // Leave Details Card
//             _buildLeaveDetailsCard(
//               isDarkMode,
//               surfaceColor,
//               textColor,
//               secondaryTextColor,
//             ),
//             const SizedBox(height: 16),

//             // Handover Details Card
//             _buildHandoverDetailsCard(
//               isDarkMode,
//               surfaceColor,
//               textColor,
//               secondaryTextColor,
//             ),
//             const SizedBox(height: 16),

//             // Reason Card
//             _buildReasonCard(
//               isDarkMode,
//               surfaceColor,
//               textColor,
//               secondaryTextColor,
//             ),
//             const SizedBox(height: 16),

//             // Previous Manager Comments (if any)
//             if (widget.application.managerRemarks != null &&
//                 widget.application.managerRemarks!.isNotEmpty)
//               _buildPreviousCommentsCard(
//                 isDarkMode,
//                 surfaceColor,
//                 textColor,
//                 secondaryTextColor,
//               ),

//             // Manager Comments Form (only for pending/query applications)
//             if (widget.application.status == LeaveStatus.pending ||
//                 widget.application.status == LeaveStatus.query)
//               _buildManagerCommentsForm(
//                 isDarkMode,
//                 surfaceColor,
//                 textColor,
//                 secondaryTextColor,
//                 borderColor,
//               ),

//             const SizedBox(height: 20),

//             // Action Buttons (only for pending/query applications)
//             if (widget.application.status == LeaveStatus.pending ||
//                 widget.application.status == LeaveStatus.query)
//               _buildActionButtons(isDarkMode),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmployeeInfoCard(
//     bool isDarkMode,
//     Color surfaceColor,
//     Color textColor,
//     Color secondaryTextColor,
//   ) {
//     return Card(
//       elevation: 2,
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Employee Information',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: _getColorFromName(
//                     widget.application.employeeName,
//                   ),
//                   child: widget.application.employeePhoto.isNotEmpty
//                       ? CircleAvatar(
//                           radius: 28,
//                           backgroundImage: NetworkImage(
//                             widget.application.employeePhoto,
//                           ),
//                         )
//                       : Text(
//                           _getInitials(widget.application.employeeName),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.application.employeeName,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: textColor,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'ID: ${widget.application.employeeId}',
//                         style: TextStyle(color: secondaryTextColor),
//                       ),
//                       Text(
//                         'Role: ${widget.application.employeeRole}',
//                         style: TextStyle(color: secondaryTextColor),
//                       ),
//                       Text(
//                         'Project: ${widget.application.projectName}',
//                         style: TextStyle(color: secondaryTextColor),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '📧 ${widget.application.employeeEmail}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: secondaryTextColor,
//                         ),
//                       ),
//                       Text(
//                         '📞 ${widget.application.employeePhone}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: secondaryTextColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLeaveDetailsCard(
//     bool isDarkMode,
//     Color surfaceColor,
//     Color textColor,
//     Color secondaryTextColor,
//   ) {
//     return Card(
//       elevation: 2,
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Leave Details',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildDetailRow(
//               'Leave Type',
//               widget.application.leaveTypeString,
//               isDarkMode: isDarkMode,
//               textColor: textColor,
//               secondaryTextColor: secondaryTextColor,
//             ),
//             _buildDetailRow(
//               'Duration',
//               widget.application.duration,
//               isDarkMode: isDarkMode,
//               textColor: textColor,
//               secondaryTextColor: secondaryTextColor,
//             ),
//             _buildDetailRow(
//               'Total Days',
//               '${widget.application.totalDays} days',
//               isDarkMode: isDarkMode,
//               textColor: textColor,
//               secondaryTextColor: secondaryTextColor,
//             ),
//             _buildDetailRow(
//               'Date Range',
//               widget.application.formattedDates,
//               isDarkMode: isDarkMode,
//               textColor: textColor,
//               secondaryTextColor: secondaryTextColor,
//             ),
//             _buildDetailRow(
//               'Applied On',
//               widget.application.appliedDateTime,
//               isDarkMode: isDarkMode,
//               textColor: textColor,
//               secondaryTextColor: secondaryTextColor,
//             ),
//             if (widget.application.approvedBy != null)
//               _buildDetailRow(
//                 'Approved By',
//                 widget.application.approvedBy!,
//                 isDarkMode: isDarkMode,
//                 textColor: textColor,
//                 secondaryTextColor: secondaryTextColor,
//               ),
//             if (widget.application.approvedDate != null)
//               _buildDetailRow(
//                 'Approved On',
//                 '${widget.application.approvedDate!.day}/${widget.application.approvedDate!.month}/${widget.application.approvedDate!.year}',
//                 isDarkMode: isDarkMode,
//                 textColor: textColor,
//                 secondaryTextColor: secondaryTextColor,
//               ),
//             _buildDetailRow(
//               'Status',
//               widget.application.statusString.toUpperCase(),
//               isDarkMode: isDarkMode,
//               textColor: textColor,
//               secondaryTextColor: secondaryTextColor,
//               valueColor: _getStatusColor(widget.application.status),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHandoverDetailsCard(
//     bool isDarkMode,
//     Color surfaceColor,
//     Color textColor,
//     Color secondaryTextColor,
//   ) {
//     return Card(
//       elevation: 2,
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Contact & Handover Details',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: _getColorFromName(
//                     widget.application.handoverPersonName,
//                   ),
//                   child: widget.application.handoverPersonPhoto.isNotEmpty
//                       ? CircleAvatar(
//                           radius: 18,
//                           backgroundImage: NetworkImage(
//                             widget.application.handoverPersonPhoto,
//                           ),
//                         )
//                       : Text(
//                           _getInitials(widget.application.handoverPersonName),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.application.handoverPersonName,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: textColor,
//                         ),
//                       ),
//                       Text(
//                         '📧 ${widget.application.handoverPersonEmail}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: secondaryTextColor,
//                         ),
//                       ),
//                       Text(
//                         '📞 ${widget.application.handoverPersonPhone}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: secondaryTextColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             _buildDetailRow(
//               'Employee Contact',
//               widget.application.contactNumber,
//               isDarkMode: isDarkMode,
//               textColor: textColor,
//               secondaryTextColor: secondaryTextColor,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReasonCard(
//     bool isDarkMode,
//     Color surfaceColor,
//     Color textColor,
//     Color secondaryTextColor,
//   ) {
//     return Card(
//       elevation: 2,
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Reason for Leave',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               widget.application.reason,
//               style: TextStyle(fontSize: 14, height: 1.5, color: textColor),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPreviousCommentsCard(
//     bool isDarkMode,
//     Color surfaceColor,
//     Color textColor,
//     Color secondaryTextColor,
//   ) {
//     return Card(
//       elevation: 2,
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Previous Manager Comments',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isDarkMode
//                     ? AppColors.surfaceVariantDark
//                     : AppColors.grey50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: isDarkMode ? AppColors.grey700 : AppColors.grey300,
//                 ),
//               ),
//               child: Text(
//                 widget.application.managerRemarks!,
//                 style: TextStyle(fontSize: 14, height: 1.5, color: textColor),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildManagerCommentsForm(
//     bool isDarkMode,
//     Color surfaceColor,
//     Color textColor,
//     Color secondaryTextColor,
//     Color borderColor,
//   ) {
//     return Card(
//       elevation: 2,
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Manager Comments *',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Minimum 200 characters required',
//                 style: TextStyle(fontSize: 12, color: secondaryTextColor),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _commentsController,
//                 maxLines: 6,
//                 style: TextStyle(color: textColor),
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: borderColor),
//                   ),
//                   hintText: 'Enter your comments (minimum 200 characters)...',
//                   hintStyle: TextStyle(color: secondaryTextColor),
//                   alignLabelWithHint: true,
//                   filled: isDarkMode,
//                   fillColor: isDarkMode ? AppColors.surfaceVariantDark : null,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Comments are required';
//                   }
//                   if (value.length < 200) {
//                     return 'Minimum 200 characters required (${value.length}/200)';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {}); // For real-time validation
//                 },
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Text(
//                     'Characters: ${_commentsController.text.length}/200',
//                     style: TextStyle(
//                       color: _commentsController.text.length >= 200
//                           ? AppColors.success
//                           : AppColors.warning,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const Spacer(),
//                   if (_commentsController.text.length >= 200)
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.check_circle,
//                           color: AppColors.success,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Minimum requirement met',
//                           style: TextStyle(
//                             color: AppColors.success,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(bool isDarkMode) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => _handleAction(LeaveStatus.query),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: AppColors.warning,
//                   side: BorderSide(color: AppColors.warning),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   backgroundColor: isDarkMode
//                       ? AppColors.warning.withOpacity(0.1)
//                       : null,
//                 ),
//                 child: const Text('Request More Info'),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => _handleAction(LeaveStatus.rejected),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: AppColors.error,
//                   side: BorderSide(color: AppColors.error),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   backgroundColor: isDarkMode
//                       ? AppColors.error.withOpacity(0.1)
//                       : null,
//                 ),
//                 child: const Text('Reject'),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _handleAction(LeaveStatus.approved),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.success,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: const Text('Approve'),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         if (widget.application.status == LeaveStatus.query)
//           Text(
//             'This application requires additional information',
//             style: TextStyle(
//               color: AppColors.warning,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//       ],
//     );
//   }

//   Widget _buildDetailRow(
//     String label,
//     String value, {
//     required bool isDarkMode,
//     required Color textColor,
//     required Color secondaryTextColor,
//     Color? valueColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: secondaryTextColor,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: valueColor ?? textColor,
//                 fontWeight: valueColor != null
//                     ? FontWeight.w600
//                     : FontWeight.w400,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _handleAction(LeaveStatus status) async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please fill manager comments with minimum 200 characters',
//           ),
//           backgroundColor: AppColors.warning,
//         ),
//       );
//       return;
//     }

//     final viewModel = context.read<LeaveViewModel>();
//     final success = await viewModel.updateLeaveStatus(
//       widget.application.id!,
//       status,
//       _commentsController.text,
//       'Manager User',
//     );

//     if (success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Leave application ${status.toString().split('.').last} successfully',
//           ),
//           backgroundColor: AppColors.success,
//         ),
//       );
//       widget.onStatusUpdated();
//       Navigator.of(context).pop();
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to update leave status'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }

//   Color _getStatusColor(LeaveStatus status) {
//     switch (status) {
//       case LeaveStatus.approved:
//         return Colors.green;
//       case LeaveStatus.rejected:
//         return Colors.red;
//       case LeaveStatus.query:
//         return Colors.orange;
//       case LeaveStatus.cancelled:
//         return Colors.grey;
//       case LeaveStatus.pending:
//       default:
//         return Colors.blue;
//     }
//   }

//   Color _getColorFromName(String name) {
//     final colors = [
//       Colors.blue,
//       Colors.green,
//       Colors.orange,
//       Colors.purple,
//       Colors.red,
//       Colors.teal,
//     ];
//     final index = name.length % colors.length;
//     return colors[index];
//   }

//   String _getInitials(String name) {
//     return name
//         .split(' ')
//         .map((e) => e.isNotEmpty ? e[0] : '')
//         .take(2)
//         .join()
//         .toUpperCase();
//   }
// }

// // views/leave_detail_screen.dart
// import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/manager/models/leavemodels/leave_model.dart';
// import 'package:attendanceapp/manager/view_models/leaveviewmodels/leave_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class LeaveDetailScreen extends StatefulWidget {
//   final LeaveApplication application;
//   final VoidCallback onStatusUpdated;

//   const LeaveDetailScreen({
//     super.key,
//     required this.application,
//     required this.onStatusUpdated,
//   });

//   @override
//   State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
// }

// class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
//   final TextEditingController _commentsController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill comments if manager remarks already exist
//     if (widget.application.managerRemarks != null &&
//         widget.application.managerRemarks!.isNotEmpty) {
//       _commentsController.text = widget.application.managerRemarks!;
//     }
//   }

//   @override
//   void dispose() {
//     _commentsController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leave Application Details'),
//         backgroundColor: AppColors.grey300,
//         elevation: 0,
//         actions: [
//           if (widget.application.status != LeaveStatus.pending)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: _getStatusColor(
//                   widget.application.status,
//                 ).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 widget.application.statusString.toUpperCase(),
//                 style: TextStyle(
//                   color: _getStatusColor(widget.application.status),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Employee Information Card
//             _buildEmployeeInfoCard(),
//             const SizedBox(height: 16),

//             // Leave Details Card
//             _buildLeaveDetailsCard(),
//             const SizedBox(height: 16),

//             // Handover Details Card
//             _buildHandoverDetailsCard(),
//             const SizedBox(height: 16),

//             // Reason Card
//             _buildReasonCard(),
//             const SizedBox(height: 16),

//             // Previous Manager Comments (if any)
//             if (widget.application.managerRemarks != null &&
//                 widget.application.managerRemarks!.isNotEmpty)
//               _buildPreviousCommentsCard(),

//             // Manager Comments Form (only for pending/query applications)
//             if (widget.application.status == LeaveStatus.pending ||
//                 widget.application.status == LeaveStatus.query)
//               _buildManagerCommentsForm(),

//             const SizedBox(height: 20),

//             // Action Buttons (only for pending/query applications)
//             if (widget.application.status == LeaveStatus.pending ||
//                 widget.application.status == LeaveStatus.query)
//               _buildActionButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmployeeInfoCard() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Employee Information',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: _getColorFromName(
//                     widget.application.employeeName,
//                   ),
//                   child: widget.application.employeePhoto.isNotEmpty
//                       ? CircleAvatar(
//                           radius: 28,
//                           backgroundImage: NetworkImage(
//                             widget.application.employeePhoto,
//                           ),
//                         )
//                       : Text(
//                           _getInitials(widget.application.employeeName),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.application.employeeName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'ID: ${widget.application.employeeId}',
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                       Text(
//                         'Role: ${widget.application.employeeRole}',
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                       Text(
//                         'Project: ${widget.application.projectName}', // Changed from project to projectName
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '📧 ${widget.application.employeeEmail}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       Text(
//                         '📞 ${widget.application.employeePhone}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLeaveDetailsCard() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Leave Details',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),
//             _buildDetailRow(
//               'Leave Type',
//               widget.application.leaveTypeString,
//             ), // Changed to leaveTypeString
//             _buildDetailRow('Duration', widget.application.duration),
//             _buildDetailRow(
//               'Total Days',
//               '${widget.application.totalDays} days',
//             ),
//             _buildDetailRow('Date Range', widget.application.formattedDates),
//             _buildDetailRow('Applied On', widget.application.appliedDateTime),
//             if (widget.application.approvedBy != null)
//               _buildDetailRow('Approved By', widget.application.approvedBy!),
//             if (widget.application.approvedDate != null)
//               _buildDetailRow(
//                 'Approved On',
//                 '${widget.application.approvedDate!.day}/${widget.application.approvedDate!.month}/${widget.application.approvedDate!.year}',
//               ),
//             _buildDetailRow(
//               'Status',
//               widget.application.statusString
//                   .toUpperCase(), // Changed to statusString
//               valueColor: _getStatusColor(widget.application.status),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHandoverDetailsCard() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Contact & Handover Details',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: _getColorFromName(
//                     widget.application.handoverPersonName,
//                   ),
//                   child: widget.application.handoverPersonPhoto.isNotEmpty
//                       ? CircleAvatar(
//                           radius: 18,
//                           backgroundImage: NetworkImage(
//                             widget.application.handoverPersonPhoto,
//                           ),
//                         )
//                       : Text(
//                           _getInitials(widget.application.handoverPersonName),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.application.handoverPersonName,
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                       Text(
//                         '📧 ${widget.application.handoverPersonEmail}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       Text(
//                         '📞 ${widget.application.handoverPersonPhone}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             _buildDetailRow(
//               'Employee Contact',
//               widget.application.contactNumber,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReasonCard() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Reason for Leave',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               widget.application.reason,
//               style: const TextStyle(fontSize: 14, height: 1.5),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPreviousCommentsCard() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Previous Manager Comments',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Text(
//                 widget.application.managerRemarks!,
//                 style: const TextStyle(fontSize: 14, height: 1.5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildManagerCommentsForm() {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Manager Comments *',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Minimum 200 characters required',
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _commentsController,
//                 maxLines: 6,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: 'Enter your comments (minimum 200 characters)...',
//                   alignLabelWithHint: true,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Comments are required';
//                   }
//                   if (value.length < 200) {
//                     return 'Minimum 200 characters required (${value.length}/200)';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   setState(() {}); // For real-time validation
//                 },
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Text(
//                     'Characters: ${_commentsController.text.length}/200',
//                     style: TextStyle(
//                       color: _commentsController.text.length >= 200
//                           ? Colors.green
//                           : Colors.orange,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const Spacer(),
//                   if (_commentsController.text.length >= 200)
//                     const Row(
//                       children: [
//                         Icon(Icons.check_circle, color: Colors.green, size: 16),
//                         SizedBox(width: 4),
//                         Text(
//                           'Minimum requirement met',
//                           style: TextStyle(color: Colors.green, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => _handleAction(LeaveStatus.query),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.orange,
//                   side: const BorderSide(color: Colors.orange),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: const Text('Request More Info'),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => _handleAction(LeaveStatus.rejected),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.red,
//                   side: const BorderSide(color: Colors.red),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: const Text('Reject'),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _handleAction(LeaveStatus.approved),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: const Text(
//                   'Approve',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         if (widget.application.status == LeaveStatus.query)
//           Text(
//             'This application requires additional information',
//             style: TextStyle(
//               color: Colors.orange.shade700,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//       ],
//     );
//   }

//   Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: valueColor ?? Colors.black87,
//                 fontWeight: valueColor != null
//                     ? FontWeight.w600
//                     : FontWeight.w400,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _handleAction(LeaveStatus status) async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please fill manager comments with minimum 200 characters',
//           ),
//         ),
//       );
//       return;
//     }

//     final viewModel = context.read<LeaveViewModel>();
//     final success = await viewModel.updateLeaveStatus(
//       widget.application.id!,
//       status,
//       _commentsController.text,
//       'Manager User', // You can replace this with actual manager name
//     );

//     if (success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Leave application ${status.toString().split('.').last} successfully',
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );
//       widget.onStatusUpdated();
//       Navigator.of(context).pop();
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to update leave status'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Color _getStatusColor(LeaveStatus status) {
//     switch (status) {
//       case LeaveStatus.approved:
//         return Colors.green;
//       case LeaveStatus.rejected:
//         return Colors.red;
//       case LeaveStatus.query:
//         return Colors.orange;
//       case LeaveStatus.cancelled:
//         return Colors.grey;
//       case LeaveStatus.pending:
//       default:
//         return Colors.blue;
//     }
//   }

//   Color _getColorFromName(String name) {
//     final colors = [
//       Colors.blue,
//       Colors.green,
//       Colors.orange,
//       Colors.purple,
//       Colors.red,
//       Colors.teal,
//     ];
//     final index = name.length % colors.length;
//     return colors[index];
//   }

//   String _getInitials(String name) {
//     return name
//         .split(' ')
//         .map((e) => e.isNotEmpty ? e[0] : '')
//         .take(2)
//         .join()
//         .toUpperCase();
//   }
// }
