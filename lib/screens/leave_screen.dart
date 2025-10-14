import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/leave_provider.dart';
import '../widgets/custom_bars.dart';
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
  final GlobalKey _formSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isFromDate) {
        provider.setFromDate(picked);
      } else {
        provider.setToDate(picked);
      }
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isFromTime) {
        provider.setFromTime(picked);
      } else {
        provider.setToTime(picked);
      }
    }
  }

  Widget _buildDayByDayLeaveView(BuildContext context,
      Map<String, dynamic> leave, LeaveProvider provider) {
    final fromDate = leave['fromDate'] as DateTime;
    final toDate = leave['toDate'] as DateTime;
    final days = toDate.difference(fromDate).inDays + 1;

    final daysList = List.generate(days, (index) {
      return fromDate.add(Duration(days: index));
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Leave Days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysList.length,
            itemBuilder: (context, index) {
              final date = daysList[index];
              final isHalfDay = leave['halfDays']?[DateFormat('yyyy-MM-dd')
                  .format(date)] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (isHalfDay)
                          const Text(
                            'Half Day',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => DayLeaveEditor(
                            leaveDate: date,
                            isHalfDay: isHalfDay,
                            onSave: (editedDate, halfDay) {
                              provider.updateLeaveDay(
                                leave['id'],
                                editedDate,
                                halfDay,
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final provider = Provider.of<LeaveProvider>(context);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: LegendItem(
                    color: entry.value['color'],
                    label: entry.key,
                    count: entry.value['count'],
                  )
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveFilters(BuildContext context) {
    final provider = Provider.of<LeaveProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => provider.setSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Search leaves...',
              hintStyle: const TextStyle(color: Colors.black, fontSize: 14),
              prefixIcon: const Icon(
                  Icons.search, color: Colors.black, size: 20),
              suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => provider.setSearchQuery(''),
              )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: provider.statusFilters.map((status) {
                final isSelected = provider.filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) => provider.setFilterStatus(status),
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: const Color(0xFF4A90E2),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight
                          .normal,
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF4A90E2) : Colors
                            .transparent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveHistoryWithFilter(BuildContext context) {
    final provider = Provider.of<LeaveProvider>(context);

    if (provider.filteredLeaves.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No leaves found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),

          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Leave History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.filteredLeaves.length} leave${provider
                          .filteredLeaves.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Total: ${provider.totalLeaveDays} days',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.displayLeaves.length,
            separatorBuilder: (context, index) =>
                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
            itemBuilder: (context, index) {
              final leave = provider.displayLeaves[index];
              return _buildLeaveCard(context, leave);
            },
          ),
          if (!provider.showAllLeaves && provider.filteredLeaves.length > 2)
            InkWell(
              onTap: () => provider.setShowAllLeaves(true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View All (${provider.filteredLeaves.length - 2} more)',
                      style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF4A90E2),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          if (provider.showAllLeaves && provider.filteredLeaves.length > 2)
            InkWell(
              onTap: () => provider.setShowAllLeaves(false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Show Less',
                      style: TextStyle(
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Color(0xFF4A90E2),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(BuildContext context, Map<String, dynamic> leave) {
    final provider = Provider.of<LeaveProvider>(context); // ADD THIS LINE

    Color statusColor;
    IconData statusIcon;

    switch (leave['status']) {
      case 'Approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
    }

    bool canEdit = leave['status'] != 'Rejected' &&
        provider.canEditOrDeleteLeave(leave);
    bool canCancelPartial = provider.canCancelPartialLeave(leave);
    bool canCancel = leave['status'] == 'Pending' || canCancelPartial;
    bool canOnlyView = leave['status'] == 'Rejected';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            leave['type'],
                            style: const TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: leave['status'])
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(
                          leave['fromDate'])} - ${DateFormat('dd MMM yyyy')
                          .format(leave['toDate'])}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${leave['days']} day${leave['days'] > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            leave['reason'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Applied on: ${DateFormat('dd MMM yyyy').format(
                    leave['appliedOn'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              if (canOnlyView) ...[
                TextButton(
                  onPressed: () => _showLeaveDetails(context, leave),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('View'),
                ),
              ] else
                ...[
                  if (canEdit)
                    TextButton(
                      onPressed: () => _showEditLeaveDialog(context, leave),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Edit'),
                    ),
                  if (canCancel)
                    TextButton(
                      onPressed: () =>
                          _showCancelConfirmation(context, leave['id']),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('Cancel'),
                    ),
                  if (!canCancel && !canOnlyView)
                    TextButton(
                      onPressed: () => _showLeaveDetails(context, leave),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('View'),
                    ),
                ],
            ],
          ),
        ],
      ),
    );
  }

  void _showEditLeaveDialog(BuildContext context,
      Map<String, dynamic> leave) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    bool isApproved = leave['status'] == 'Approved';
    int originalDays = leave['days'];

    provider.prefillFormForEdit(leave);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproved ? 'Edit Approved Leave' : 'Edit Leave'),
        content: Text(
          isApproved
              ? 'You can only decrease the number of days for an approved leave. '
              'Current days: $originalDays'
              : 'Do you want to Update you Details?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.resetForm();
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              int newDays = provider.toDate
                  .difference(provider.fromDate)
                  .inDays + 1;

              provider.updateLeave(
                leave['id'],
                fromDate: provider.fromDate,
                toDate: provider.toDate,
                reason: provider.notesController.text,
              );

              Navigator.pop(context);

              // Scroll to form section after closing dialog
              Future.delayed(const Duration(milliseconds: 300), () {
                _scrollToFormSection();
                _showFormUpdatedBanner(context);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isApproved
                      ? 'Leave updated successfully. You decreased days from '
                      '$originalDays to $newDays'
                      : 'Leave updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _scrollToFormSection() {
    final context = _formSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showFormUpdatedBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Form updated! Continue editing above or submit when ready.',
                style: TextStyle(color: Colors.white),
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
  void _showDeleteConfirmation(BuildContext context, String leaveId) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

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
              provider.cancelLeave(leaveId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Leave deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, String leaveId) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    // Get leave from provider data
    final leave = provider.allLeaves.firstWhere((l) => l['id'] == leaveId, orElse: () => {});

    final isPartialCancel = provider.canCancelPartialLeave(leave);
    final remainingDays = isPartialCancel
        ? provider.getRemainingLeaveDays(leave)
        : 0;

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
              provider.cancelLeave(leaveId, isPartialCancel: isPartialCancel);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isPartialCancel
                        ? 'Remaining $remainingDays day(s) cancelled successfully'
                        : 'Leave cancelled successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDetails(BuildContext context, Map<String, dynamic> leave) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(leave['type']),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DetailRow(
                    label: 'Status',
                    value: leave['status'],
                  ),
                  DetailRow(label:'From Date', value:
                      DateFormat('dd MMM yyyy').format(leave['fromDate'])),
                  DetailRow(label:'To Date',value:
                      DateFormat('dd MMM yyyy').format(leave['toDate'])),
                  DetailRow(label:'Duration',value:
                      '${leave['days']} day${leave['days'] > 1 ? 's' : ''}'),
                  DetailRow(label: 'Reason', value: leave['reason']),
                  DetailRow(label:'Applied On',value:
                      DateFormat('dd MMM yyyy').format(leave['appliedOn'])),
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
  Future<void> _submitLeave(BuildContext context) async {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

    await provider.submitLeave();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave application submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      provider.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaveProvider(),
      child: Consumer<LeaveProvider>(
        builder: (context, provider, child) {
          return ScreenWithBottomNav(
            currentIndex: 2,
            child: Scaffold(
              backgroundColor: Colors.grey.shade50,
              body: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      color: Colors.white,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Leaves',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Search and filters
                            _buildLeaveFilters(context),

                            // Pie Chart Card
                            Container(
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _buildPieChart(context),
                            ),

                            // Apply for Leave Form
                            _buildLeaveForm(context, provider),
                            const SizedBox(height: 16),

                            // Leave History
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

  Widget _buildLeaveForm(BuildContext context, LeaveProvider provider) {
    final formKey = GlobalKey<FormState>();
    final isFormFilled = provider.isFormPrefilled();

    return Container(
      key: _formSectionKey,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isFormFilled
            ? Border.all(
          color: const Color(0xFF4A90E2),
          width: 2,
        )
            : null,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Show this small info bar on top when editing mode is active
            if (isFormFilled)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF4A90E2), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Editing mode: Continue editing or submit to update',
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ Title and attach icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Apply/Edit For Leave',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.attachment,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ From / To date fields
            Row(
              children: [
                CustomDateField(
                  label: 'From Date',
                  value: DateFormattingUtils.formatDate(provider.fromDate),
                  onTap: () => _selectDate(context, true),
                ),
                const SizedBox(width: 16),
                CustomDateField(
                  label: 'To Date',
                  value: DateFormattingUtils.formatDate(provider.toDate),
                  onTap: () => _selectDate(context, false),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ From / To time fields
            Row(
              children: [
                CustomTimeField(
                  value: DateFormattingUtils.formatTime(provider.fromTime),
                  onTap: () => _selectTime(context, true),
                ),
                const SizedBox(width: 16),
                CustomTimeField(
                  value: DateFormattingUtils.formatTime(provider.toTime),
                  onTap: () => _selectTime(context, false),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ Half-day checkboxes
            Row(
              children: [
                Expanded(
                  child: HalfDayCheckbox(
                    value: provider.isHalfDayFrom,
                    onChanged: (value) =>
                        provider.setIsHalfDayFrom(value ?? false),
                  ),
                ),
                Expanded(
                  child: HalfDayCheckbox(
                    value: provider.isHalfDayTo,
                    onChanged: (value) =>
                        provider.setIsHalfDayTo(value ?? false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Leave type dropdown
            LeaveTypeDropdown(
              selectedValue: provider.selectedLeaveType,
              leaveTypes: provider.leaveTypes,
              onChanged: (value) {
                if (value != null) provider.setSelectedLeaveType(value);
              },
            ),

            const SizedBox(height: 24),

            // ✅ Justification field
            const Text(
              'Justification :',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: provider.notesController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter reason for leave...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A90E2),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a reason for leave';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            // ✅ Submit button
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
      ),
    );
  }

}