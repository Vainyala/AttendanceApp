import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/custom_bars.dart';
import '../services/storage_service.dart';
import '../models/attendance_model.dart';

// State Management - Regularisation Provider/State
class RegularisationState {
  final List<AttendanceModel> attendance;
  final bool isLoading;
  final String? errorMessage;
  final List<DateTime> availableMonths;
  final int currentMonthIndex;
  final Map<String, Map<String, int>> monthlyStats;
  final int currentProjectPage;

  RegularisationState({
    required this.attendance,
    required this.isLoading,
    this.errorMessage,
    required this.availableMonths,
    required this.currentMonthIndex,
    required this.monthlyStats,
    required this.currentProjectPage,
  });

  RegularisationState copyWith({
    List<AttendanceModel>? attendance,
    bool? isLoading,
    String? errorMessage,
    List<DateTime>? availableMonths,
    int? currentMonthIndex,
    Map<String, Map<String, int>>? monthlyStats,
    int? currentProjectPage,
  }) {
    return RegularisationState(
      attendance: attendance ?? this.attendance,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      availableMonths: availableMonths ?? this.availableMonths,
      currentMonthIndex: currentMonthIndex ?? this.currentMonthIndex,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      currentProjectPage: currentProjectPage ?? this.currentProjectPage,
    );
  }
}

class RegularisationScreen extends StatefulWidget {
  const RegularisationScreen({super.key});

  @override
  State<RegularisationScreen> createState() => _RegularisationScreenState();
}

