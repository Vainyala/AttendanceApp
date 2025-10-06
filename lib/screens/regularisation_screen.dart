import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/custom_bars.dart';
import '../services/storage_service.dart';
import '../models/attendance_model.dart';

class RegularisationScreen extends StatefulWidget {
  const RegularisationScreen({super.key});

  @override
  State<RegularisationScreen> createState() => _RegularisationScreenState();
}

class _RegularisationScreenState extends State<RegularisationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AttendanceModel> _attendance = [];
  bool _isLoading = true;
  String? _errorMessage;
  List<DateTime> _availableMonths = [];
  int _currentMonthIndex = 0;

  // Statistics per month
  Map<String, Map<String, int>> _monthlyStats = {};

  @override
  void initState() {
    super.initState();
    _initializeMonths();
    _tabController = TabController(length: _availableMonths.length, vsync: this);
    _tabController.index = _currentMonthIndex;
    _loadAttendance();
  }

  void _initializeMonths() {
    final now = DateTime.now();
    _availableMonths.clear();

    // Generate last 6 months including current month
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      _availableMonths.add(month);
    }

    // Set current month as default (last in list)
    _currentMonthIndex = _availableMonths.length - 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(seconds: 1));

      final dummyData = _createDummyAttendance();
      _calculateMonthlyStats(dummyData);

      if (mounted) {
        setState(() {
          _attendance = dummyData;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading attendance: $e';
          _isLoading = false;
          _attendance = [];
        });
      }
      print('Error loading attendance: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _calculateMonthlyStats(List<AttendanceModel> records) {
    _monthlyStats.clear();

    for (var month in _availableMonths) {
      final monthKey = DateFormat('yyyy-MM').format(month);
      _monthlyStats[monthKey] = {
        'Apply': 0,
        'Approved': 0,
        'Pending': 0,
        'Rejected': 0,
      };
    }

    // Group by date and calculate stats
    final groupedByDate = <String, List<AttendanceModel>>{};
    for (var record in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.timestamp);
      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(record);
    }

    // Calculate status for each day
    for (var entry in groupedByDate.entries) {
      final dayRecords = entry.value;
      final clockHours = _calculateClockHours(dayRecords);
      final shortfall = _calculateShortfall(clockHours);
      final date = dayRecords.first.timestamp;
      final monthKey = DateFormat('yyyy-MM').format(date);

      if (_monthlyStats.containsKey(monthKey)) {
        final status = _getStatusForDay(date, shortfall);
        if (_monthlyStats[monthKey]!.containsKey(status)) {
          _monthlyStats[monthKey]![status] = _monthlyStats[monthKey]![status]! + 1;
        }
      }
    }
  }

  List<AttendanceModel> _createDummyAttendance() {
    final dummyRecords = <AttendanceModel>[];
    final now = DateTime.now();

    // Generate data for last 6 months
    for (var month in _availableMonths) {
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final maxDay = month.month == now.month && month.year == now.year ? now.day : daysInMonth;

      for (int day = 1; day <= maxDay; day++) {
        final date = DateTime(month.year, month.month, day);

        // Skip weekends
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          continue;
        }

        // Vary check-in times (some early, some late)
        final checkInHour = 9 + (day % 3 == 0 ? -1 : (day % 4 == 0 ? 1 : 0));
        final checkInMinute = day % 60;
        final checkInTime = DateTime(month.year, month.month, day, checkInHour, checkInMinute);

        // Vary work duration (7-9 hours)
        final workHours = 7 + (day % 3);
        final checkOutTime = checkInTime.add(Duration(hours: workHours, minutes: 30));

        // Check-in record
        dummyRecords.add(AttendanceModel(
          id: 'checkin_${month.month}_$day',
          userId: 'user_123',
          timestamp: checkInTime,
          type: AttendanceType.checkIn,
          latitude: 19.2183 + (day * 0.001),
          longitude: 72.9781 + (day * 0.001),
        ));

        // Check-out record
        dummyRecords.add(AttendanceModel(
          id: 'checkout_${month.month}_$day',
          userId: 'user_123',
          timestamp: checkOutTime,
          type: AttendanceType.checkOut,
          latitude: 19.2183 + (day * 0.001),
          longitude: 72.9781 + (day * 0.001),
        ));
      }
    }

    return dummyRecords;
  }

  List<AttendanceModel> _filterByMonth(DateTime month) {
    return _attendance.where((record) {
      return record.timestamp.year == month.year &&
          record.timestamp.month == month.month;
    }).toList();
  }

  String _calculateClockHours(List<AttendanceModel> dayRecords) {
    try {
      final checkIn = dayRecords.firstWhere(
            (r) => r.type == AttendanceType.checkIn,
        orElse: () => dayRecords.first,
      );
      final checkOut = dayRecords.lastWhere(
            (r) => r.type == AttendanceType.checkOut,
        orElse: () => dayRecords.last,
      );

      final duration = checkOut.timestamp.difference(checkIn.timestamp);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  String _calculateShortfall(String clockHours) {
    try {
      final parts = clockHours.split(':');
      final workedHours = int.parse(parts[0]);
      final workedMinutes = int.parse(parts[1]);
      final totalWorkedMinutes = workedHours * 60 + workedMinutes;
      final standardMinutes = 8 * 60;

      if (totalWorkedMinutes >= standardMinutes) {
        return '00:00';
      }

      final shortfallMinutes = standardMinutes - totalWorkedMinutes;
      final hours = shortfallMinutes ~/ 60;
      final minutes = shortfallMinutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  String _getStatusForDay(DateTime date, String shortfall) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    // Today and future dates are automatically Approved (can't be edited)
    if (checkDate.isAtSameMomentAs(today) || checkDate.isAfter(today)) {
      return 'Approved';
    }

    // For past dates, generate varied statuses based on shortfall and day
    final random = date.day % 10;

    if (shortfall == '00:00') {
      return 'Approved'; // No shortfall = approved
    } else {
      // Has shortfall - distribute among Apply, Pending, Rejected
      if (random < 3) {
        return 'Rejected';
      } else if (random < 6) {
        return 'Pending';
      } else {
        return 'Apply';
      }
    }
  }

  bool _canEditRecord(DateTime date, String status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    // Can only edit if:
    // 1. Date is in the past (not today or future)
    // 2. Status is "Apply"
    // Note: All previous dates with "Apply" status can be edited
    return checkDate.isBefore(today) && status == 'Apply';
  }

  void _showRegularisationDialog(String dateStr, DateTime actualDate) {
    if (!_canEditRecord(actualDate, _getStatusForDay(actualDate, ''))) {
      String message = actualDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))
          ? 'Cannot apply for regularisation for today or future dates'
          : 'This record cannot be edited';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedType = 'PM'; // Default is PM as per requirement
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Apply for Regularisation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: $dateStr', style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                const Text('Select Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setDialogState(() => selectedTime = time);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                        ),
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('AM'),
                        value: 'AM',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('PM'),
                        value: 'PM',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason for regularisation...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reason for regularisation'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Regularisation request submitted for $dateStr at ${selectedTime.format(context)} $selectedType'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Regularisation'),
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    // Left Arrow
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                      onPressed: _tabController.index > 0
                          ? () {
                        _tabController.animateTo(_tabController.index - 1);
                      }
                          : null,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    // Month Tabs - Scrollable
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.center,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        //labelColor: const Color(0xFF4A90E2),
                        unselectedLabelColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                        indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        tabs: _availableMonths.map((month) {
                          return Tab(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(DateFormat('MMM').format(month)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Right Arrow
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                      onPressed: _tabController.index < _tabController.length - 1
                          ? () {
                        _tabController.animateTo(_tabController.index + 1);
                      }
                          : null,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading attendance data...'),
            ],
          ),
        )
            : _errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAttendance,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : TabBarView(
          controller: _tabController,
          children: _availableMonths.map((month) => _buildTabContent(month)).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(DateTime month) {
    final records = _filterByMonth(month);
    final monthKey = DateFormat('yyyy-MM').format(month);
    final stats = _monthlyStats[monthKey] ?? {
      'Apply': 0,
      'Approved': 0,
      'Pending': 0,
      'Rejected': 0,
    };

    // Group records by date
    final Map<String, List<AttendanceModel>> groupedRecords = {};
    for (var record in records) {
      final dateKey = DateFormat('dd/MM/yy').format(record.timestamp);
      if (!groupedRecords.containsKey(dateKey)) {
        groupedRecords[dateKey] = [];
      }
      groupedRecords[dateKey]!.add(record);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Regularization Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.close, size: 20, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Text(
                      'Avg Shortfall :- 01:30 Hrs - ',
                      style: TextStyle(fontSize: 14),
                    ),
                    Icon(Icons.thumb_down, color: Colors.orange, size: 16),
                    Text(
                      " YOU'RE LAGGING",
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Text(
                      'Avg Catch Up:- 5:30 Hrs - ',
                      style: TextStyle(fontSize: 14),
                    ),
                    Icon(Icons.thumb_up, color: Colors.green, size: 16),
                    Text(
                      ' GREAT',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bar Chart Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
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
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: () {
                    final maxValue = stats.values.reduce((a, b) => a > b ? a : b);
                    return maxValue > 0 ? (maxValue + 2).toDouble() : 10.0;
                  }(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          const labels = ['Apply', 'Approved', 'Pending', 'Rejected'];
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: const TextStyle(fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: stats['Apply']! > 0 ? stats['Apply']!.toDouble() : 0.1,
                          color: Colors.orange,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: stats['Approved']! > 0 ? stats['Approved']!.toDouble() : 0.1,
                          color: Colors.green,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: stats['Pending']! > 0 ? stats['Pending']!.toDouble() : 0.1,
                          color: Colors.orange.shade300,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: stats['Rejected']! > 0 ? stats['Rejected']!.toDouble() : 0.1,
                          color: Colors.red,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Records Table
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
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Date",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Clock Hrs",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Shortfall",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Regularize",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                groupedRecords.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No attendance records for this month',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedRecords.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final dateKey = groupedRecords.keys.elementAt(index);
                    final dayRecords = groupedRecords[dateKey]!;
                    final clockHours = _calculateClockHours(dayRecords);
                    final shortfall = _calculateShortfall(clockHours);
                    final actualDate = dayRecords.first.timestamp;
                    final status = _getStatusForDay(actualDate, shortfall);

                    return _buildTableRow(
                      dateKey,
                      clockHours,
                      shortfall,
                      status,
                      actualDate,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTableRow(String date, String hours, String shortfall, String status, DateTime actualDate) {
    final canEdit = _canEditRecord(actualDate, status);

    return InkWell(
      onTap: canEdit ? () => _showRegularisationDialog(date, actualDate) : null,
      child: Container(
        color: canEdit ? Colors.transparent : Colors.grey.shade50,
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 13))),
            Expanded(flex: 2, child: Text(hours, style: const TextStyle(fontSize: 13))),
            Expanded(flex: 2, child: Text(shortfall, style: const TextStyle(fontSize: 13))),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      case "Pending":
        return Colors.orange;
      case "Apply":
        return const Color(0xFF4A90E2);
      default:
        return Colors.blue;
    }
  }
}