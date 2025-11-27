import 'dart:io';

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/leave_provider.dart';
import '../utils/app_styles.dart';
import '../utils/app_dimensions.dart';
import '../utils/leave_utils.dart';
import '../utils/leave_dialogs.dart';
import '../widgets/common/leaves_pie_chart.dart';
import '../widgets/custom_bars.dart';
import '../widgets/date_time_utils.dart';
import '../widgets/leaves_widgets/custom_card.dart';
import '../widgets/leaves_widgets/custome_date_time_fields.dart';
import '../widgets/leaves_widgets/half_day_checkbox.dart';
import '../widgets/leaves_widgets/leave_card_widget.dart';
import '../widgets/leaves_widgets/leave_details_card.dart';
import '../widgets/leaves_widgets/leave_type_dropdown.dart';
import '../widgets/submit_button.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showLeaveFormDialog(
      BuildContext context, {
        Map<String, dynamic>? leave,
        bool isDecrease = false,
      }) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

    if (leave != null) {
      provider.prefillFormForEdit(leave);
    } else {
      provider.resetForm();
    }

    final bool shouldDisableDates = isDecrease;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog( // ✅ dialogContext is the key
        shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMedium),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      leave == null
                          ? 'Apply For Leave'
                          : (isDecrease ? 'Decrease Leave Days' : 'Edit Leave'),
                      style: AppStyles.headingMedium.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        provider.resetForm();
                        Navigator.pop(dialogContext); // ✅ Use dialogContext
                      },
                      icon: const Icon(Icons.close, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<LeaveProvider>(
                  builder: (_, provider, __) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
                      child: _buildLeaveForm(
                        dialogContext, // ✅ Pass dialogContext here
                        provider,
                        leave,
                        shouldDisableDates,
                        isDecrease,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadLeave(
      BuildContext context,
      List<Map<String, dynamic>> leaves,
      ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textLight,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Text('Preparing download...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );

      final StringBuffer content = StringBuffer();
      content.writeln('LEAVE HISTORY REPORT');
      content.writeln('=' * 50);

      for (final leave in leaves) {
        content.writeln('=' * 40);
        content.writeln();
        content.writeln('\nLeave Type: ${leave['type']}');
        content.writeln('Status: ${leave['status']}');
        content.writeln();
        content.writeln(
          'From: ${DateFormat('dd MMM yyyy').format(leave['fromDate'])}',
        );
        content.writeln(
          'To: ${DateFormat('dd MMM yyyy').format(leave['toDate'])}',
        );
        content.writeln('Duration: ${leave['days']} days');
        content.writeln();
        content.writeln('Reason: ${leave['reason']}');
        content.writeln(
          'Applied On: ${DateFormat('dd MMM yyyy').format(leave['appliedOn'])}',
        );
        content.writeln('-' * 50);
      }

      final directory = await getTemporaryDirectory();
      final fileName =
          'leave_history_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(content.toString());

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Leave History Download');

      if (context.mounted) {
        LeaveUtils.showSuccessMessage(context, 'Leave history downloaded!');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildLeaveFilters(BuildContext context) {
    final provider = Provider.of<LeaveProvider>(context);

    return CustomCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.marginLarge,
        vertical: AppDimensions.marginSmall,
      ),
      padding: const EdgeInsets.all(AppDimensions.marginLarge),
      child: Column(
        children: [
          TextField(
            onChanged: provider.setSearchQuery,
            decoration: AppStyles.getInputDecoration(
              hintText: 'Search leaves...',
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textPrimary,
                size: AppDimensions.iconMedium,
              ),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  size: AppDimensions.iconMedium,
                ),
                onPressed: () => provider.setSearchQuery(''),
              )
                  : null,
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          _buildFilterChips(provider),
        ],
      ),
    );
  }

  Widget _buildFilterChips(LeaveProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: provider.statusFilters.map((status) {
          final isSelected = provider.filterStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (_) => provider.setFilterStatus(status),
              backgroundColor: AppColors.textHint,
              selectedColor: AppColors.primaryBlue,
              labelStyle: AppStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.textLight : AppColors.textPrimary,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppStyles.radiusXLarge,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeaveHistoryWithFilter(BuildContext context) {
    final provider = Provider.of<LeaveProvider>(context);

    if (provider.filteredLeaves.isEmpty) {
      return _buildEmptyState();
    }

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginLarge),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHistoryHeader(provider),
          _buildLeaveList(provider),
          if (!provider.showAllLeaves && provider.filteredLeaves.length > 2)
            _buildViewAllButton(provider, true),
          if (provider.showAllLeaves && provider.filteredLeaves.length > 2)
            _buildViewAllButton(provider, false),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: AppDimensions.iconXLarge,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          Text(
            'No leaves found',
            style: AppStyles.headingSmall.copyWith(color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader(LeaveProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leave History', style: AppStyles.headingMedium),
              const SizedBox(height: AppDimensions.paddingXSmall),
              Text(
                '${provider.filteredLeaves.length} leave${provider.filteredLeaves.length != 1 ? 's application' : ''}',
                style: AppStyles.bodySmall,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingXSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: AppStyles.radiusXLarge,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: AppDimensions.iconSmall,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: AppDimensions.paddingXSmall),
                    Text(
                      'Total: ${provider.totalLeaveDays} days',
                      style: AppStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: AppColors.textDark.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _downloadLeave(context, provider.filteredLeaves),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.download_rounded,
                      color: AppColors.textDark,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList(LeaveProvider provider) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.displayLeaves.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: AppColors.borderLight),
      itemBuilder: (context, index) {
        return _buildLeaveCard(context, provider.displayLeaves[index]);
      },
    );
  }

  Widget _buildViewAllButton(LeaveProvider provider, bool showAll) {
    return InkWell(
      onTap: () => provider.setShowAllLeaves(showAll),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.marginLarge),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              showAll
                  ? 'View All (${provider.filteredLeaves.length - 2} more)'
                  : 'Show Less',
              style: AppStyles.buttonTextMedium,
            ),
            const SizedBox(width: AppDimensions.paddingXSmall),
            Icon(
              showAll ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: AppColors.primaryBlue,
              size: AppDimensions.iconMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard(BuildContext context, Map<String, dynamic> leave) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

    final canEdit = provider.canEditLeave(leave);
    final canCancel = provider.canCancelLeave(leave);
    final canDecrease = provider.canDecreaseLeave(leave);

    return LeaveCardWidget(
      leave: leave,
      onView: () => _showLeaveDetails(context, leave),
      onEdit: canEdit
          ? () => _showLeaveFormDialog(context, leave: leave)
          : null,
      onCancel: canCancel ? () => _handleCancelLeave(context, leave) : null,
      onDecrease: canDecrease
          ? () => _showLeaveFormDialog(context, leave: leave, isDecrease: true)
          : null,
    );
  }

  void _handleCancelLeave(BuildContext context, Map<String, dynamic> leave) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    final isPartialCancel = provider.canCancelPartialLeave(leave);
    final remainingDays = isPartialCancel
        ? provider.getRemainingLeaveDays(leave)
        : 0;

    LeaveDialogs.showCancelLeaveDialog(
      context: context,
      isPartialCancel: isPartialCancel,
      remainingDays: remainingDays,
      onConfirm: () {
        provider.cancelLeave(leave['id'], isPartialCancel: isPartialCancel);
        LeaveUtils.showSuccessMessage(
          context,
          isPartialCancel
              ? 'Remaining $remainingDays day(s) cancelled successfully'
              : 'Leave cancelled successfully',
        );
      },
    );
  }

  void _showLeaveDetails(BuildContext context, Map<String, dynamic> leave) {
    showDialog(
      context: context,
      builder: (context) => LeaveDetailsCard(leave: leave),
    );
  }



  Widget _buildLeaveForm(
      BuildContext context,
      LeaveProvider provider,
      Map<String, dynamic>? leave,
      bool shouldDisableDates,  // ✅ Renamed from isEditMode
      bool isDecrease,
      ) {
    final formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDecrease)
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                margin: const EdgeInsets.only(
                  bottom: AppDimensions.marginMedium,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: AppStyles.radiusSmall,
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: Text(
                        'You can only decrease the end date for ongoing leaves',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildDateTimeFields(context, provider, shouldDisableDates),  // ✅ Pass correct param
            const SizedBox(height: AppDimensions.marginMedium),
            if (leave == null) _buildHalfDayCheckboxes(provider),  // ✅ Only show for new leaves
            if (leave == null)
              const SizedBox(height: AppDimensions.paddingXLarge),
            LeaveTypeDropdown(
              selectedValue: provider.selectedLeaveType,
              leaveTypes: provider.leaveTypes,
              onChanged: leave == null  // ✅ Only disable for new applications
                  ? (value) {
                if (value != null) provider.setSelectedLeaveType(value);
              }
                  : null,
            ),
            const SizedBox(height: AppDimensions.paddingXXLarge),
            _buildJustificationField(provider, leave != null),  // ✅ Disable justification when editing
            const SizedBox(height: 30),
            Consumer<LeaveProvider>(
              builder: (context, provider, _) {
                return SubmitButton(
                  onPressed: () async {
                    final isValid = formKey.currentState?.validate() ?? false;

                    // ✅ Additional time validation for same-day leaves
                    if (isValid && provider.fromDate.year == provider.toDate.year &&
                        provider.fromDate.month == provider.toDate.month &&
                        provider.fromDate.day == provider.toDate.day) {

                      final fromMinutes = provider.fromTime.hour * 60 + provider.fromTime.minute;
                      final toMinutes = provider.toTime.hour * 60 + provider.toTime.minute;

                      if (toMinutes <= fromMinutes) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('End time must be after start time for same-day leaves'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                    }

                    if (isValid) {
                      if (leave != null) {
                        await _updateLeave(context, leave['id']); // ✅ Using correct context
                      } else {
                        await _submitLeave(context); // ✅ Using correct context
                      }
                    }
                  },
                  isLoading: provider.isLoading,
                  text: leave != null ? 'Update' : 'Submit',
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _submitLeave(BuildContext dialogContext) async {
    print('🔵 Submit button pressed');

    final provider = Provider.of<LeaveProvider>(dialogContext, listen: false);

    print('🔵 Provider state:');
    print('   From Date: ${provider.fromDate}');
    print('   To Date: ${provider.toDate}');
    print('   Leave Type: ${provider.selectedLeaveType}');
    print('   Notes: ${provider.notesController.text}');

    await provider.submitLeave();

    print('🔵 Leave submitted successfully');

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext); // ✅ This will now close the dialog
      print('🔵 Leave submitted successfully.....');
      // Get the scaffold context for showing snackbar
      final scaffoldContext = Navigator.of(dialogContext).context;
      LeaveUtils.showSuccessMessage(
        scaffoldContext,
        'Leave application submitted successfully!',
      );
      provider.resetForm();
    }
  }

  Future<void> _updateLeave(BuildContext dialogContext, String leaveId) async {
    print('🔵 Update button pressed for leave: $leaveId');

    final provider = Provider.of<LeaveProvider>(dialogContext, listen: false);

    provider.updateLeave(
      leaveId,
      fromDate: provider.fromDate,
      toDate: provider.toDate,
      reason: provider.notesController.text,
    );

    print('🔵 Leave updated successfully');

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext); // ✅ This will now close the dialog

      final scaffoldContext = Navigator.of(dialogContext).context;
      LeaveUtils.showSuccessMessage(
        scaffoldContext,
        'Leave updated successfully!',
      );
      provider.resetForm();
    }
  }
  Widget _buildDateTimeFields(
      BuildContext context,
      LeaveProvider provider,
      bool shouldDisableDates,  // ✅ Renamed parameter
      ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomDateField(
                label: "From Date",
                value: provider.fromDateFormatted,
                onTap: shouldDisableDates ? null : () => provider.pickFromDate(context),  // ✅ Changed condition
              ),
            ),
            const SizedBox(width: AppDimensions.marginLarge),
            Expanded(
              child: CustomDateField(
                label: "To Date",
                value: provider.toDateFormatted,
                onTap: shouldDisableDates ? null : () => provider.pickToDate(context),  // ✅ Changed condition
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        Row(
          children: [
            Expanded(
              child: CustomTimeField(
                value: provider.fromTimeFormatted,
                onTap: shouldDisableDates ? null : () => provider.pickFromTime(context),  // ✅ Changed condition
              ),
            ),
            const SizedBox(width: AppDimensions.marginLarge),
            Expanded(
              child: CustomTimeField(
                value: provider.toTimeFormatted,
                onTap: shouldDisableDates ? null : () => provider.pickToTime(context),  // ✅ Changed condition
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHalfDayCheckboxes(LeaveProvider provider) {
    return Row(
      children: [
        Expanded(
          child: HalfDayCheckbox(
            value: provider.isHalfDayFrom,
            onChanged: (value) {
              provider.setIsHalfDayFrom(value ?? false);
              if (value == true) {
                provider.setFromTime(TimeOfDay(hour: 9, minute: 30));
                provider.setToTime(TimeOfDay(hour: 13, minute: 30));
              }
              provider.notifyListeners();
            },
          ),
        ),
        Expanded(
          child: HalfDayCheckbox(
            value: provider.isHalfDayTo,
            onChanged: (value) {
              provider.setIsHalfDayTo(value ?? false);
              if (value == true) {
                provider.setFromTime(TimeOfDay(hour: 13, minute: 30));
                provider.setToTime(TimeOfDay(hour: 18, minute: 30));
              }
              provider.notifyListeners();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildJustificationField(LeaveProvider provider, bool isEditMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Justification :', style: AppStyles.labelMedium),
        const SizedBox(height: AppDimensions.marginMedium),
        TextFormField(
          controller: provider.notesController,
          maxLines: 4,
          enabled: !isEditMode,
          style: AppStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter reason for leave...',
            hintStyle: AppStyles.hintText,
            filled: true,
            fillColor: isEditMode
                ? AppColors.textLight.withOpacity(0.5)
                : AppColors.textHint,
            border: OutlineInputBorder(
              borderRadius: AppStyles.radiusMedium,
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppStyles.radiusMedium,
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: AppDimensions.borderMedium,
              ),
            ),
            contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
          ),
          validator: (value) {
            // Skip validation in edit mode OR validate normally
            if (isEditMode) return null; // Don't validate when editing/viewing

            if (value == null || value.trim().isEmpty) {
              return 'Please enter a reason for leave';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveProvider>(  // ✅ Just use Consumer
      builder: (context, provider, child) {
        return ScreenWithBottomNav(
          currentIndex: 2,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Leaves', style: AppStyles.headingLarge),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textLight,
              elevation: 0,
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.primaryBlue,
              onPressed: () => _showLeaveFormDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          _buildLeaveFilters(context),
                          LeavePieChartWidget(data: provider.leaveTypeCount),
                          const SizedBox(height: AppDimensions.marginLarge),
                          _buildLeaveHistoryWithFilter(context),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXLarge,
        vertical: AppDimensions.marginLarge,
      ),
      color: AppColors.primaryBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Leaves',
            style: AppStyles.headingLarge.copyWith(
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}