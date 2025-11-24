// views/managerviews/manager_regularisation_detail_screen.dart
import 'package:attendanceapp/manager/models/regularisationmodels/manager_regularisation_model.dart';
import 'package:attendanceapp/manager/view_models/regularisationviewmodel/manager_regularisation_view_model.dart';
import 'package:attendanceapp/manager/widgets/fakewidgets/fakedashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/view_models/theme_view_model.dart';

class ManagerRegularisationDetailScreen extends StatefulWidget {
  final ManagerRegularisationRequest request;
  final ManagerRegularisationViewModel viewModel;

  const ManagerRegularisationDetailScreen({
    super.key,
    required this.request,
    required this.viewModel,
  });

  @override
  State<ManagerRegularisationDetailScreen> createState() =>
      _ManagerRegularisationDetailScreenState();
}

class _ManagerRegularisationDetailScreenState
    extends State<ManagerRegularisationDetailScreen> {
  final TextEditingController _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppTheme>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final employeeProjects = widget.viewModel.getEmployeeProjects(
      widget.request.employeeEmail,
    );

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        title: const Text('Request Details'),
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
                    _buildEmployeeSection(employeeProjects, isDarkMode),
                    const SizedBox(height: 5),

                    // Request Details & Time Comparison
                    _buildOverviewSection(isDarkMode),
                    const SizedBox(height: 5),

                    // Reason Section
                    _buildReasonSection(isDarkMode),
                    const SizedBox(height: 5),

                    // Manager Remarks
                    _buildRemarksSection(isDarkMode),
                  ],
                ),
              ),
            ),

            // Action Buttons
            if (widget.request.isPending) _buildActionButtons(isDarkMode),
          ],
        ),
      ),
    );
  }

  // ✅ SIMPLIFIED: Employee Section
  Widget _buildEmployeeSection(List<String> employeeProjects, bool isDarkMode) {
    return Container(
      // padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 12,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
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
                  color: _getProfileColor(widget.request.employeeName),
                  shape: BoxShape.circle,
                  image: widget.request.employeePhoto.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.request.employeePhoto),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.request.employeePhoto.isEmpty
                    ? Center(
                        child: Text(
                          _getInitials(widget.request.employeeName),
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
                      widget.request.employeeName,
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
                      widget.request.employeeRole,
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
                  color: widget.viewModel
                      .getStatusColor(widget.request.status)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.viewModel
                        .getStatusColor(widget.request.status)
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.viewModel.getStatusText(widget.request.status),
                  style: TextStyle(
                    color: widget.viewModel.getStatusColor(
                      widget.request.status,
                    ),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Project Info
          Row(
            children: [
              _buildInfoChip(
                Icons.work_outline,
                widget.request.projectName,
                AppColors.primary,
                isDarkMode,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.calendar_today,
                widget.request.formattedDate,
                AppColors.secondary,
                isDarkMode,
              ),
            ],
          ),

          // Assigned Projects
          if (employeeProjects.isNotEmpty &&
              employeeProjects.first != 'No Projects Assigned') ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  size: 16,
                  color: isDarkMode
                      ? AppColors.grey400
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? AppColors.textInverse
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: employeeProjects.take(4).map((project) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(
                      isDarkMode ? 0.15 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    project,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ SIMPLIFIED: Overview Section (Request Details + Time Comparison)
  Widget _buildOverviewSection(bool isDarkMode) {
    return Container(
      //padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
        // borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 12,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          // Request Type
          Row(
            children: [
              Icon(
                Icons.punch_clock,
                size: 18,
                color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Working Time:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                widget.viewModel.getTypeText(widget.request.type),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Time Comparison
          // Text(
          //   'Time Comparison',
          //   style: TextStyle(
          //     fontSize: 16,
          //     fontWeight: FontWeight.w700,
          //     color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
          //   ),
          // ),
          // const SizedBox(height: 16),
          Row(
            children: [
              // Expanded(
              //   child: _buildTimeComparisonItem(
              //     'Expected',
              //     '${_formatTime(widget.request.expectedCheckIn)} - ${_formatTime(widget.request.expectedCheckOut)}',
              //     Colors.green,
              //     isDarkMode,
              //   ),
              // ),
              // const SizedBox(width: 12),
              Expanded(
                child: _buildTimeComparisonItem(
                  'Punch IN - OUT',
                  '${_formatTime(widget.request.actualCheckIn)} - ${_formatTime(widget.request.actualCheckOut)}',
                  Colors.orange,
                  isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Shortfall Hrs',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.request.formattedShortfallTime,
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 16),
          //     const SizedBox(width: 12),

          //     // Shortfall Time
          //     Container(
          //       padding: const EdgeInsets.all(16),
          //       decoration: BoxDecoration(
          //         color: AppColors.error.withOpacity(isDarkMode ? 0.15 : 0.08),
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: Row(
          //         children: [
          //           Icon(Icons.timer, color: AppColors.error, size: 20),
          //           const SizedBox(width: 12),
          //           Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   'Shortfall Time',
          //                   style: TextStyle(
          //                     fontSize: 14,
          //                     color: isDarkMode
          //                         ? AppColors.textInverse
          //                         : AppColors.textPrimary,
          //                     fontWeight: FontWeight.w600,
          //                   ),
          //                 ),
          //                 Text(
          //                   widget.request.formattedShortfallTime,
          //                   style: TextStyle(
          //                     fontSize: 18,
          //                     color: AppColors.error,
          //                     fontWeight: FontWeight.w700,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
        ],
      ),
    );
  }

  // ✅ SIMPLIFIED: Reason Section
  Widget _buildReasonSection(bool isDarkMode) {
    return Container(
      // padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
        // borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 12,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
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
              widget.request.reason,
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

  // ✅ SIMPLIFIED: Remarks Section
  Widget _buildRemarksSection(bool isDarkMode) {
    return Container(
      // padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.transparent : Colors.white,
        //borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 12,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
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
            'Please provide detailed remarks for your decision (minimum 200 characters)',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _remarksController,
            maxLines: 5,
            style: TextStyle(
              color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your detailed remarks here...',
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
                return 'Remarks are required';
              }
              if (value.length < 200) {
                return 'Remarks must be at least 200 characters (${value.length}/200)';
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
                  color: _remarksController.text.length >= 200
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_remarksController.text.length}/200',
                  style: TextStyle(
                    color: _remarksController.text.length <= 200
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

  // ✅ IMPROVED: Action Buttons
  // Widget _buildActionButtons(bool isDarkMode) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: isDarkMode ? AppColors.surfaceDark : Colors.white,
  //       border: Border(
  //         top: BorderSide(
  //           color: isDarkMode ? AppColors.grey700 : AppColors.grey200,
  //         ),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: OutlinedButton.icon(
  //             onPressed: _isSubmitting ? null : () => _handleMoreInfo(),
  //             icon: Icon(Icons.help_outline, size: 18),
  //             label: Text('More Info'),
  //             style: OutlinedButton.styleFrom(
  //               foregroundColor: AppColors.warning,
  //               side: BorderSide(color: AppColors.warning),
  //               padding: const EdgeInsets.symmetric(vertical: 14),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: OutlinedButton.icon(
  //             onPressed: _isSubmitting ? null : () => _handleReject(),
  //             icon: Icon(Icons.close, size: 18),
  //             label: Text('Reject'),
  //             style: OutlinedButton.styleFrom(
  //               foregroundColor: AppColors.error,
  //               side: BorderSide(color: AppColors.error),
  //               padding: const EdgeInsets.symmetric(vertical: 14),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: ElevatedButton.icon(
  //             onPressed: _isSubmitting ? null : () => _handleApprove(),
  //             icon: Icon(Icons.check, size: 18),
  //             label: Text('Approve'),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.success,
  //               foregroundColor: Colors.white,
  //               padding: const EdgeInsets.symmetric(vertical: 14),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // ✅ OPTION 3: Complete solution with dynamic padding
  Widget _buildActionButtons(bool isDarkMode) {
    // Get bottom padding dynamically based on device
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        bottomPadding + 16,
      ), // ✅ Dynamic padding
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
              onPressed: _isSubmitting ? null : () => _handleReject(),
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
              onPressed: _isSubmitting ? null : () => _handleMoreInfo(),
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
              onPressed: _isSubmitting ? null : () => _handleApprove(),
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

  Widget _buildTimeComparisonItem(
    String title,
    String time,
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
            time,
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

  // Existing Helper Methods
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(TimeOfDay.fromDateTime(dateTime))}';
  }

  String _getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
  }

  Color _getProfileColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.secondary,
      AppColors.error,
    ];
    final index = name.hashCode % colors.length;
    return colors[index];
  }

  // Action Handlers
  Future<void> _handleApprove() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final success = await widget.viewModel.approveRequest(
      widget.request.id,
      _remarksController.text,
    );
    setState(() => _isSubmitting = false);
    if (success && mounted) {
      _showSuccessMessage('Request approved successfully');
      Navigator.pop(context);
    }
  }

  Future<void> _handleReject() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final success = await widget.viewModel.rejectRequest(
      widget.request.id,
      _remarksController.text,
    );
    setState(() => _isSubmitting = false);
    if (success && mounted) {
      _showSuccessMessage('Request rejected');
      Navigator.pop(context);
    }
  }

  Future<void> _handleMoreInfo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final success = await widget.viewModel.requestMoreInfo(
      widget.request.id,
      _remarksController.text,
    );
    setState(() => _isSubmitting = false);
    if (success && mounted) {
      _showSuccessMessage('More information requested');
      Navigator.pop(context);
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
}
