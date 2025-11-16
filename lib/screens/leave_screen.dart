import 'dart:io';

import 'package:AttendanceApp/utils/app_text.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// Providers
import '../providers/leave_provider.dart';

// Utils
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_dimensions.dart';
import '../utils/leave_utils.dart';
import '../utils/leave_dialogs.dart';

// Widgets
import '../widgets/custom_bars.dart';
import '../widgets/custom_card.dart';
import '../widgets/date_time_utils.dart';
import '../widgets/day_leave_edit.dart';
import '../widgets/detail_row.dart';
import '../widgets/half_day_checkbox.dart';
import '../widgets/leave_type_dropdown.dart';
import '../widgets/legend_item.dart';
import '../widgets/status_badge.dart';
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

  // ==================== SHOW LEAVE FORM DIALOG ====================
  void _showLeaveFormDialog(BuildContext context, {Map<String, dynamic>? leave}) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

    if (leave != null) {
      provider.prefillFormForEdit(leave);
    } else {
      provider.resetForm();
    }

    showDialog(
      context: context,
      barrierDismissible: false,  // Changed from isBarrierDismissible
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppStyles.radiusMedium,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
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
                      leave != null ? 'Edit Leave' : 'Apply For Leave',
                      style: AppStyles.headingMedium.copyWith(color: AppColors.textLight),
                    ),
                    IconButton(
                      onPressed: () {
                        provider.resetForm();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              // Dialog Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
                  child: _buildLeaveForm(context, provider, leave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DATE & TIME PICKERS ====================
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? provider.fromDate : provider.toDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      isFromDate ? provider.setFromDate(picked) : provider.setToDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime ? provider.fromTime : provider.toTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      isFromTime ? provider.setFromTime(picked) : provider.setToTime(picked);
    }
  }

  // ==================== PIE CHART ====================
  Widget _buildPieChart(BuildContext context) {
    final provider = Provider.of<LeaveProvider>(context);

    return CustomCard(
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: SizedBox(
        height: AppDimensions.chartHeight,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  sections: provider.leaveBalance.entries.map((entry) {
                    return PieChartSectionData(
                      color: entry.value['color'],
                      value: entry.value['count'].toDouble(),
                      title: '',
                      radius: 80,
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: provider.leaveBalance.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXSmall),
                    child: LegendItem(
                      color: entry.value['color'],
                      label: entry.key,
                      count: entry.value['count'],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DOWNLOAD LEAVE ====================

  Future<void> _downloadLeave(BuildContext context, Map<String, dynamic> leave) async {
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLight),
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
      content.writeln('LEAVE APPLICATION');
      content.writeln('=' * 40);
      content.writeln();
      content.writeln('Leave Type: ${leave['type']}');
      content.writeln('Status: ${leave['status']}');
      content.writeln();
      content.writeln('From Date: ${DateFormat('dd MMM yyyy').format(leave['fromDate'])}');
      content.writeln('To Date: ${DateFormat('dd MMM yyyy').format(leave['toDate'])}');
      content.writeln('Duration: ${leave['days']} day${leave['days'] > 1 ? 's' : ''}');
      content.writeln();
      content.writeln('Reason:');
      content.writeln(leave['reason']);
      content.writeln();
      content.writeln('Applied On: ${DateFormat('dd MMM yyyy').format(leave['appliedOn'])}');
      content.writeln('=' * 40);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'leave_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';
      final file = File('${directory.path}/$fileName');

      // Write content to file
      await file.writeAsString(content.toString());

      // Share/download the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Leave Application - ${leave['type']}',
      );

      if (context.mounted) {
        LeaveUtils.showSuccessMessage(
          context,
          'Leave downloaded successfully!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading leave: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ==================== FILTERS ====================
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
              prefixIcon: Icon(Icons.search, color: AppColors.textPrimary, size: AppDimensions.iconMedium),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: AppDimensions.iconMedium),
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
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== LEAVE HISTORY ====================
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
                '${provider.filteredLeaves.length} leave${provider.filteredLeaves.length != 1 ? 's' : ''}',
                style: AppStyles.bodySmall,
              ),
            ],
          ),
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
        ],
      ),
    );
  }

  Widget _buildLeaveList(LeaveProvider provider) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.displayLeaves.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight),
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

  // ==================== LEAVE CARD ====================
  Widget _buildLeaveCard(BuildContext context, Map<String, dynamic> leave) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

    final canEdit = leave['status'] != 'Rejected' && provider.canEditOrDeleteLeave(leave);
    final canCancelPartial = provider.canCancelPartialLeave(leave);
    final canCancel = leave['status'] == 'Pending' || canCancelPartial;
    final canOnlyView = leave['status'] == 'Rejected';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.marginLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeaveCardHeader(leave),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            leave['reason'],
            style: AppStyles.bodyMedium.copyWith(color: AppColors.textHint),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          _buildLeaveCardFooter(context, leave, canEdit, canCancel, canOnlyView),
        ],
      ),
    );
  }

  Widget _buildLeaveCardHeader(Map<String, dynamic> leave) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: AppDimensions.paddingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: AppStyles.radiusSmall,
                    ),
                    child: Text(
                      leave['type'],
                      style: AppStyles.chipText.copyWith(color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingSmall),
                  StatusBadge(status: leave['status']),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                '${DateFormat('dd MMM yyyy').format(leave['fromDate'])} - '
                    '${DateFormat('dd MMM yyyy').format(leave['toDate'])}',
                style: AppStyles.bodyLarge,
              ),
              const SizedBox(height: AppDimensions.paddingXSmall),
              Text(
                '${leave['days']} day${leave['days'] > 1 ? 's' : ''}',
                style: AppStyles.bodySmall,
              ),
            ],
          ),
        ),
        // Download Icon Button
        IconButton(
          onPressed: () => _downloadLeave(context, leave),
          icon: Icon(
            Icons.download_rounded,
            color: AppColors.primaryBlue,
            size: AppDimensions.iconMedium,
          ),
          tooltip: 'Download Leave',
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildLeaveCardFooter(
      BuildContext context,
      Map<String, dynamic> leave,
      bool canEdit,
      bool canCancel,
      bool canOnlyView,
      ) {
    return Row(
      children: [
        Text(
          'Applied on: ${DateFormat('dd MMM yyyy').format(leave['appliedOn'])}',
          style: AppStyles.caption,
        ),
        const Spacer(),
        if (canOnlyView)
          _buildActionButton('View', AppColors.primaryBlue, () => _showLeaveDetails(context, leave)),
        if (!canOnlyView) ...[
          if (canEdit)
            _buildActionButton('Edit', AppColors.primaryBlue, () => _showLeaveFormDialog(context, leave: leave)),
          if (canCancel)
            _buildActionButton('Cancel', AppColors.error, () => _handleCancelLeave(context, leave)),
          if (!canCancel)
            _buildActionButton('View', AppColors.primaryBlue, () => _showLeaveDetails(context, leave)),
        ],
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
        minimumSize: const Size(0, AppDimensions.buttonHeightSmall),
      ),
      child: Text(label),
    );
  }

  // ==================== LEAVE ACTIONS ====================
  void _handleCancelLeave(BuildContext context, Map<String, dynamic> leave) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    final isPartialCancel = provider.canCancelPartialLeave(leave);
    final remainingDays = isPartialCancel ? provider.getRemainingLeaveDays(leave) : 0;

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
    LeaveDialogs.showLeaveDetailsDialog(context: context, leave: leave);
  }

  Future<void> _submitLeave(BuildContext context) async {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    await provider.submitLeave();

    if (context.mounted) {
      LeaveUtils.showSuccessMessage(context, 'Leave application submitted successfully!');
      provider.resetForm();
      Navigator.pop(context); // Close the dialog
    }
  }

  // ==================== LEAVE FORM ====================
  Widget _buildLeaveForm(BuildContext context, LeaveProvider provider, Map<String, dynamic>? leave) {
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimeFields(context, provider),
          const SizedBox(height: AppDimensions.marginMedium),
          _buildHalfDayCheckboxes(provider),
          const SizedBox(height: AppDimensions.paddingXLarge),
          LeaveTypeDropdown(
            selectedValue: provider.selectedLeaveType,
            leaveTypes: provider.leaveTypes,
            onChanged: (value) {
              if (value != null) provider.setSelectedLeaveType(value);
            },
          ),
          const SizedBox(height: AppDimensions.paddingXXLarge),
          _buildJustificationField(provider),
          const SizedBox(height: 30),
          SubmitButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _submitLeave(context);
              }
            },
            isLoading: provider.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeFields(BuildContext context, LeaveProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            CustomDateField(
              label: 'From Date',
              value: DateFormattingUtils.formatDate(provider.fromDate),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(width: AppDimensions.marginLarge),
            CustomDateField(
              label: 'To Date',
              value: DateFormattingUtils.formatDate(provider.toDate),
              onTap: () => _selectDate(context, false),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.marginMedium),
        Row(
          children: [
            CustomTimeField(
              value: DateFormattingUtils.formatTime(provider.fromTime),
              onTap: () => _selectTime(context, true),
            ),
            const SizedBox(width: AppDimensions.marginLarge),
            CustomTimeField(
              value: DateFormattingUtils.formatTime(provider.toTime),
              onTap: () => _selectTime(context, false),
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
            onChanged: (value) => provider.setIsHalfDayFrom(value ?? false),
          ),
        ),
        Expanded(
          child: HalfDayCheckbox(
            value: provider.isHalfDayTo,
            onChanged: (value) => provider.setIsHalfDayTo(value ?? false),
          ),
        ),
      ],
    );
  }

  Widget _buildJustificationField(LeaveProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Justification :', style: AppStyles.labelMedium),
        const SizedBox(height: AppDimensions.marginMedium),
        TextFormField(
          controller: provider.notesController,
          maxLines: 4,
          style: AppStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter reason for leave...',
            hintStyle: AppStyles.hintText,
            filled: true,
            fillColor: AppColors.textHint,
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
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a reason for leave';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ==================== ADD LEAVE BUTTON ====================
  Widget _buildAddLeaveButton(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginLarge),
      child: InkWell(
        onTap: () => _showLeaveFormDialog(context),
        borderRadius: AppStyles.radiusMedium,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.textLight,
                  size: AppDimensions.iconMedium,
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Text(
                'Add Leave',
                style: AppStyles.headingMedium.copyWith(color: AppColors.primaryBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaveProvider(),
      child: Consumer<LeaveProvider>(
        builder: (context, provider, child) {
          return ScreenWithBottomNav(
            currentIndex: 2,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            _buildLeaveFilters(context),
                            _buildPieChart(context),
                            const SizedBox(height: AppDimensions.marginLarge),
                            _buildAddLeaveButton(context),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingXLarge,
        vertical: AppDimensions.marginLarge,
      ),
      color: AppColors.textLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Leaves', style: AppStyles.headingLarge),
        ],
      ),
    );
  }
}