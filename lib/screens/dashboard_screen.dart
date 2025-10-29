import 'dart:async';

import 'package:AttendanceApp/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/location_service.dart';
import '../services/geofencing_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/attendance_chart_utils.dart';
import '../widgets/custom_bars.dart';
import '../widgets/custom_button.dart';
import '../widgets/custome_stat_row.dart';
import '../widgets/date_time_utils.dart';
import '../widgets/menu_drawer.dart';
import '../widgets/profile_header.dart';
import '../widgets/attendance_graph.dart';
import 'attendance_history_screen.dart';
import 'project_details_screen.dart';
import 'auth_verification_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'face_detection_screen.dart';
import '../main.dart' show cameras;


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _verificationAlertShowing = false;

  // Timer variables
  Timer? _countdownTimer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    _setupNotificationHandler();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingVerification();
      _startCountdownTimer(); // Restart timer when app resumes
    }
  }

  // FIXED: Countdown Timer Logic - Counts DOWN from 9 hours
  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        final provider = context.read<AppProvider>();

        if (provider.checkInTime != null && provider.checkOutTime == null) {
          final checkInTime = provider.checkInTime!;
          final targetTime = checkInTime.add(Duration(hours: 9));
          final now = DateTime.now();

          final difference = targetTime.difference(now);

          setState(() {
            if (difference.isNegative) {
              _remainingTime = Duration.zero;
            } else {
              _remainingTime = difference;
            }
          });
        } else {
          setState(() {
            _remainingTime = null;
          });
        }
      }
    });
  }

  // Format countdown time (HH:MM:SS)
  String _formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _setupNotificationHandler() {
    NotificationService.onNotificationTap = (payload) {
      if (payload != null) {
        _handleNotificationTap(payload);
      }
    };
  }

  void _handleNotificationTap(String payload) {
    final provider = context.read<AppProvider>();

    if (!provider.isNotificationValid(payload)) {
      _showExpiredNotificationDialog();
      return;
    }

    if (payload.startsWith('checkin_')) {
      // FIXED: First check-in should ONLY do face verification
      _navigateToFaceVerification(VerificationReason.checkIn);
    } else if (payload.startsWith('out_of_range_')) {
      // Going out during office hours - show both options
      _navigateToAuthChoice();
    } else if (payload.startsWith('checkout_')) {
      // Checkout after 6 PM - only face verification
      _navigateToFaceVerification(VerificationReason.checkOut);
    }
  }

  void _showExpiredNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Notification Expired'),
          ],
        ),
        content: Text(
          'This notification has expired (5 minutes limit). Check-in is disabled for this instance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _checkPendingVerification() {
    final provider = context.read<AppProvider>();

    if (provider.pendingVerification &&
        !_verificationAlertShowing &&
        ModalRoute.of(context)?.isCurrent == true) {
      _showVerificationAlert();
    }
  }

  void _showVerificationAlert() {
    if (_verificationAlertShowing) return;

    _verificationAlertShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text('Verification Required'),
            ],
          ),
          content: Text(
            'You need to complete verification to continue. Please complete face or fingerprint authentication.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _verificationAlertShowing = false;

                final provider = context.read<AppProvider>();

                // FIXED: If first check-in, go directly to face verification
                if (provider.employeeStatus == EmployeeStatus.notCheckedIn) {
                  _navigateToFaceVerification(VerificationReason.checkIn);
                } else {
                  _navigateToAuthChoice();
                }
              },
              child: Text('Verify Now', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    ).then((_) {
      _verificationAlertShowing = false;

      Future.delayed(Duration(seconds: 10), () {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          _checkPendingVerification();
        }
      });
    });
  }

  void _navigateToAuthChoice() {
    final provider = context.read<AppProvider>();

    setState(() {
      _verificationAlertShowing = false;
    });

    VerificationReason reason;
    bool allowFingerprint = false;

    // **UPDATED: Check if first check-in of the day**
    if (provider.isFirstCheckInToday || provider.employeeStatus == EmployeeStatus.notCheckedIn) {
      // First check-in - go directly to face verification
      _navigateToFaceVerification(VerificationReason.checkIn);
      return; // Exit early, don't show choice screen
    } else if (provider.employeeStatus == EmployeeStatus.checkedIn) {
      reason = VerificationReason.goingOut;
      allowFingerprint = true; // Allow both options for going out
    } else if (provider.employeeStatus == EmployeeStatus.returned) {
      reason = VerificationReason.returning;
      allowFingerprint = true; // Allow both options when returning
    } else {
      reason = VerificationReason.checkOut;
      allowFingerprint = false; // Only face auth for final checkout
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthVerificationScreen(
          reason: reason,
          allowFingerprint: allowFingerprint,
          onVerificationSuccess: (verificationType) {
            _handleVerificationSuccess(verificationType, reason);
          },
        ),
      ),
    );
  }

  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    return status.isGranted;
  }

  Future<void> _navigateToFaceVerification(VerificationReason reason) async {
    final hasPermission = await _checkCameraPermission();

    if (!hasPermission) {
      _showMessage('Camera permission is required for verification');
      return;
    }

    if (cameras.isEmpty) {
      _showMessage('No camera found on this device');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceDetectionScreen(
          cameras: cameras,
          onVerificationComplete: () {
            _handleFaceVerificationSuccess(reason);
          },
        ),
      ),
    );
  }

  void _handleVerificationSuccess(VerificationType type, VerificationReason reason) {
    final provider = context.read<AppProvider>();

    if (type == VerificationType.faceBlinking) {
      _navigateToFaceVerification(reason);
    } else {
      if (reason == VerificationReason.goingOut) {
        provider.handleOutOfRangeVerification(true);
        _showMessage('Going out - Will return later');
      } else if (reason == VerificationReason.returning) {
        provider.clearPendingVerification();
        _showMessage('Return verified successfully');
      }
    }
  }

  void _handleFaceVerificationSuccess(VerificationReason reason) async {
    final provider = context.read<AppProvider>();

    switch (reason) {
      case VerificationReason.checkIn:
        await provider.handleCheckIn(verified: true);
        _showMessage('Check-in successful!');
        _startCountdownTimer(); // FIXED: Start timer after check-in
        break;
      case VerificationReason.goingOut:
        await provider.handleOutOfRangeVerification(false);
        _showMessage('Going out - Not returning today');
        break;
      case VerificationReason.returning:
        provider.clearPendingVerification();
        _showMessage('Return verified successfully');
        break;
      case VerificationReason.checkOut:
        await provider.handleCheckOut(verified: true);
        _showMessage('Check-out successful!');
        _countdownTimer?.cancel(); // Stop timer on checkout
        break;
      default:
        break;
    }
  }

  Future<void> _initializeApp() async {
    final provider = context.read<AppProvider>();

    await NotificationService.initialize();
    await provider.loadUserData();
    await _checkLocationAndStartMonitoring();
    await provider.loadTodayAttendance();
    await provider.loadWeeklyAttendance();
    _startCountdownTimer(); // Start timer after loading data
    _checkPendingVerification();
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
        final provider = context.read<AppProvider>();
        provider.updateLocationStatus();
        provider.checkAndMarkAbsences(); // Add this
        _startPeriodicLocationCheck();
      }
    });
  }

  Future<void> _handleCheckIn() async {
    final provider = context.read<AppProvider>();

    // **UPDATED: Check if first check-in**
    if (provider.isFirstCheckInToday || provider.pendingVerification) {
      // Always go to face verification for first check-in
      _navigateToFaceVerification(VerificationReason.checkIn);
      return;
    }

    final message = await provider.handleCheckIn();
    _showMessage(message);

    if (message.contains('successful')) {
      _startCountdownTimer();
    }
  }
  Future<void> _handleCheckOut() async {
    final provider = context.read<AppProvider>();

    if (provider.employeeStatus == EmployeeStatus.checkedIn) {
      final now = DateTime.now();
      if (now.hour >= 18) {
        _navigateToFaceVerification(VerificationReason.checkOut);
        return;
      }
    }

    final message = await provider.handleCheckOut();
    _showMessage(message);

    if (message.contains('successful')) {
      _countdownTimer?.cancel(); // Stop timer on successful checkout
    }
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
            body: Stack(
              children: [
                _buildBody(provider),

                if (provider.pendingVerification)
                  _buildVerificationBanner(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verification Required - Tap to verify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  final provider = context.read<AppProvider>();

                  // FIXED: Check if first check-in
                  if (provider.employeeStatus == EmployeeStatus.notCheckedIn) {
                    _navigateToFaceVerification(VerificationReason.checkIn);
                  } else {
                    _navigateToAuthChoice();
                  }
                },
              ),
            ],
          ),
        ),
      ),
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
          onRefresh: () async {
            await provider.refreshAllData();
            _startCountdownTimer(); // Restart timer after refresh
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildTopBar(provider),
               // _buildTrackingToggle(provider),
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
 
  Widget _buildTopBar(AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Menu icon
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
            onPressed: () => showProfileMenu(context),
          ),

          // Center: Tracking toggle (Active/Inactive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.trackingEnabled ? Icons.location_on : Icons.location_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  provider.trackingEnabled ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: provider.trackingEnabled,
                  onChanged: (value) => provider.toggleTracking(value),
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green.shade300,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          // Right: Sync + Notification icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.sync, color: Colors.white, size: 26),
                onPressed: () => _showMessage('Sync data with the database'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                onPressed: () => _showMessage('Notifications coming soon'),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Widget _buildTrackingToggle(AppProvider provider) {
  //   return Center( // centers the container on the screen
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.15),
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all(
  //           color: Colors.white.withOpacity(0.3),
  //           width: 1,
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min, // makes container fit content
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             provider.trackingEnabled ? Icons.location_on : Icons.location_off,
  //             color: Colors.white,
  //             size: 18, // smaller icon
  //           ),
  //           const SizedBox(width: 10),
  //           Text(
  //             provider.trackingEnabled ? 'Active' : 'Inactive',
  //             style: TextStyle(
  //               color: Colors.white.withOpacity(0.9),
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //           const SizedBox(width: 10),
  //           Switch(
  //             value: provider.trackingEnabled,
  //             onChanged: (value) => provider.toggleTracking(value),
  //             activeColor: Colors.green,
  //             activeTrackColor: Colors.green.shade300,
  //             materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // makes switch smaller
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

  // FIXED: Date Time Status Widget with proper layout
  Widget _buildDateTimeStatus(AppProvider provider) {
    final hasCheckedIn = provider.checkInTime != null;
    final hasCheckedOut = provider.checkOutTime != null;
    final showTimer = hasCheckedIn && !hasCheckedOut;

    return Center(
      child: Column(
        children: [
          // Date at top
          Text(
            DateTimeUtils.formatDateTime(DateTime.now()),
            style: AppStyles.time,
          ),
          const SizedBox(height: 15),

          // FIXED: Check-in time and Countdown Timer Row
          if (showTimer && _remainingTime != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Check-in Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-in Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.login,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateTimeUtils.formatTimeOnly(
                                  provider.checkInTime!
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),

                  // Right: Countdown Timer (Counts DOWN)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Time Remaining',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.timer,
                              color: _remainingTime!.inMinutes > 60
                                  ? Colors.green
                                  : (_remainingTime!.inMinutes > 0
                                  ? Colors.orange
                                  : Colors.red),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatCountdown(_remainingTime!),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _remainingTime!.inMinutes > 60
                                    ? Colors.green
                                    : (_remainingTime!.inMinutes > 0
                                    ? Colors.orange
                                    : Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Show status message when not checked in
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
            onPressed: provider.canCheckIn || provider.pendingVerification
                ? _handleCheckIn
                : null,
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