import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/geofencing_service.dart';
import 'geofence_setup_screen.dart';
import 'attendance_history_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _user;
  List<AttendanceModel> _todayAttendance = [];
  bool _isLocationEnabled = false;
  String _currentStatus = "Checking location...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkLocationAndStartMonitoring();
    _loadTodayAttendance();
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
        _currentStatus = insideAnyGeofence
            ? "Inside $geofenceName"
            : "Outside all geofences";
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

  Future<void> _logout() async {
    await GeofencingService.stopMonitoring();
    await StorageService.removeUser();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${_user?.name ?? 'User'}'),
        backgroundColor: const Color(0xFF4A5AE8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadTodayAttendance();
          await _updateLocationStatus();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: _isLocationEnabled
                        ? [Colors.green, Colors.green.shade700]
                        : [Colors.orange, Colors.orange.shade700],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLocationEnabled ? Icons.location_on : Icons.location_off,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateTime.now().toString().split('.')[0],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Today's Attendance
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A5AE8),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (_todayAttendance.isEmpty)
                      const Text(
                        'No attendance records for today',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      )
                    else
                      ..._todayAttendance.map((record) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              record.type == AttendanceType.enter
                                  ? Icons.login
                                  : Icons.logout,
                              color: record.type == AttendanceType.enter
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${record.type.toString().split('.').last.toUpperCase()} - ${record.geofence?.name ?? 'Unknown'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GeofenceSetupScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_location,
                              size: 40,
                              color: Color(0xFF4A5AE8),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Setup\nGeofences',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AttendanceHistoryScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 40,
                              color: Color(0xFF4A5AE8),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Attendance\nHistory',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}