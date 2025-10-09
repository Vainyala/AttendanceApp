import 'package:AttendenceApp/screens/profile_screen.dart';
import 'package:AttendenceApp/services/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/attendance_model.dart';
import '../providers/dashboard_provider.dart';
import '../services/location_service.dart';
import '../services/geofencing_service.dart';
import '../services/notification_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final provider = context.read<AppProvider>();

    // Initialize notifications
    await NotificationService.initialize();

    // Load user data
    await provider.loadUserData();

    // Check location and start monitoring
    await _checkLocationAndStartMonitoring();

    // Load attendance data
    await provider.loadTodayAttendance();
    await provider.loadWeeklyAttendance();
  }

  Future<void> _checkLocationAndStartMonitoring() async {
    final provider = context.read<AppProvider>();
    final hasPermission = await LocationService.requestLocationPermission();

    if (hasPermission) {
      provider.setLocationEnabled(true);
      await GeofencingService.startMonitoring();
      await provider.updateLocationStatus();

      // Start periodic location checking
      _startPeriodicLocationCheck();
    } else {
      provider.setLocationEnabled(false);
    }
  }

  void _startPeriodicLocationCheck() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        context.read<AppProvider>().updateLocationStatus();
        _startPeriodicLocationCheck();
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[dateTime.weekday - 1]} ${months[dateTime.month - 1]} ${dateTime.day} ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  List<FlSpot> _getChartData(List<AttendanceModel> weeklyAttendance) {
    Map<int, double> dailyHours = {};

    for (int i = 0; i < weeklyAttendance.length - 1; i += 2) {
      if (i + 1 < weeklyAttendance.length &&
          weeklyAttendance[i].type == AttendanceType.enter &&
          weeklyAttendance[i + 1].type == AttendanceType.exit) {
        final checkIn = weeklyAttendance[i];
        final checkOut = weeklyAttendance[i + 1];
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

  Future<void> _handleCheckIn() async {
    final provider = context.read<AppProvider>();
    final message = await provider.handleCheckIn();
    _showMessage(message);
  }

  Future<void> _handleCheckOut() async {
    final provider = context.read<AppProvider>();
    final message = await provider.handleCheckOut();
    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
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
                  onRefresh: () => provider.refreshAllData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Top Bar
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
                              provider.user?.name ?? 'Loading...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              provider.user?.role ?? 'Developer',
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
                                // Date, Time and Status
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
                                        provider.statusMessage,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: provider.canCheckIn || provider.canCheckOut
                                              ? Colors.green
                                              : Colors.red,
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
                                        onPressed: provider.canCheckIn && !provider.isCheckingIn
                                            ? _handleCheckIn
                                            : null,
                                        icon: provider.isCheckingIn
                                            ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                            : const Icon(Icons.login, color: Colors.white),
                                        label: Text(
                                          provider.isCheckingIn ? 'CHECKING IN...' : 'CHECK IN',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: provider.canCheckIn
                                              ? const Color(0xFF4CAF50)
                                              : Colors.grey.shade400,
                                          disabledBackgroundColor: Colors.grey.shade300,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: provider.canCheckIn ? 4 : 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: provider.canCheckOut && !provider.isCheckingOut
                                            ? _handleCheckOut
                                            : null,
                                        icon: provider.isCheckingOut
                                            ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                            : const Icon(Icons.logout, color: Colors.white),
                                        label: Text(
                                          provider.isCheckingOut ? 'CHECKING OUT...' : 'CHECK OUT',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: provider.canCheckOut
                                              ? const Color(0xFFFF5722)
                                              : Colors.grey.shade400,
                                          disabledBackgroundColor: Colors.grey.shade300,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: provider.canCheckOut ? 4 : 0,
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
                                      '${provider.user?.projects.length ?? 0} Projects',
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
                                  child: provider.isLoadingUser
                                      ? const Center(child: CircularProgressIndicator())
                                      : provider.user == null || provider.user!.projects.isEmpty
                                      ? Center(
                                    child: Text(
                                      "No projects mapped",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  )
                                      : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: provider.user!.projects.length,
                                    itemBuilder: (context, index) {
                                      final project = provider.user!.projects[index];
                                      return GestureDetector(
                                        onTap: () {
                                          // 1️⃣ Set the selected project in provider
                                          provider.setSelectedProject(project);

                                          // 2️⃣ Navigate to ProjectDetailsScreen (no project argument needed)
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const ProjectDetailsScreen(),
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
                                    TextButton.icon(
                                      onPressed: () {
                                        if (provider.user?.projects != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AttendanceHistoryScreen(
                                                projects: provider.user!.projects,
                                              ),
                                            ),
                                          );
                                        }
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
                                          spots: _getChartData(provider.weeklyAttendance),
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
                                        '${provider.weeklyAvgHours.toStringAsFixed(1)} Hrs',
                                        provider.weeklyAvgHours >= 8,
                                      ),
                                      const Divider(height: 20),
                                      _buildStatRow(
                                        'Monthly Total',
                                        '${provider.monthlyAvgHours.toStringAsFixed(0)} Hrs',
                                        provider.monthlyAvgHours >= 160,
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
      },
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