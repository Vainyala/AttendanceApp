
import 'package:AttendenceApp/utils/app_styles.dart';
import 'package:AttendenceApp/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/location_service.dart';
import '../services/geofencing_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../widgets/attendance_chart_utils.dart';
import '../widgets/custom_bars.dart';
import '../widgets/custom_button.dart';
import '../widgets/custome_stat_row.dart';
import '../widgets/date_time_utils.dart';
import '../widgets/profile_header.dart';
import '../widgets/attendance_graph.dart';
import 'attendance_history_screen.dart';
import 'project_details_screen.dart';

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

    await NotificationService.initialize();
    await provider.loadUserData();
    await _checkLocationAndStartMonitoring();
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
            body: _buildBody(provider),
          ),
        );
      },
    );
  }

  Widget _buildBody(AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryBlue, AppColors.primaryBlue],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.refreshAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildTopBar(),
                _buildProfileHeader(provider),
                const SizedBox(height: 30),
                _buildMainContent(provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
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
    );
  }

  Widget _buildProfileHeader(AppProvider provider) {
    return ProfileHeader(
      name: provider.user?.name,
      role: provider.user?.role,
      company: 'Nutantek Solutions',
    );
  }

  Widget _buildMainContent(AppProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.textLight,
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
            _buildDateTimeStatus(provider),
            const SizedBox(height: 25),
            _buildCheckInOutButtons(provider),
            const SizedBox(height: 30),
            _buildMappedProjects(provider),
            const SizedBox(height: 30),
            _buildAttendanceGraphSection(provider),
            const SizedBox(height: 20),
            _buildStatsContainer(provider),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeStatus(AppProvider provider) {
    return Center(
      child: Column(
        children: [
          Text(
            DateTimeUtils.formatDateTime(DateTime.now()),
            style: AppStyles.time,
          ),
          const SizedBox(height: 5),
          Text(
            DateTimeUtils.formatTime(DateTime.now()),
            style: AppStyles.textMedium,
          ),
          const SizedBox(height: 10),
          Text(
            provider.statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: provider.canCheckIn || provider.canCheckOut ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInOutButtons(AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: provider.isCheckingIn ? 'CHECKING IN...' : 'CHECK IN',
            icon: Icons.login,
            color: AppColors.successGreen,
            loading: provider.isCheckingIn,
            onPressed: provider.canCheckIn ? _handleCheckIn : null,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: CustomButton(
            text: provider.isCheckingOut ? 'CHECKING OUT...' : 'CHECK OUT',
            icon: Icons.logout,
            color: AppColors.successGreen,
            loading: provider.isCheckingOut,
            onPressed: provider.canCheckOut ? _handleCheckOut : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMappedProjects(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mapped Projects',
              style: AppStyles.headingLarge,
            ),
            Text(
              '${provider.user?.projects.length ?? 0} Projects',
              style: AppStyles.text,
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildProjectsList(provider),
      ],
    );
  }

  Widget _buildProjectsList(AppProvider provider) {
    return SizedBox(
      height: 140,
      child: provider.isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : provider.user == null || provider.user!.projects.isEmpty
          ? Center(
        child: Text(
          "No projects mapped",
          style: AppStyles.text
        ),
      )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.user!.projects.length,
        itemBuilder: (context, index) {
          final project = provider.user!.projects[index];
          return _buildProjectCard(provider, project);
        },
      ),
    );
  }

  Widget _buildProjectCard(AppProvider provider, dynamic project) {
    return GestureDetector(
      onTap: () {
        provider.setSelectedProject(project);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProjectDetailsScreen()),
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
              style: AppStyles.text1,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            _buildProjectDetailRow(Icons.location_on, project.site),
            const SizedBox(height: 5),
            _buildProjectDetailRow(Icons.access_time, project.shift),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: AppStyles.text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceGraphSection(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attendance Graph',
              style: AppStyles.headingLarge,
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
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        AttendanceGraph(
          data: AttendanceChartUtils.getChartData(provider.weeklyAttendance),
        ),
      ],
    );
  }

  Widget _buildStatsContainer(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomStatRow(
            label: 'Daily Avg',
            value: '${provider.weeklyAvgHours.toStringAsFixed(1)} Hrs',
            isGood: provider.weeklyAvgHours >= 8,
          ),
          const Divider(height: 20),
          CustomStatRow(
            label: 'Monthly Total',
            value: '${provider.monthlyAvgHours.toStringAsFixed(0)} Hrs',
            isGood: provider.monthlyAvgHours >= 160,
          ),
        ],
      ),
    );
  }
}