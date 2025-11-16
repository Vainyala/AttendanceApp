// import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
// import 'package:intl/intl.dart';
// import '../models/attendance_model.dart';
// import '../models/geofence_model.dart';
// import '../services/storage_service.dart';
//
// class AttendanceHistoryScreen extends StatefulWidget {
//   final List<dynamic> projects; // Replace with ProjectModel
//
//   const AttendanceHistoryScreen({super.key, required this.projects});
//   @override
//   State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
// }
//
// class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
//   List<AttendanceModel> _allAttendance = [];
//   List<AttendanceModel> _filteredAttendance = [];
//   bool _isLoading = true;
//   DateTime? _selectedDate;
//   String _selectedFilter = 'All';
//   final List<String> _filterOptions = ['All', 'Enter', 'Exit', 'Today', 'This Week', 'This Month'];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAttendanceHistory();
//   }
//
//   Future<void> _loadAttendanceHistory() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final attendance = await StorageService.getAttendanceHistory();
//       setState(() {
//         _allAttendance = attendance..sort((a, b) => b.timestamp.compareTo(a.timestamp));
//         _filteredAttendance = _allAttendance;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error loading attendance history: $e'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     }
//   }
//
//   void _applyFilter(String filter) {
//     setState(() {
//       _selectedFilter = filter;
//       final now = DateTime.now();
//
//       switch (filter) {
//         case 'All':
//           _filteredAttendance = _allAttendance;
//           break;
//         case 'Enter':
//           _filteredAttendance = _allAttendance
//               .where((record) => record.type == AttendanceType.enter)
//               .toList();
//           break;
//         case 'Exit':
//           _filteredAttendance = _allAttendance
//               .where((record) => record.type == AttendanceType.exit)
//               .toList();
//           break;
//         case 'Today':
//           _filteredAttendance = _allAttendance.where((record) {
//             return record.timestamp.year == now.year &&
//                 record.timestamp.month == now.month &&
//                 record.timestamp.day == now.day;
//           }).toList();
//           break;
//         case 'This Week':
//           final weekStart = now.subtract(Duration(days: now.weekday - 1));
//           _filteredAttendance = _allAttendance.where((record) {
//             return record.timestamp.isAfter(weekStart.subtract(const Duration(days: 1)));
//           }).toList();
//           break;
//         case 'This Month':
//           _filteredAttendance = _allAttendance.where((record) {
//             return record.timestamp.year == now.year &&
//                 record.timestamp.month == now.month;
//           }).toList();
//           break;
//       }
//     });
//   }
//
//   void _selectDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF4A5AE8),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _selectedFilter = 'Custom Date';
//         _filteredAttendance = _allAttendance.where((record) {
//           return record.timestamp.year == picked.year &&
//               record.timestamp.month == picked.month &&
//               record.timestamp.day == picked.day;
//         }).toList();
//       });
//     }
//   }
//
//   String _formatDuration(Duration duration) {
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return '${hours}h ${minutes}m';
//   }
//
//   Widget _buildStatsCard() {
//     final totalRecords = _filteredAttendance.length;
//     final enterRecords = _filteredAttendance.where((r) => r.type == AttendanceType.enter).length;
//     final exitRecords = _filteredAttendance.where((r) => r.type == AttendanceType.exit).length;
//
//     // Calculate total time spent (simplified)
//     Duration totalTime = Duration.zero;
//     AttendanceModel? lastEnter;
//
//     for (var record in _filteredAttendance.reversed) {
//       if (record.type == AttendanceType.enter) {
//         lastEnter = record;
//       } else if (record.type == AttendanceType.exit && lastEnter != null) {
//         totalTime += record.timestamp.difference(lastEnter.timestamp);
//         lastEnter = null;
//       }
//     }
//
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: const LinearGradient(
//             colors: [Color(0xFF4A5AE8), Color(0xFF6B73FF)],
//           ),
//         ),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text(
//               'Attendance Summary',
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatItem('Total', totalRecords.toString(), Icons.list),
//                 _buildStatItem('Entries', enterRecords.toString(), Icons.login),
//                 _buildStatItem('Exits', exitRecords.toString(), Icons.logout),
//               ],
//             ),
//             if (totalTime.inMinutes > 0) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: AppColors.textLight.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'Total Time: ${_formatDuration(totalTime)}',
//                   style: const TextStyle(
//                     color: AppColors.textLight,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatItem(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, color: AppColors.textLight, size: 28),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             color: AppColors.textLight,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             color: AppColors.textLight70,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAttendanceCard(AttendanceModel record) {
//     final isEnter = record.type == AttendanceType.enter;
//
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isEnter ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: ListTile(
//           contentPadding: const EdgeInsets.all(16),
//           leading: Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: isEnter ? AppColors.success : AppColors.error,
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Icon(
//               isEnter ? Icons.login : Icons.logout,
//               color: AppColors.textLight,
//               size: 28,
//             ),
//           ),
//           title: Text(
//             '${isEnter ? 'ENTERED' : 'EXITED'} ${record.geofence?.name ?? 'Unknown Location'}',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   const Icon(Icons.access_time, size: 16, color: AppColors.textHint),
//                   const SizedBox(width: 4),
//                   Text(
//                     DateFormat('MMM dd, yyyy - hh:mm a').format(record.timestamp),
//                     style: TextStyle(
//                       color: AppColors.textHint[600],
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 2),
//               if (record.geofence != null) ...[
//                 Row(
//                   children: [
//                     const Icon(Icons.location_on, size: 16, color: AppColors.textHint),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Type: ${record.geofence!.type.toString().split('.').last.toUpperCase()}',
//                       style: TextStyle(
//                         color: AppColors.textHint[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//           trailing: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: isEnter ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               DateFormat('HH:mm').format(record.timestamp),
//               style: TextStyle(
//                 color: isEnter ? AppColors.success[700] : AppColors.error[700],
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance History'),
//         backgroundColor: const Color(0xFF4A5AE8),
//         foregroundColor: AppColors.textLight,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_today),
//             onPressed: _selectDate,
//             tooltip: 'Select Date',
//           ),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.filter_list),
//             onSelected: _applyFilter,
//             itemBuilder: (context) => _filterOptions.map((filter) {
//               return PopupMenuItem<String>(
//                 value: filter,
//                 child: Row(
//                   children: [
//                     Icon(
//                       _selectedFilter == filter ? Icons.check_circle : Icons.circle_outlined,
//                       size: 18,
//                       color: _selectedFilter == filter ? const Color(0xFF4A5AE8) : AppColors.textHint,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(filter),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadAttendanceHistory,
//         color: const Color(0xFF4A5AE8),
//         child: _isLoading
//             ? const Center(
//           child: CircularProgressIndicator(
//             color: Color(0xFF4A5AE8),
//           ),
//         )
//             : Column(
//           children: [
//             // Filter Status
//             if (_selectedFilter != 'All' || _selectedDate != null)
//               Container(
//                 width: double.infinity,
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF4A5AE8).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: const Color(0xFF4A5AE8).withOpacity(0.3),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.filter_alt,
//                       color: const Color(0xFF4A5AE8),
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         _selectedDate != null
//                             ? 'Filtered by: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'
//                             : 'Filtered by: $_selectedFilter',
//                         style: const TextStyle(
//                           color: Color(0xFF4A5AE8),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(
//                         Icons.clear,
//                         color: Color(0xFF4A5AE8),
//                         size: 20,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _selectedFilter = 'All';
//                           _selectedDate = null;
//                           _filteredAttendance = _allAttendance;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//
//             // Stats Card
//             if (_filteredAttendance.isNotEmpty) ...[
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _buildStatsCard(),
//               ),
//               const SizedBox(height: 16),
//             ],
//
//             // Attendance List
//             Expanded(
//               child: _filteredAttendance.isEmpty
//                   ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.history,
//                       size: 80,
//                       color: AppColors.textHint[400],
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       _selectedFilter == 'All'
//                           ? 'No Attendance Records'
//                           : 'No Records Found',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textHint[600],
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       _selectedFilter == 'All'
//                           ? 'Your attendance history will appear here'
//                           : 'Try changing the filter or date',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppColors.textHint[500],
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: _filteredAttendance.length,
//                 itemBuilder: (context, index) {
//                   return _buildAttendanceCard(_filteredAttendance[index]);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/project_model.dart';
import '../models/attendance_model.dart';
import '../services/storage_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final List<ProjectModel> projects;

  const AttendanceHistoryScreen({super.key, required this.projects});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<AttendanceModel> _allAttendance = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final attendance = await StorageService.getAttendanceHistory();

    // Generate dummy data if empty
    if (attendance.isEmpty) {
      _allAttendance = _generateDummyAttendance();
    } else {
      _allAttendance = attendance;
    }
    setState(() {});
  }

  List<AttendanceModel> _generateDummyAttendance() {
    List<AttendanceModel> dummyData = [];
    final now = DateTime.now();

    // Generate data for last 7 days
    for (int day = 0; day < 7; day++) {
      final date = now.subtract(Duration(days: day));

      // Check-in at 9 AM
      dummyData.add(AttendanceModel(
        id: 'dummy_${day}_in',
        userId: 'U001',
        timestamp: DateTime(date.year, date.month, date.day, 9, 0),
        type: AttendanceType.enter,
        latitude: 19.2952,
        longitude: 73.1186,
      ));

      // Check-out at 6 PM (9 hours)
      dummyData.add(AttendanceModel(
        id: 'dummy_${day}_out',
        userId: 'U001',
        timestamp: DateTime(date.year, date.month, date.day, 18, 0),
        type: AttendanceType.exit,
        latitude: 19.2952,
        longitude: 73.1186,
      ));
    }

    return dummyData;
  }

  List<FlSpot> _getProjectAttendanceData(String projectId) {
    Map<int, double> dailyHours = {};

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final projectAttendance = _allAttendance.where((record) {
      return record.timestamp.isAfter(weekAgo);
    }).toList();

    for (int i = 0; i < projectAttendance.length - 1; i += 2) {
      if (i + 1 < projectAttendance.length &&
          projectAttendance[i].type == AttendanceType.enter &&
          projectAttendance[i + 1].type == AttendanceType.exit) {
        final day = projectAttendance[i].timestamp.weekday;
        final duration = projectAttendance[i + 1].timestamp
            .difference(projectAttendance[i].timestamp);
        final hours = duration.inMinutes / 60.0;
        dailyHours[day] = (dailyHours[day] ?? 0) + hours;
      }
    }

    List<FlSpot> spots = [];
    for (int i = 1; i <= 7; i++) {
      spots.add(FlSpot(i.toDouble(), dailyHours[i] ?? 0));
    }

    return spots;
  }

  double _calculateWeeklyAvg() {
    double totalHours = 0;
    int days = 0;

    for (int i = 0; i < _allAttendance.length - 1; i += 2) {
      if (i + 1 < _allAttendance.length &&
          _allAttendance[i].type == AttendanceType.enter &&
          _allAttendance[i + 1].type == AttendanceType.exit) {
        final duration = _allAttendance[i + 1].timestamp
            .difference(_allAttendance[i].timestamp);
        totalHours += duration.inMinutes / 60.0;
        days++;
      }
    }

    return days > 0 ? totalHours / days : 0;
  }

  double _calculateWeeklyTotal() {
    double totalHours = 0;

    for (int i = 0; i < _allAttendance.length - 1; i += 2) {
      if (i + 1 < _allAttendance.length &&
          _allAttendance[i].type == AttendanceType.enter &&
          _allAttendance[i + 1].type == AttendanceType.exit) {
        final duration = _allAttendance[i + 1].timestamp
            .difference(_allAttendance[i].timestamp);
        totalHours += duration.inMinutes / 60.0;
      }
    }

    return totalHours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History", style: TextStyle(color: AppColors.textLight)),
        backgroundColor: const Color(0xFF4A90E2),
        iconTheme: const IconThemeData(color: AppColors.textLight),
        elevation: 0,
      ),
      body: widget.projects.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: AppColors.textHint.shade400),
            const SizedBox(height: 20),
            Text(
              'No Projects Mapped',
              style: TextStyle(fontSize: 18, color: AppColors.textHint.shade600),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: widget.projects.length,
        itemBuilder: (context, index) {
          final project = widget.projects[index];
          final weeklyAvg = _calculateWeeklyAvg();
          final weeklyTotal = _calculateWeeklyTotal();

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${project.site} • ${project.shift}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.cardBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.bar_chart, color: AppColors.textLight, size: 30),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.textLight.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '${value.toInt()}h',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    days[value.toInt()],
                                    style: const TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
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
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getProjectAttendanceData(project.id),
                          isCurved: true,
                          color: AppColors.textLight,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: AppColors.textLight,
                                strokeWidth: 2,
                                strokeColor: Colors.blue.shade600,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.textLight.withOpacity(0.2),
                          ),
                        ),
                      ],
                      minX: 1,
                      maxX: 7,
                      minY: 0,
                      maxY: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatChip('Daily Avg', '${weeklyAvg.toStringAsFixed(1)} Hrs'),
                    _buildStatChip('This Week', '${weeklyTotal.toStringAsFixed(0)} Hrs'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cardBackground,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}