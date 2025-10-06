import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/leave_model.dart';
import '../services/custom_bars.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  TimeOfDay _fromTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _toTime = const TimeOfDay(hour: 17, minute: 0);
  String _selectedLeaveType = 'Casual Leave';
  bool _isHalfDayFrom = false;
  bool _isHalfDayTo = false;
  bool _isLoading = false;

  // Leave balance data
  final Map<String, dynamic> _leaveBalance = {
    'Carry Forward': {'count': 3, 'color': const Color(0xFF4CAF50)},
    'Eligible': {'count': 6, 'color': const Color(0xFF2196F3)},
    'Availed': {'count': 2, 'color': const Color(0xFFF44336)},
    'Balance': {'count': 4, 'color': const Color(0xFFFFEB3B)},
  };

  final List<String> _leaveTypes = [
    'Casual Leave',
    'Sick Leave',
    'Annual Leave',
    'Emergency Leave',
    'Maternity Leave',
    'Paternity Leave',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
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
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
          if (_toDate.isBefore(_fromDate)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime ? _fromTime : _toTime,
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
      setState(() {
        if (isFromTime) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPieChart() {
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
                sections: _leaveBalance.entries.map((entry) {
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
              children: _leaveBalance.entries.map((entry) {
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

  Future<void> _submitLeave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final leave = LeaveModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id',
        fromDate: _fromDate,
        toDate: _toDate,
        fromTime: _fromTime,
        toTime: _toTime,
        leaveType: _selectedLeaveType,
        notes: _notesController.text,
        isHalfDayFrom: _isHalfDayFrom,
        isHalfDayTo: _isHalfDayTo,
        appliedDate: DateTime.now(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave application submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _resetForm();
      }
    }
  }

  void _resetForm() {
    _notesController.clear();
    setState(() {
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      _fromTime = const TimeOfDay(hour: 9, minute: 30);
      _toTime = const TimeOfDay(hour: 17, minute: 0);
      _selectedLeaveType = 'Casual Leave';
      _isHalfDayFrom = false;
      _isHalfDayTo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Leaves',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Pie Chart Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildPieChart(),
                      ),

                      // Apply for Leave Form
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
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
                                    value: _formatDate(_fromDate),
                                    onTap: () => _selectDate(context, true),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildDateField(
                                    label: 'To Date',
                                    value: _formatDate(_toDate),
                                    onTap: () => _selectDate(context, false),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Time Fields Row
                              Row(
                                children: [
                                  _buildTimeField(
                                    value: _formatTime(_fromTime),
                                    onTap: () => _selectTime(context, true),
                                  ),
                                  const SizedBox(width: 16),
                                  _buildTimeField(
                                    value: _formatTime(_toTime),
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
                                      _isHalfDayFrom,
                                          (value) => setState(() => _isHalfDayFrom = value ?? false),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildHalfDayCheckbox(
                                      _isHalfDayTo,
                                          (value) => setState(() => _isHalfDayTo = value ?? false),
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
                                          value: _selectedLeaveType,
                                          isExpanded: true,
                                          icon: const Icon(Icons.arrow_drop_down),
                                          items: _leaveTypes.map((String type) {
                                            return DropdownMenuItem<String>(
                                              value: type,
                                              child: Text(
                                                type,
                                                style: const TextStyle(fontSize: 15),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedLeaveType = newValue!;
                                            });
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
                                controller: _notesController,
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
                                  if (value == null || value.trim().isEmpty) {
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
                                  onPressed: _isLoading ? null : _submitLeave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
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
                        ),
                      ),

                      const SizedBox(height: 100), // Space for bottom navigation
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}