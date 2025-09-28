import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/leave_model.dart';
import '../services/custom_bottom_nav_bar.dart';


// Leave Screen
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

  // Sample leave balance data
  final Map<String, int> _leaveBalance = {
    'Carry Forward': 3,
    'Eligible': 6,
    'Availed': 2,
    'Balance': 4,
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF4CAF50), // Green
                    value: _leaveBalance['Carry Forward']!.toDouble(),
                    title: '',
                    radius: 80,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF2196F3), // Blue
                    value: _leaveBalance['Eligible']!.toDouble(),
                    title: '',
                    radius: 80,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF44336), // Red
                    value: _leaveBalance['Availed']!.toDouble(),
                    title: '',
                    radius: 80,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFFEB3B), // Yellow
                    value: _leaveBalance['Balance']!.toDouble(),
                    title: '',
                    radius: 80,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(const Color(0xFF4CAF50), 'Carry Forward', _leaveBalance['Carry Forward']!),
                const SizedBox(height: 8),
                _buildLegendItem(const Color(0xFF2196F3), 'Eligible', _leaveBalance['Eligible']!),
                const SizedBox(height: 8),
                _buildLegendItem(const Color(0xFFF44336), 'Availed', _leaveBalance['Availed']!),
                const SizedBox(height: 8),
                _buildLegendItem(const Color(0xFFFFEB3B), 'Balance', _leaveBalance['Balance']!),
              ],
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
        Text(
          '$count $label',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Text('–', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHalfDayCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4A90E2),
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

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
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
                padding: const EdgeInsets.all(20),
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
                    IconButton(
                      onPressed: () {
                        // Download functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download feature coming soon')),
                        );
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  IconButton(
                                    onPressed: () {
                                      // Attachment functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Attachment feature coming soon')),
                                      );
                                    },
                                    icon: const Icon(Icons.attachment),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Date Fields
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateTimeField(
                                      label: 'From Date',
                                      icon: Icons.calendar_today,
                                      value: _formatDate(_fromDate),
                                      onTap: () => _selectDate(context, true),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildDateTimeField(
                                      label: 'To Date',
                                      icon: Icons.calendar_today,
                                      value: _formatDate(_toDate),
                                      onTap: () => _selectDate(context, false),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Time Fields
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateTimeField(
                                      label: _formatTime(_fromTime),
                                      icon: Icons.access_time,
                                      value: '',
                                      onTap: () => _selectTime(context, true),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildDateTimeField(
                                      label: _formatTime(_toTime),
                                      icon: Icons.access_time,
                                      value: '',
                                      onTap: () => _selectTime(context, false),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Half Day Checkboxes
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildHalfDayCheckbox(
                                      'Half Day',
                                      _isHalfDayFrom,
                                          (value) => setState(() => _isHalfDayFrom = value ?? false),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildHalfDayCheckbox(
                                      'Half Day',
                                      _isHalfDayTo,
                                          (value) => setState(() => _isHalfDayTo = value ?? false),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Leave Type Dropdown
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Leave Type :-',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedLeaveType,
                                          isExpanded: true,
                                          items: _leaveTypes.map((String type) {
                                            return DropdownMenuItem<String>(
                                              value: type,
                                              child: Text(type),
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
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Notes Field
                              const Text(
                                'Notes :',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _notesController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Enter reason for leave...',
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
                                    borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                                  ),
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
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