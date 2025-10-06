import 'package:AttendenceApp/screens/profile_screen.dart';
import 'package:AttendenceApp/services/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/geofencing_service.dart';
import '../services/notification_service.dart'; // Add this import
import 'attendance_history_screen.dart';
import 'project_details_screen.dart';
import '../services/custom_bars.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserModel? _user;
  List<AttendanceModel> _todayAttendance = [];
  List<AttendanceModel> _weeklyAttendance = [];
  bool _isLocationEnabled = false;
  String _currentStatus = "Checking location...";
  String _geofenceStatus = "You Are Not In Range Of Nutantek";
  double _weeklyAvgHours = 0.0;
  double _monthlyAvgHours = 0.0;
  bool _canCheckIn = false;
  bool _canCheckOut = false;
  bool _wasInsideGeofence = false; // Track previous geofence state

  @override
  void initState() {
    super.initState();
    _initializeNotifications(); // Initialize notifications
    _loadUserData();
    _checkLocationAndStartMonitoring();
    _loadTodayAttendance();
    _loadWeeklyAttendance();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
  }

  Future<void> _loadUserData() async {
    final dummyProjects = [
      ProjectModel(
        id: 'P001',
        name: 'Nutantek Office App',
        site: 'Nutantek Office',
        shift: 'Morning',
        clientName: 'Client A',
        clientContact: '1234567890',
        manager: 'Manager A',
        description: 'Office attendance app',
        techStack: 'Flutter, Firebase',
        assignedDate: DateTime.now(),
      ),
      ProjectModel(
        id: 'P002',
        name: 'Delhi Police App',
        site: 'Client Site',
        shift: 'Evening',
        clientName: 'Client B',
        clientContact: '0987654321',
        manager: 'Manager B',
        description: 'Website development',
        techStack: 'React, Node.js',
        assignedDate: DateTime.now(),
      ),
      ProjectModel(
        id: 'P003',
        name: 'eMulakat App',
        site: 'WFH',
        shift: 'Morning',
        clientName: 'Client A',
        clientContact: '1234567890',
        manager: 'Manager A',
        description: 'Office attendance app',
        techStack: 'Flutter, Firebase',
        assignedDate: DateTime.now(),
      ),
      ProjectModel(
        id: 'P004',
        name: 'Attedance App',
        site: 'WFH',
        shift: 'Morning',
        clientName: 'Client A',
        clientContact: '1234567890',
        manager: 'Manager A',
        description: 'Office attendance app',
        techStack: 'Flutter, Firebase',
        assignedDate: DateTime.now(),
      ),
    ];

    final dummyUser = UserModel(
      id: 'U001',
      name: 'Samal Vainyala',
      email: 'samal@nutantek.com',
      role: 'Flutter Developer',
      projects: dummyProjects,
    );

    setState(() => _user = dummyUser);
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

      // Start periodic location checking
      _startPeriodicLocationCheck();
    } else {
      setState(() {
        _isLocationEnabled = false;
        _currentStatus = "Location permission required";
        _geofenceStatus = "Location Permission Required";
      });
    }
  }

  void _startPeriodicLocationCheck() {
    // Check location every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _updateLocationStatus();
        _startPeriodicLocationCheck();
      }
    });
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

      // Check if geofence state has changed
      if (insideAnyGeofence != _wasInsideGeofence) {
        if (insideAnyGeofence) {
          // User entered geofence
          await NotificationService.showGeofenceNotification(
            title: 'Welcome to $geofenceName',
            body: 'You are now in range. You can check in.',
            isEntering: true,
          );
        } else {
          // User exited geofence
          await NotificationService.showGeofenceNotification(
            title: 'Left Geofence Area',
            body: 'You are no longer in range of Nutantek.',
            isEntering: false,
          );
        }
        _wasInsideGeofence = insideAnyGeofence;
      }

      setState(() {
        _geofenceStatus = insideAnyGeofence
            ? "You Are In Range Of $geofenceName"
            : "You Are Not In Range Of Nutantek";

        if (insideAnyGeofence) {
          _canCheckIn = _todayAttendance.isEmpty ||
              _todayAttendance.last.type == AttendanceType.exit;
          _canCheckOut = _todayAttendance.isNotEmpty &&
              _todayAttendance.last.type == AttendanceType.enter;
        } else {
          _canCheckIn = false;
          _canCheckOut = false;
        }
      });
    }
  }

  Future<void> _loadTodayAttendance() async {
    final allAttendance = await StorageService.getAttendanceHistory();
    final today = DateTime.now();

    // If no attendance, generate dummy data
    if (allAttendance.isEmpty) {
      final dummyAttendance = _generateDummyAttendance();
      for (var record in dummyAttendance) {
        await StorageService.saveAttendanceRecord(record);
      }
    }

    final updatedAttendance = await StorageService.getAttendanceHistory();
    final todayRecords = updatedAttendance.where((record) {
      return record.timestamp.year == today.year &&
          record.timestamp.month == today.month &&
          record.timestamp.day == today.day;
    }).toList();

    setState(() => _todayAttendance = todayRecords);
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

  Future<void> _loadWeeklyAttendance() async {
    final allAttendance = await StorageService.getAttendanceHistory();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    final weeklyRecords = allAttendance.where((record) {
      return record.timestamp.isAfter(weekAgo);
    }).toList();

    setState(() => _weeklyAttendance = weeklyRecords);
    _calculateAverages(weeklyRecords, allAttendance);
  }

  void _calculateAverages(List<AttendanceModel> weeklyRecords, List<AttendanceModel> allRecords) {
    double weeklyHours = 0;
    int weeklyDays = 0;

    for (int i = 0; i < weeklyRecords.length - 1; i += 2) {
      if (i + 1 < weeklyRecords.length &&
          weeklyRecords[i].type == AttendanceType.enter &&
          weeklyRecords[i + 1].type == AttendanceType.exit) {
        final duration = weeklyRecords[i + 1].timestamp.difference(weeklyRecords[i].timestamp);
        weeklyHours += duration.inMinutes / 60.0;
        weeklyDays++;
      }
    }

    final monthStart = DateTime.now().subtract(const Duration(days: 30));
    final monthlyRecords = allRecords.where((record) => record.timestamp.isAfter(monthStart)).toList();

    double monthlyHours = 0;
    for (int i = 0; i < monthlyRecords.length - 1; i += 2) {
      if (i + 1 < monthlyRecords.length &&
          monthlyRecords[i].type == AttendanceType.enter &&
          monthlyRecords[i + 1].type == AttendanceType.exit) {
        final duration = monthlyRecords[i + 1].timestamp.difference(monthlyRecords[i].timestamp);
        monthlyHours += duration.inMinutes / 60.0;
      }
    }

    setState(() {
      _weeklyAvgHours = weeklyDays > 0 ? weeklyHours / weeklyDays : 0;
      _monthlyAvgHours = monthlyHours;
    });
  }

  List<FlSpot> _getChartData() {
    Map<int, double> dailyHours = {};

    for (int i = 0; i < _weeklyAttendance.length - 1; i += 2) {
      if (i + 1 < _weeklyAttendance.length &&
          _weeklyAttendance[i].type == AttendanceType.enter &&
          _weeklyAttendance[i + 1].type == AttendanceType.exit) {
        final checkIn = _weeklyAttendance[i];
        final checkOut = _weeklyAttendance[i + 1];
        final day = checkIn.timestamp.weekday;
        final duration = checkOut.timestamp.difference(checkIn.timestamp);
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

    if (!_canCheckIn) {
      _showMessage('You have already checked in or are not in range');
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
          await _updateLocationStatus();

          // Send check-in notification
          await NotificationService.showAttendanceNotification(
            title: 'Check-In Successful',
            body: 'You have successfully checked in at ${_formatTime(DateTime.now())}',
          );

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
    if (!_isLocationEnabled) {
      _showMessage('Please enable location services');
      return;
    }

    if (!_canCheckOut) {
      _showMessage('You need to check in first');
      return;
    }

    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        _showMessage('Unable to get current location');
        return;
      }

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
      await _updateLocationStatus();

      // Send check-out notification
      await NotificationService.showAttendanceNotification(
        title: 'Check-Out Successful',
        body: 'You have successfully checked out at ${_formatTime(DateTime.now())}',
      );

      _showMessage('Check-out successful!');
    } catch (e) {
      _showMessage('Check-out failed: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 0,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
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
                    // Top Bar with Notifications only
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                            onPressed: () => showProfileMenu(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                            onPressed: () => _showMessage('Notifications coming soon'),
                          ),
                        ],
                      ),
                    ),

                    // Profile Section
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ProfileScreen()),
                            );
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/profile.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _user?.name ?? 'Loading...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _user?.role ?? 'Developer',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Nutantek Solutions',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Main Content
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _formatTime(DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _geofenceStatus,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _canCheckIn || _canCheckOut ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Check In/Out Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _canCheckIn ? _handleCheckIn : null,
                                    icon: const Icon(Icons.login, color: Colors.white),
                                    label: const Text('CHECK IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _canCheckIn ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: _canCheckIn ? 4 : 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _canCheckOut ? _handleCheckOut : null,
                                    icon: const Icon(Icons.logout, color: Colors.white),
                                    label: const Text('CHECK OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _canCheckOut ? const Color(0xFFFF5722) : Colors.grey.shade400,
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: _canCheckOut ? 4 : 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Mapped Projects
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Mapped Projects',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${_user?.projects.length ?? 0} Projects',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            SizedBox(
                              height: 140,
                              child: _user == null
                                  ? const Center(child: CircularProgressIndicator())
                                  : _user!.projects.isEmpty
                                  ? Center(
                                child: Text(
                                  "No projects mapped",
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                ),
                              )
                                  : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _user!.projects.length,
                                itemBuilder: (context, index) {
                                  final project = _user!.projects[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProjectDetailsScreen(project: project),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 280,
                                      margin: const EdgeInsets.only(right: 15),
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            project.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  project.site,
                                                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time, color: Colors.white70, size: 16),
                                              const SizedBox(width: 5),
                                              Text(
                                                project.shift,
                                                style: const TextStyle(fontSize: 13, color: Colors.white70),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Attendance Graph - Fixed with better scaling
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
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AttendanceHistoryScreen(projects: _user!.projects),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.history, size: 20),
                                  label: const Text('View All'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF4A90E2),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFFF8C00), Color(0xFFFF6347)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(15),
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 2,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.white.withOpacity(0.2),
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
                                                color: Colors.white,
                                                fontSize: 12,
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
                                          const titles = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                          if (value.toInt() >= 0 && value.toInt() < titles.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                titles[value.toInt()],
                                                style: const TextStyle(
                                                  color: Colors.white,
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
                                            radius: 5,
                                            color: Colors.white,
                                            strokeWidth: 2,
                                            strokeColor: Colors.orange.shade700,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.white.withOpacity(0.2),
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

                            const SizedBox(height: 20),

                            // Weekly and Monthly Stats
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildStatRow(
                                    'Daily Avg',
                                    '${_weeklyAvgHours.toStringAsFixed(1)} Hrs',
                                    _weeklyAvgHours >= 8,
                                  ),
                                  const Divider(height: 20),
                                  _buildStatRow(
                                    'Monthly Total',
                                    '${_monthlyAvgHours.toStringAsFixed(0)} Hrs',
                                    _monthlyAvgHours >= 160,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 100),
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
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isGood) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isGood ? Colors.green.shade100 : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isGood ? Icons.thumb_up : Icons.warning,
                color: isGood ? Colors.green.shade700 : Colors.orange.shade700,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                isGood ? 'GOOD' : 'IMPROVE',
                style: TextStyle(
                  color: isGood ? Colors.green.shade700 : Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}