class _RegularisationScreenState extends State<RegularisationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RegularisationState _state;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _loadAttendance();
  }

  void _initializeState() {
    final now = DateTime.now();
    final availableMonths = <DateTime>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      availableMonths.add(month);
    }

    _state = RegularisationState(
      attendance: [],
      isLoading: false,
      availableMonths: availableMonths,
      currentMonthIndex: availableMonths.length - 1,
      monthlyStats: {},
      currentProjectPage: 0,
    );

    _tabController = TabController(
      length: availableMonths.length,
      vsync: this,
      initialIndex: _state.currentMonthIndex,
    );
  }

  void _updateState(RegularisationState newState) {
    setState(() {
      _state = newState;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      await Future.delayed(const Duration(seconds: 1));

      final dummyData = _createDummyAttendance();
      _calculateMonthlyStats(dummyData);

      if (mounted) {
        _updateState(_state.copyWith(
          attendance: dummyData,
          isLoading: false,
        ));
      }
    } catch (e, stackTrace) {
      if (mounted) {
        _updateState(_state.copyWith(
          errorMessage: 'Error loading attendance: $e',
          isLoading: false,
          attendance: [],
        ));
      }
      print('Error: $e\nStack: $stackTrace');
    }
  }

  void _calculateMonthlyStats(List<AttendanceModel> records) {
    final stats = <String, Map<String, int>>{};

    for (var month in _state.availableMonths) {
      final monthKey = DateFormat('yyyy-MM').format(month);
      stats[monthKey] = {
        'Apply': 0,
        'Approved': 0,
        'Pending': 0,
        'Rejected': 0,
      };
    }

    final groupedByDate = <String, List<AttendanceModel>>{};
    for (var record in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.timestamp);
      groupedByDate.putIfAbsent(dateKey, () => []);
      groupedByDate[dateKey]!.add(record);
    }

    for (var entry in groupedByDate.entries) {
      final dayRecords = entry.value;
      final clockHours = _calculateClockHours(dayRecords);
      final shortfall = _calculateShortfall(clockHours);
      final date = dayRecords.first.timestamp;
      final monthKey = DateFormat('yyyy-MM').format(date);
      final status = _getStatusForDay(date, shortfall);

      if (stats.containsKey(monthKey) && stats[monthKey]!.containsKey(status)) {
        stats[monthKey]![status] = stats[monthKey]![status]! + 1;
      }
    }

    _updateState(_state.copyWith(monthlyStats: stats));
  }

  List<AttendanceModel> _createDummyAttendance() {
    final records = <AttendanceModel>[];
    final now = DateTime.now();

    // List of holidays (format: 'yyyy-MM-dd')
    final holidays = [
      '2024-10-02', // Gandhi Jayanti
      '2024-10-12', // Dussehra
      '2024-10-31', // Diwali
      '2024-11-01', // Diwali
      '2024-12-25', // Christmas
      '2025-01-26', // Republic Day
    ];

    final projectNames = [
      'Project A', 'Project B', 'Project C', 'Project D',
      'Project Alpha', 'Project Beta', 'Project Gamma'
    ];

    for (var month in _state.availableMonths) {
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final maxDay =
      month.month == now.month && month.year == now.year ? now.day : daysInMonth;

      for (int day = 1; day <= maxDay; day++) {
        final currentDate = DateTime(month.year, month.month, day);
        final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);

        // Skip Sundays
        if (currentDate.weekday == DateTime.sunday) {
          continue;
        }

        // Skip holidays
        if (holidays.contains(dateKey)) {
          continue;
        }

        // Randomly select 1-3 projects for this day
        final numProjects = 1 + ((day * month.month) % 3);
        final dayProjects = <String>[];

        for (int i = 0; i < numProjects; i++) {
          final projectIndex = ((day * 7 + i * 13 + month.month * 3) % projectNames.length);
          final project = projectNames[projectIndex];
          if (!dayProjects.contains(project)) {
            dayProjects.add(project);
          }
        }

        // Create varied work hours to simulate different scenarios
        final dayVariation = (day * 3 + month.month * 7) % 10;

        for (int i = 0; i < dayProjects.length; i++) {
          final project = dayProjects[i];

          // Vary work hours more realistically
          int workHours;
          int workMinutes;

          if (dayVariation < 2) {
            workHours = 2; // 2-3 hours
            workMinutes = 30 + ((day + i) % 30);
          } else if (dayVariation < 4) {
            workHours = 3; // 3-4 hours
            workMinutes = ((day * i) % 60);
          } else if (dayVariation < 7) {
            workHours = 3; // 3.5-4 hours
            workMinutes = 30 + ((day - i) % 30);
          } else {
            workHours = 4; // 4-5 hours (full/near full)
            workMinutes = ((day + month.month + i) % 45);
          }

          // Vary check-in times between 8:30 AM and 10:00 AM
          final checkInHour = 8 + ((day + i) % 2);
          final checkInMinute = (day * 5 + i * 15) % 60;

          final checkInTime = DateTime(
              month.year, month.month, day,
              checkInHour, checkInMinute
          );
          final checkOutTime = checkInTime.add(
              Duration(hours: workHours, minutes: workMinutes)
          );

          records.addAll([
            AttendanceModel(
              id: 'checkin_${month.month}_${day}_$project',
              userId: 'user_123',
              timestamp: checkInTime,
              type: AttendanceType.checkIn,
              latitude: 19.2183,
              longitude: 72.9781,
              projectName: project,
            ),
            AttendanceModel(
              id: 'checkout_${month.month}_${day}_$project',
              userId: 'user_123',
              timestamp: checkOutTime,
              type: AttendanceType.checkOut,
              latitude: 19.2183,
              longitude: 72.9781,
              projectName: project,
            ),
          ]);
        }
      }
    }

    return records;
  }

  List<AttendanceModel> _filterByMonth(DateTime month) {
    return _state.attendance
        .where((record) =>
    record.timestamp.year == month.year &&
        record.timestamp.month == month.month)
        .toList();
  }

  String _calculateClockHours(List<AttendanceModel> dayRecords) {
    try {
      final projectGroups = <String, List<AttendanceModel>>{};
      for (var record in dayRecords) {
        projectGroups.putIfAbsent(record.projectName, () => []);
        projectGroups[record.projectName]!.add(record);
      }

      int totalMinutes = 0;

      for (var projectRecords in projectGroups.values) {
        final checkIn = projectRecords.firstWhere(
              (r) => r.type == AttendanceType.checkIn,
          orElse: () => projectRecords.first,
        );
        final checkOut = projectRecords.lastWhere(
              (r) => r.type == AttendanceType.checkOut,
          orElse: () => projectRecords.last,
        );

        totalMinutes += checkOut.timestamp.difference(checkIn.timestamp).inMinutes;
      }

      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  String _calculateShortfall(String clockHours) {
    try {
      final parts = clockHours.split(':');
      final workedMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final standardMinutes = 8 * 60;

      if (workedMinutes >= standardMinutes) return '00:00';

      final shortfallMinutes = standardMinutes - workedMinutes;
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

    // Future dates and today are always approved
    if (checkDate.isAtSameMomentAs(today) || checkDate.isAfter(today)) {
      return 'Approved';
    }

    // If no shortfall, approved
    if (shortfall == '00:00') return 'Approved';

    // For past dates with shortfall, create realistic distribution
    // Using day and month for better variety
    final random = (date.day * 3 + date.month * 7) % 20;

    // 25% Apply (needs action)
    if (random < 5) return 'Apply';

    // 20% Pending (under review)
    if (random < 9) return 'Pending';

    // 15% Rejected (denied)
    if (random < 12) return 'Rejected';

    // 40% Approved (accepted)
    return 'Approved';
  }

  bool _canEditRecord(DateTime date, String status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    return checkDate.isBefore(today) && status == 'Apply';
  }

  void _showRegularisationDialog(
      String dateStr,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,
      ) {
    final status = _getStatusForDay(
      actualDate,
      _calculateShortfall(_calculateClockHours(dayRecords)),
    );

    if (!_canEditRecord(actualDate, status)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot apply for regularisation for today or future dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedType = 'PM';
    final noteController = TextEditingController();

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
                _buildProjectSummary(dayRecords),
                const SizedBox(height: 16),
                const Text('Select Time:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
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
                    content: Text(
                      'Regularisation request submitted for $dateStr at ${selectedTime.format(context)} $selectedType',
                    ),
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

  Widget _buildProjectSummary(List<AttendanceModel> dayRecords) {
    final projectGroups = <String, List<AttendanceModel>>{};
    for (var record in dayRecords) {
      projectGroups.putIfAbsent(record.projectName, () => []);
      projectGroups[record.projectName]!.add(record);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Hours:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...projectGroups.entries.map((entry) {
            final projectRecords = entry.value;
            final checkIn = projectRecords.firstWhere(
                  (r) => r.type == AttendanceType.checkIn,
              orElse: () => projectRecords.first,
            );
            final checkOut = projectRecords.lastWhere(
                  (r) => r.type == AttendanceType.checkOut,
              orElse: () => projectRecords.last,
            );

            final duration = checkOut.timestamp.difference(checkIn.timestamp);
            final hours = duration.inHours;
            final minutes = duration.inMinutes % 60;
            final timeStr =
                '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 13)),
                  Text(
                    '$timeStr hrs',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '${_calculateClockHours(dayRecords)} hrs',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSwiper(List<AttendanceModel> dayRecords) {
    final projectGroups = <String, List<AttendanceModel>>{};
    for (var record in dayRecords) {
      projectGroups.putIfAbsent(record.projectName, () => []);
      projectGroups[record.projectName]!.add(record);
    }

    if (projectGroups.isEmpty) return const SizedBox.shrink();

    final projectEntries = projectGroups.entries.toList();

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Projects (Swipe to view)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${projectEntries.length} projects',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: PageView.builder(
              itemCount: projectEntries.length,
              itemBuilder: (context, index) {
                final entry = projectEntries[index];
                final projectRecords = entry.value;

                final checkIn = projectRecords.firstWhere(
                      (r) => r.type == AttendanceType.checkIn,
                  orElse: () => projectRecords.first,
                );
                final checkOut = projectRecords.lastWhere(
                      (r) => r.type == AttendanceType.checkOut,
                  orElse: () => projectRecords.last,
                );

                final duration = checkOut.timestamp.difference(checkIn.timestamp);
                final hours = duration.inHours;
                final minutes = duration.inMinutes % 60;
                final timeStr =
                    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}/${projectEntries.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 6),
                          Text(
                            '$timeStr hrs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
      String date,
      String hours,
      String shortfall,
      String status,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,
      ) {
    final canEdit = _canEditRecord(actualDate, status);

    return InkWell(
      onTap: canEdit ? () => _showRegularisationDialog(date, actualDate, dayRecords) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: canEdit ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canEdit ? Colors.blue.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE').format(actualDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            hours,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(' hrs',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        shortfall,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: shortfall == '00:00' ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        'shortfall',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getStatusIcon(status),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildProjectSwiper(dayRecords),
            if (canEdit)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tap to apply for regularisation',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorizedRecords(DateTime month) {
    final records = _filterByMonth(month);
    final byStatus = {
      'Apply': <Map>[],
      'Pending': <Map>[],
      'Rejected': <Map>[],
      'Approved': <Map>[],
    };

    final groupedByDate = <String, List<AttendanceModel>>{};
    for (var record in records) {
      final dateKey = DateFormat('dd/MM/yy').format(record.timestamp);
      groupedByDate.putIfAbsent(dateKey, () => []);
      groupedByDate[dateKey]!.add(record);
    }

    for (var entry in groupedByDate.entries) {
      final dayRecords = entry.value;
      final clockHours = _calculateClockHours(dayRecords);
      final shortfall = _calculateShortfall(clockHours);
      final actualDate = dayRecords.first.timestamp;
      final status = _getStatusForDay(actualDate, shortfall);

      byStatus[status]?.add({
        'date': entry.key,
        'hours': clockHours,
        'shortfall': shortfall,
        'actualDate': actualDate,
        'records': dayRecords,
      });
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: byStatus.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => _buildStatusCategory(entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildStatusCategory(String status, List<Map> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getStatusIcon(status),
                const SizedBox(width: 8),
                Text(
                  '$status (${items.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...items
              .map((item) => _buildTableRow(
            item['date'],
            item['hours'],
            item['shortfall'],
            status,
            item['actualDate'],
            item['records'],
          ))
              .toList(),
        ],
      ),
    );
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'Apply':
        return const Icon(Icons.edit, size: 12, color: Colors.white);
      case 'Approved':
        return const Icon(Icons.check_circle, size: 12, color: Colors.white);
      case 'Pending':
        return const Icon(Icons.schedule, size: 12, color: Colors.white);
      case 'Rejected':
        return const Icon(Icons.cancel, size: 12, color: Colors.white);
      default:
        return const Icon(Icons.help, size: 12, color: Colors.white);
    }
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

  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Regularisation', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Color(0xFF4A90E2),
                    width: 3,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 16),
                ),
                labelColor: const Color(0xFF4A90E2),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                tabs: _state.availableMonths
                    .map((month) {
                  final isCurrentMonth =
                      month.month == DateTime.now().month &&
                          month.year == DateTime.now().year;
                  return Tab(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(DateFormat('MMM yyyy').format(month)),
                        if (isCurrentMonth) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4A90E2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        body: _state.isLoading
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
            : _state.errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_state.errorMessage!),
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
          children: _state.availableMonths
              .map((month) => _buildCategorizedRecords(month))
              .toList(),
        ),
      ),
    );
  }
}