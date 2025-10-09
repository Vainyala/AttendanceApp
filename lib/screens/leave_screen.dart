import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/leave_provider.dart';
import '../services/custom_bars.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

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

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString()
        .padLeft(2, '0')}';
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
                  child: _buildLegendItem(
                    entry.value['color'],
                    entry.key,
                    entry.value['count'],
                  ),
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

    bool canEdit = leave['status'] == 'Pending' ||
        leave['status'] == 'Approved';
    bool canCancel = leave['status'] == 'Pending';
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                leave['status'],
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  void _showEditLeaveDialog(BuildContext context, Map<String, dynamic> leave) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);
    bool isApproved = leave['status'] == 'Approved';
    int originalDays = leave['days'];

    provider.prefillFormForEdit(leave);

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(isApproved ? 'Edit Approved Leave' : 'Edit Leave'),
            content: Text(
              isApproved
                  ? 'You can only decrease the number of days for an approved leave. Current days: $originalDays'
                  : 'Update your leave details below and submit the form.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  provider.resetForm();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isApproved
                          ? 'Leave updated successfully. You decreased days from $originalDays to $newDays'
                          : 'Leave updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showCancelConfirmation(BuildContext context, String leaveId) {
    final provider = Provider.of<LeaveProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Cancel Leave'),
            content: const Text(
                'Are you sure you want to cancel this leave application?'),
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
                      content: Text('Leave cancelled successfully'),
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
                  _buildDetailRow('Status', leave['status']),
                  _buildDetailRow('From Date',
                      DateFormat('dd MMM yyyy').format(leave['fromDate'])),
                  _buildDetailRow('To Date',
                      DateFormat('dd MMM yyyy').format(leave['toDate'])),
                  _buildDetailRow('Duration',
                      '${leave['days']} day${leave['days'] > 1 ? 's' : ''}'),
                  _buildDetailRow('Reason', leave['reason']),
                  _buildDetailRow('Applied On',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '$count $label',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.red, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '–',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.red, size: 18),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Text(
                '–',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHalfDayCheckbox(bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Half Day',
          style: TextStyle(fontSize: 14),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4A90E2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
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
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16),
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
                              child: _buildLeaveForm(context, provider),
                            ),
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

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Apply For Leave',
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

          // Date Fields Row
          Row(
            children: [
              _buildDateField(
                label: 'From Date',
                value: _formatDate(provider.fromDate),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(width: 16),
              _buildDateField(
                label: 'To Date',
                value: _formatDate(provider.toDate),
                onTap: () => _selectDate(context, false),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Time Fields Row
          Row(
            children: [
              _buildTimeField(
                value: _formatTime(provider.fromTime),
                onTap: () => _selectTime(context, true),
              ),
              const SizedBox(width: 16),
              _buildTimeField(
                value: _formatTime(provider.toTime),
                onTap: () => _selectTime(context, false),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Half Day Checkboxes
          Row(
            children: [
              Expanded(
                child: _buildHalfDayCheckbox(
                  provider.isHalfDayFrom,
                      (value) => provider.setIsHalfDayFrom(value ?? false),
                ),
              ),
              Expanded(
                child: _buildHalfDayCheckbox(
                  provider.isHalfDayTo,
                      (value) => provider.setIsHalfDayTo(value ?? false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Leave Type Dropdown
          Row(
            children: [
              const Text(
                'Leave Type :-',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.selectedLeaveType,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: provider.leaveTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(fontSize: 15),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          provider.setSelectedLeaveType(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Notes Field
          const Text(
            'Notes :',
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
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
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
              if (value == null || value
                  .trim()
                  .isEmpty) {
                return 'Please enter a reason for leave';
              }
              return null;
            },
          ),

          const SizedBox(height: 30),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () {
                if (formKey.currentState!.validate()) {
                  _submitLeave(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: provider.isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}