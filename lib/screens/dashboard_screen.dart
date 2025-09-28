// import 'package:flutter/material.dart';
// import '../models/user_model.dart';
// import '../models/attendance_model.dart';
// import '../services/storage_service.dart';
// import '../services/location_service.dart';
// import '../services/geofencing_service.dart';
// import 'geofence_setup_screen.dart';
// import 'attendance_history_screen.dart';
// import 'login_screen.dart';
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//   UserModel? _user;
//   List<AttendanceModel> _todayAttendance = [];
//   bool _isLocationEnabled = false;
//   String _currentStatus = "Checking location...";
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _checkLocationAndStartMonitoring();
//     _loadTodayAttendance();
//   }
//
//   Future<void> _loadUserData() async {
//     final user = await StorageService.getUser();
//     setState(() => _user = user);
//   }
//
//   Future<void> _checkLocationAndStartMonitoring() async {
//     final hasPermission = await LocationService.requestLocationPermission();
//
//     if (hasPermission) {
//       setState(() {
//         _isLocationEnabled = true;
//         _currentStatus = "Location monitoring active";
//       });
//
//       await GeofencingService.startMonitoring();
//       _updateLocationStatus();
//     } else {
//       setState(() {
//         _isLocationEnabled = false;
//         _currentStatus = "Location permission required";
//       });
//     }
//   }
//
//   Future<void> _updateLocationStatus() async {
//     final position = await LocationService.getCurrentPosition();
//     if (position != null) {
//       final geofences = await StorageService.getGeofences();
//       bool insideAnyGeofence = false;
//       String geofenceName = "";
//
//       for (var geofence in geofences) {
//         if (LocationService.isWithinGeofence(position, geofence)) {
//           insideAnyGeofence = true;
//           geofenceName = geofence.name;
//           break;
//         }
//       }
//
//       setState(() {
//         _currentStatus = insideAnyGeofence
//             ? "Inside $geofenceName"
//             : "Outside all geofences";
//       });
//     }
//   }
//
//   Future<void> _loadTodayAttendance() async {
//     final allAttendance = await StorageService.getAttendanceHistory();
//     final today = DateTime.now();
//
//     final todayRecords = allAttendance.where((record) {
//       return record.timestamp.year == today.year &&
//           record.timestamp.month == today.month &&
//           record.timestamp.day == today.day;
//     }).toList();
//
//     setState(() => _todayAttendance = todayRecords);
//   }
//
//   Future<void> _logout() async {
//     await GeofencingService.stopMonitoring();
//     await StorageService.removeUser();
//
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Welcome ${_user?.name ?? 'User'}'),
//         backgroundColor: const Color(0xFF4A5AE8),
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _logout,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await _loadTodayAttendance();
//           await _updateLocationStatus();
//         },
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             // Status Card
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   gradient: LinearGradient(
//                     colors: _isLocationEnabled
//                         ? [Colors.green, Colors.green.shade700]
//                         : [Colors.orange, Colors.orange.shade700],
//                   ),
//                 ),
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           _isLocationEnabled ? Icons.location_on : Icons.location_off,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             _currentStatus,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       DateTime.now().toString().split('.')[0],
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Today's Attendance
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Today\'s Attendance',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF4A5AE8),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     if (_todayAttendance.isEmpty)
//                       const Text(
//                         'No attendance records for today',
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 14,
//                         ),
//                       )
//                     else
//                       ..._todayAttendance.map((record) => Container(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[50],
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey[300]!),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               record.type == AttendanceType.enter
//                                   ? Icons.login
//                                   : Icons.logout,
//                               color: record.type == AttendanceType.enter
//                                   ? Colors.green
//                                   : Colors.red,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${record.type.toString().split('.').last.toUpperCase()} - ${record.geofence?.name ?? 'Unknown'}',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                   Text(
//                                     '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
//                                     style: TextStyle(
//                                       color: Colors.grey[600],
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )).toList(),
//                   ],
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Quick Actions
//             Row(
//               children: [
//                 Expanded(
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const GeofenceSetupScreen()),
//                         );
//                       },
//                       borderRadius: BorderRadius.circular(12),
//                       child: const Padding(
//                         padding: EdgeInsets.all(20),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.add_location,
//                               size: 40,
//                               color: Color(0xFF4A5AE8),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'Setup\nGeofences',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const AttendanceHistoryScreen()),
//                         );
//                       },
//                       borderRadius: BorderRadius.circular(12),
//                       child: const Padding(
//                         padding: EdgeInsets.all(20),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.history,
//                               size: 40,
//                               color: Color(0xFF4A5AE8),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'Attendance\nHistory',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../services/custom_bottom_nav_bar.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/geofencing_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _user;
  List<AttendanceModel> _todayAttendance = [];
  List<AttendanceModel> _weeklyAttendance = [];
  bool _isLocationEnabled = false;
  String _currentStatus = "Checking location...";
  String _geofenceStatus = "You Are Not In Range Of Nutantek";
  double _weeklyAvgHours = 8.5;
  double _monthlyAvgHours = 45.5;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkLocationAndStartMonitoring();
    _loadTodayAttendance();
    _loadWeeklyAttendance();
  }

  Future<void> _loadUserData() async {
    final user = await StorageService.getUser();
    setState(() => _user = user);
  }

  Future<void> _checkLocationAndStartMonitoring() async {
    final hasPermission = await LocationService.requestLocationPermission();

    if (hasPermission) {
      setState(() {
        _isLocationEnabled = true;
        _currentStatus = "Location monitoring active";
      });

      await GeofencingService.startMonitoring();
      _updateLocationStatus();
    } else {
      setState(() {
        _isLocationEnabled = false;
        _currentStatus = "Location permission required";
        _geofenceStatus = "Location Permission Required";
      });
    }
  }

  Future<void> _updateLocationStatus() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      final geofences = await StorageService.getGeofences();
      bool insideAnyGeofence = false;
      String geofenceName = "";

      for (var geofence in geofences) {
        if (LocationService.isWithinGeofence(position, geofence)) {
          insideAnyGeofence = true;
          geofenceName = geofence.name;
          break;
        }
      }

      setState(() {
        _geofenceStatus = insideAnyGeofence
            ? "You Are In Range Of $geofenceName"
            : "You Are Not In Range Of Nutantek";
      });
    }
  }

  Future<void> _loadTodayAttendance() async {
    final allAttendance = await StorageService.getAttendanceHistory();
    final today = DateTime.now();

    final todayRecords = allAttendance.where((record) {
      return record.timestamp.year == today.year &&
          record.timestamp.month == today.month &&
          record.timestamp.day == today.day;
    }).toList();

    setState(() => _todayAttendance = todayRecords);
  }

  Future<void> _loadWeeklyAttendance() async {
    final allAttendance = await StorageService.getAttendanceHistory();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final weeklyRecords = allAttendance.where((record) {
      return record.timestamp.isAfter(weekStart);
    }).toList();

    setState(() => _weeklyAttendance = weeklyRecords);
    _calculateAverages(weeklyRecords, allAttendance);
  }

  void _calculateAverages(List<AttendanceModel> weeklyRecords, List<AttendanceModel> allRecords) {
    // Calculate weekly hours
    double weeklyHours = 0;
    for (int i = 0; i < weeklyRecords.length - 1; i += 2) {
      if (i + 1 < weeklyRecords.length) {
        final duration = weeklyRecords[i + 1].timestamp.difference(weeklyRecords[i].timestamp);
        weeklyHours += duration.inMinutes / 60.0;
      }
    }

    // Calculate monthly hours (last 30 days)
    final monthStart = DateTime.now().subtract(const Duration(days: 30));
    final monthlyRecords = allRecords.where((record) => record.timestamp.isAfter(monthStart)).toList();

    double monthlyHours = 0;
    for (int i = 0; i < monthlyRecords.length - 1; i += 2) {
      if (i + 1 < monthlyRecords.length) {
        final duration = monthlyRecords[i + 1].timestamp.difference(monthlyRecords[i].timestamp);
        monthlyHours += duration.inMinutes / 60.0;
      }
    }

    setState(() {
      _weeklyAvgHours = weeklyHours / 7; // Average per day
      _monthlyAvgHours = monthlyHours;
    });
  }

  List<FlSpot> _getChartData() {
    // Convert actual weekly attendance data to chart points
    if (_weeklyAttendance.isEmpty) {
      // Return sample data if no attendance records
      return [
        const FlSpot(1, 67.11),
        const FlSpot(2, 8.5),
        const FlSpot(3, 5.2),
        const FlSpot(4, 1.8),
        const FlSpot(5, 89.27),
        const FlSpot(6, 85.6),
        const FlSpot(7, 72.3),
      ];
    }

    // Group attendance by days of the week
    Map<int, double> dailyHours = {};

    for (int i = 0; i < _weeklyAttendance.length - 1; i += 2) {
      if (i + 1 < _weeklyAttendance.length) {
        final checkIn = _weeklyAttendance[i];
        final checkOut = _weeklyAttendance[i + 1];
        final day = checkIn.timestamp.weekday;
        final duration = checkOut.timestamp.difference(checkIn.timestamp);
        final hours = duration.inMinutes / 60.0;

        dailyHours[day] = (dailyHours[day] ?? 0) + hours;
      }
    }

    // Convert to chart spots
    List<FlSpot> spots = [];
    for (int i = 1; i <= 7; i++) {
      spots.add(FlSpot(i.toDouble(), dailyHours[i] ?? 0));
    }

    return spots;
  }

  String _formatDateTime(DateTime dateTime) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return '${days[dateTime.weekday - 1]} ${months[dateTime.month - 1]} ${dateTime.day} ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  Future<void> _handleCheckIn() async {
    if (!_isLocationEnabled) {
      _showMessage('Please enable location services');
      return;
    }

    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        _showMessage('Unable to get current location');
        return;
      }

      final geofences = await StorageService.getGeofences();
      bool insideGeofence = false;

      for (var geofence in geofences) {
        if (LocationService.isWithinGeofence(position, geofence)) {
          insideGeofence = true;

          // Create attendance record
          final attendance = AttendanceModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: _user?.id ?? '',
            timestamp: DateTime.now(),
            type: AttendanceType.enter,
            latitude: position.latitude,
            longitude: position.longitude,
            geofence: geofence,
          );

          await StorageService.saveAttendanceRecord(attendance);
          await _loadTodayAttendance();
          await _loadWeeklyAttendance();

          _showMessage('Check-in successful!');
          break;
        }
      }

      if (!insideGeofence) {
        _showMessage('You are not within any geofence area');
      }
    } catch (e) {
      _showMessage('Check-in failed: $e');
    }
  }

  Future<void> _handleCheckOut() async {
    // Similar logic to check-in but for checkout
    if (!_isLocationEnabled) {
      _showMessage('Please enable location services');
      return;
    }

    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        _showMessage('Unable to get current location');
        return;
      }

      // Create checkout record
      final attendance = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _user?.id ?? '',
        timestamp: DateTime.now(),
        type: AttendanceType.exit,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await StorageService.saveAttendanceRecord(attendance);
      await _loadTodayAttendance();
      await _loadWeeklyAttendance();

      _showMessage('Check-out successful!');
    } catch (e) {
      _showMessage('Check-out failed: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF357ABD),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadTodayAttendance();
              await _loadWeeklyAttendance();
              await _updateLocationStatus();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Top Section with User Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                              onPressed: () {
                                _showMessage('Notifications feature coming soon');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _user?.name ?? 'Samal Vainyala',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Flutter Developer',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Nutantek Solutions',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content Area
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date and Time
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _formatDateTime(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _formatTime(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _geofenceStatus,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Check In/Out Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _handleCheckIn,
                                  icon: const Icon(Icons.login, color: Colors.white),
                                  label: const Text('CHECK IN', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isLocationEnabled
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey.shade400,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _handleCheckOut,
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                  label: const Text('CHECK OUT', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isLocationEnabled
                                        ? const Color(0xFFFF5722)
                                        : Colors.grey.shade400,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Attendance Graph
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Attendance Graph',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _showMessage('Opening attendance history');
                                },
                                icon: const Icon(Icons.folder, size: 24),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Chart Container
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFF8C00), Color(0xFFFF6347)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const titles = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                        if (value.toInt() >= 0 && value.toInt() < titles.length) {
                                          return Text(
                                            titles[value.toInt()],
                                            style: const TextStyle(color: Colors.white, fontSize: 10),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getChartData(),
                                    isCurved: true,
                                    color: Colors.white,
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 6,
                                          color: Colors.white,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                                minX: 0,
                                maxX: 8,
                                minY: 0,
                                maxY: 100,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Weekly and Monthly Averages
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Weekly Avg :- ${_weeklyAvgHours.toStringAsFixed(2)} Hrs',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _weeklyAvgHours < 8
                                            ? Colors.orange.shade100
                                            : Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                              _weeklyAvgHours < 8 ? Icons.warning : Icons.thumb_up,
                                              color: _weeklyAvgHours < 8 ? Colors.orange.shade600 : Colors.green.shade600,
                                              size: 16
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _weeklyAvgHours < 8 ? 'YOU\'R LAGGING' : 'GOOD',
                                            style: TextStyle(
                                              color: _weeklyAvgHours < 8 ? Colors.orange.shade600 : Colors.green.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Monthly Avg :- ${_monthlyAvgHours.toStringAsFixed(2)} Hrs',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _monthlyAvgHours < 160
                                            ? Colors.orange.shade100
                                            : Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                              _monthlyAvgHours < 160 ? Icons.warning : Icons.thumb_up,
                                              color: _monthlyAvgHours < 160 ? Colors.orange.shade600 : Colors.green.shade600,
                                              size: 16
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _monthlyAvgHours < 160 ? 'NEEDS \nIMPROVEMENT' : 'GREAT',
                                            style: TextStyle(
                                              color: _monthlyAvgHours < 160 ? Colors.orange.shade600 : Colors.green.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        ),
      ),
    );
  }
}