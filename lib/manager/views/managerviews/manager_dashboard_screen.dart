import 'dart:async';

import 'package:AttendanceApp/manager/models/user_model.dart';
import 'package:AttendanceApp/manager/views/managerviews/manager_regularisation_screen.dart';
import 'package:AttendanceApp/manager/views/managerviews/timeline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/view_models/theme_view_model.dart';
import '../../core/widgets/bottom_navigation.dart';
import '../../view_models/managerviewmodels/manager_dashboard_view_model.dart';
import '../../widgets/mangerwidgets/attendance_timer.dart';
import '../../widgets/mangerwidgets/dashboard_cards.dart';
import '../../widgets/mangerwidgets/manager_drawer.dart';
import '../../widgets/mangerwidgets/matrix_counter.dart';
import '../../widgets/mangerwidgets/presentdashboard.dart';
import 'leavescreen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  final User user;

  const ManagerDashboardScreen({super.key, required this.user});

  @override
  _ManagerDashboardScreenState createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
    with TickerProviderStateMixin {
  String _currentTime = '';
  Timer? _timer;
  late TabController _tabController;
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Notification variables
  int _notificationCount = 3;
  bool _showNotificationBadge = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeAnimations();
    _initializeDashboard();
    _startLiveTime();
  }

  // Navigation handle करने का method add करें
  void _handleTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManagerRegularisationScreen(user: widget.user),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeaveScreen(user: widget.user)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimelineScreen(user: widget.user),
        ),
      );
    } else {
      _tabController.animateTo(index);
    }
  }

  void _startLiveTime() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = _getLiveTime();
      });
    }
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _initializeDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ManagerDashboardViewModel>(
        context,
        listen: false,
      );
      viewModel.initializeDashboard(widget.user);
    });
  }

  void _showNotifications(BuildContext context) {
    setState(() {
      _notificationCount = 0;
      _showNotificationBadge = false;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildNotificationsSheet(),
    );
  }

  Widget _buildNotificationsSheet() {
    final theme = Provider.of<AppTheme>(context);
    final bool isDarkMode = theme.isDarkMode;

    final notifications = [
      {
        'title': 'Team Meeting',
        'message': 'Scheduled for 3:00 PM today',
        'time': '10 min ago',
        'read': false,
      },
      {
        'title': 'Report Generated',
        'message': 'Monthly attendance report is ready',
        'time': '1 hour ago',
        'read': false,
      },
      {
        'title': 'New Employee',
        'message': 'Rahul joined your team',
        'time': '2 hours ago',
        'read': true,
      },
      {
        'title': 'System Update',
        'message': 'New features available',
        'time': '1 day ago',
        'read': true,
      },
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDarkMode
                        ? AppColors.textInverse
                        : AppColors.primary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Icon(
                  Icons.notifications_active_rounded,
                  color: isDarkMode ? AppColors.textInverse : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    color: isDarkMode
                        ? AppColors.textInverse
                        : AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: notification['read'] as bool
                        ? isDarkMode
                              ? AppColors.surfaceVariantDark
                              : AppColors.grey100
                        : isDarkMode
                        ? AppColors.accent.withOpacity(0.2)
                        : AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notification['read'] as bool
                          ? isDarkMode
                                ? AppColors.grey700
                                : AppColors.grey300
                          : isDarkMode
                          ? AppColors.accent.withOpacity(0.4)
                          : AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: notification['read'] as bool
                              ? Colors.transparent
                              : AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['title'] as String,
                              style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.textInverse
                                    : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['message'] as String,
                              style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.grey400
                                    : AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification['time'] as String,
                              style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.grey500
                                    : AppColors.textDisabled,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
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

  // void _showLogoutConfirmation(BuildContext context) {
  //   final theme = Provider.of<AppTheme>(context);
  //   final bool isDarkMode = theme.isDarkMode;

  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       backgroundColor: Colors.transparent,
  //       child: Container(
  //         padding: const EdgeInsets.all(24),
  //         decoration: BoxDecoration(
  //           color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
  //           borderRadius: BorderRadius.circular(20),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.3),
  //               blurRadius: 20,
  //               offset: const Offset(0, 10),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               'LOGOUT',
  //               style: TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.w700,
  //                 color: isDarkMode
  //                     ? AppColors.textInverse
  //                     : AppColors.textPrimary,
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             Text(
  //               'Are you sure you want to logout?',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: isDarkMode
  //                     ? AppColors.grey400
  //                     : AppColors.textSecondary,
  //                 height: 1.4,
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                         color: isDarkMode
  //                             ? AppColors.grey700
  //                             : AppColors.grey300,
  //                       ),
  //                     ),
  //                     child: TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       style: TextButton.styleFrom(
  //                         backgroundColor: isDarkMode
  //                             ? AppColors.surfaceVariantDark
  //                             : AppColors.grey50,
  //                         padding: const EdgeInsets.symmetric(vertical: 16),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                       ),
  //                       child: Text(
  //                         'CANCEL',
  //                         style: TextStyle(
  //                           color: isDarkMode
  //                               ? AppColors.textInverse
  //                               : AppColors.textPrimary,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: AppColors.error,
  //                       borderRadius: BorderRadius.circular(12),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: AppColors.error.withOpacity(0.3),
  //                           blurRadius: 10,
  //                           offset: const Offset(0, 5),
  //                         ),
  //                       ],
  //                     ),
  //                     child: TextButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         // Add your logout logic here
  //                       },
  //                       style: TextButton.styleFrom(
  //                         backgroundColor: Colors.transparent,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         padding: const EdgeInsets.symmetric(vertical: 16),
  //                       ),
  //                       child: Text(
  //                         'LOGOUT',
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontWeight: FontWeight.w600,
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
  //     ),
  //   );
  // }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LOGOUT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Add your logout logic here
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final bool isDarkMode = theme.isDarkMode;

    // Safe colors that work in both themes
    final backgroundColor = isDarkMode
        ? Colors.black
        : AppColors.backgroundLight;
    // final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    // final cardColor = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white;
    // final inputFillColor = isDarkMode
    //     ? Colors.white.withOpacity(0.1)
    //     : AppColors.grey50;
    // final borderColor = isDarkMode
    //     ? Colors.white.withOpacity(0.2)
    //     : AppColors.grey300;
    // final hintColor = isDarkMode
    //     ? Colors.white.withOpacity(0.5)
    //     : AppColors.textDisabled;
    // final secondaryTextColor = isDarkMode
    //     ? Colors.white.withOpacity(0.8)
    //     : AppColors.textSecondary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: ManagerDrawer(
        user: widget.user,
        onLogout: () => _showLogoutConfirmation(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? RadialGradient(
                  center: Alignment.topLeft,
                  radius: 2.0,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.secondary.withOpacity(0.03),
                    AppColors.backgroundLight,
                  ],
                ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          // Profile Header
                          _buildProfileHeader(),

                          const SizedBox(height: 5),

                          // Date & Time Section
                          _buildDateTimeSection(isDarkMode),
                          _buildWhiteHorizontalLine(isDarkMode),

                          const SizedBox(height: 2),

                          //Present Card Section
                          _buildpresentdashboardCards(),

                          const SizedBox(height: 2),

                          // METRICS COUNTER Cards
                          _buildMetricsCounterCards(),
                          const SizedBox(height: 2),
                          // _buildWhiteHorizontalLine(isDarkMode),
                          // _buildWhiteHorizontalLine(isDarkMode),
                          // Premium Dashboard Cards
                          _buildDashboardCards(),

                          const SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: _currentIndex,
        onTabChanged: _handleTabChange,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.menu_rounded, color: Colors.white, size: 20),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getUserTypeDisplay(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipOval(
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Notification Icon
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _showNotifications(context),
                ),
              ),
              if (_showNotificationBadge && _notificationCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.grey700 : AppColors.grey200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFormattedDate(),
                style: TextStyle(
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _currentTime,
                style: TextStyle(
                  color: isDarkMode
                      ? AppColors.grey400
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteHorizontalLine(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: isDarkMode ? AppColors.white : AppColors.backgroundDark,
    );
  }

  Widget _buildDateTimeItem({required String value, bool isLive = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (isLive)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildAttendanceTimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const AttendanceTimerSection(),
    );
  }

  Widget whiteHorizontalLine({
    double height = 1.0,
    double thickness = 1.0,
    Color color = Colors.white,
    double opacity = 0.3,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color.withOpacity(opacity),
            width: thickness,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsCounterCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: MetricsCounter(
        totalAttendance: _calculateDynamicAttendance(),
        teamMembers: _getDynamicTeamSize(),
        projects: _getDynamicProjectCount(),
        timeline: _getCurrentTimeline(),
      ),
    );
  }

  // Helper methods for dynamic data
  int _calculateDynamicAttendance() {
    final now = DateTime.now();
    return (now.day * now.hour) ~/ 2;
  }

  int _getDynamicTeamSize() {
    return 8 + (DateTime.now().day % 5);
  }

  int _getDynamicProjectCount() {
    final now = DateTime.now();
    return 5 + (now.weekday % 3);
  }

  String _getCurrentTimeline() {
    final now = DateTime.now();
    final quarter = ((now.month - 1) ~/ 3) + 1;
    return 'Q$quarter ${now.year}';
  }

  Widget _buildDashboardCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const DashboardCardsSection(),
    );
  }

  Widget _buildpresentdashboardCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: const PresentDashboardCardSection(),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)} ${now.year}';
  }

  String _getLiveTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  String _getUserTypeDisplay() {
    switch (widget.user.userType.toLowerCase()) {
      case 'manager':
        return 'MANAGER';
      case 'admin':
        return 'ADMIN';
      case 'employee':
        return 'EMPLOYEE';
      case 'supervisor':
        return 'SUPERVISOR';
      default:
        return widget.user.userType.toUpperCase();
    }
  }

  String _getWeekday(int weekday) {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return months[month - 1];
  }
}

// import 'dart:async';

// import 'package:attendanceapp/views/managerviews/leavescreen.dart';
// import 'package:attendanceapp/views/managerviews/manager_regularisation_screen.dart';
// import 'package:attendanceapp/views/managerviews/regularisation_screen.dart';
// import 'package:attendanceapp/views/managerviews/timeline.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/manager_drawer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/matrix_counter.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/presentdashboard.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/attendance_timer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/dashboard_cards.dart';

// class ManagerDashboardScreen extends StatefulWidget {
//   final User user;

//   const ManagerDashboardScreen({super.key, required this.user});

//   @override
//   _ManagerDashboardScreenState createState() => _ManagerDashboardScreenState();
// }

// class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
//     with TickerProviderStateMixin {
//   String _currentTime = '';
//   Timer? _timer;
//   late TabController _tabController;
//   int _currentIndex = 0;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;

//   // Notification variables
//   int _notificationCount = 3;
//   bool _showNotificationBadge = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeAnimations();
//     _initializeDashboard();
//     _startLiveTime();
//   }

//   // Navigation handle करने का method add करें
//   void _handleTabChange(int index) {
//     setState(() {
//       _currentIndex = index;
//     });

//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ManagerRegularisationScreen(user: widget.user),
//         ),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => LeaveScreen(user: widget.user)),
//       );
//     } else if (index == 3) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TimelineScreen(user: widget.user),
//         ),
//       );
//     } else {
//       _tabController.animateTo(index);
//     }
//   }

//   void _startLiveTime() {
//     _updateTime();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _updateTime();
//     });
//   }

//   void _updateTime() {
//     if (mounted) {
//       setState(() {
//         _currentTime = _getLiveTime();
//       });
//     }
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     _scaleAnimation = Tween<double>(
//       begin: 0.95,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();
//   }

//   void _initializeDashboard() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.initializeDashboard(widget.user);
//     });
//   }

//   void _showNotifications(BuildContext context) {
//     setState(() {
//       _notificationCount = 0;
//       _showNotificationBadge = false;
//     });

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => _buildNotificationsSheet(),
//     );
//   }

//   Widget _buildNotificationsSheet() {
//     final theme = Provider.of<AppTheme>(context);
//     final bool isDarkMode = theme.isDarkMode;

//     final notifications = [
//       {
//         'title': 'Team Meeting',
//         'message': 'Scheduled for 3:00 PM today',
//         'time': '10 min ago',
//         'read': false,
//       },
//       {
//         'title': 'Report Generated',
//         'message': 'Monthly attendance report is ready',
//         'time': '1 hour ago',
//         'read': false,
//       },
//       {
//         'title': 'New Employee',
//         'message': 'Rahul joined your team',
//         'time': '2 hours ago',
//         'read': true,
//       },
//       {
//         'title': 'System Update',
//         'message': 'New features available',
//         'time': '1 day ago',
//         'read': true,
//       },
//     ];

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.8,
//       decoration: BoxDecoration(
//         color: isDarkMode ? AppColors.primary.withOpacity(0.95) : Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: isDarkMode
//                   ? Colors.white.withOpacity(0.1)
//                   : AppColors.primary.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.close_rounded,
//                     color: isDarkMode ? Colors.white : AppColors.primary,
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.notifications_active_rounded,
//                   color: isDarkMode ? Colors.white : AppColors.primary,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'NOTIFICATIONS',
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.white : AppColors.primary,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final notification = notifications[index];
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: notification['read'] as bool
//                         ? isDarkMode
//                               ? Colors.white.withOpacity(0.1)
//                               : AppColors.grey100
//                         : isDarkMode
//                         ? AppColors.accent.withOpacity(0.2)
//                         : AppColors.accent.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: notification['read'] as bool
//                           ? isDarkMode
//                                 ? Colors.white.withOpacity(0.2)
//                                 : AppColors.grey300
//                           : isDarkMode
//                           ? AppColors.accent.withOpacity(0.4)
//                           : AppColors.accent.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: notification['read'] as bool
//                               ? Colors.transparent
//                               : AppColors.accent,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               notification['title'] as String,
//                               style: TextStyle(
//                                 color: isDarkMode
//                                     ? Colors.white
//                                     : AppColors.textPrimary,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               notification['message'] as String,
//                               style: TextStyle(
//                                 color: isDarkMode
//                                     ? Colors.white.withOpacity(0.8)
//                                     : AppColors.textSecondary,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               notification['time'] as String,
//                               style: TextStyle(
//                                 color: isDarkMode
//                                     ? Colors.white.withOpacity(0.6)
//                                     : AppColors.textDisabled,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final bool isDarkMode = theme.isDarkMode;

//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: isDarkMode
//                 ? AppColors.primary.withOpacity(0.95)
//                 : Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'LOGOUT',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   color: isDarkMode ? Colors.white : AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Are you sure you want to logout?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: isDarkMode
//                       ? Colors.white.withOpacity(0.9)
//                       : AppColors.textSecondary,
//                   height: 1.4,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isDarkMode
//                               ? Colors.white.withOpacity(0.3)
//                               : AppColors.grey300,
//                         ),
//                       ),
//                       child: TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: TextButton.styleFrom(
//                           backgroundColor: isDarkMode
//                               ? Colors.white.withOpacity(0.1)
//                               : AppColors.grey50,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           'CANCEL',
//                           style: TextStyle(
//                             color: isDarkMode
//                                 ? Colors.white
//                                 : AppColors.textPrimary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.error,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.error.withOpacity(0.3),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           // Add your logout logic here
//                         },
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         child: Text(
//                           'LOGOUT',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final bool isDarkMode = theme.isDarkMode;

//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.transparent,
//       drawer: ManagerDrawer(
//         user: widget.user,
//         onLogout: () => _showLogoutConfirmation(context),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: isDarkMode
//               ? RadialGradient(
//                   center: Alignment.topLeft,
//                   radius: 2.0,
//                   colors: [
//                     AppColors.primary.withOpacity(0.15),
//                     AppColors.secondary.withOpacity(0.1),
//                     Colors.black,
//                   ],
//                   stops: const [0.0, 0.5, 1.0],
//                 )
//               : LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     AppColors.primary.withOpacity(0.05),
//                     AppColors.secondary.withOpacity(0.03),
//                     AppColors.backgroundLight,
//                   ],
//                 ),
//         ),
//         child: SafeArea(
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, child) {
//               return FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: SlideTransition(
//                   position: _slideAnimation,
//                   child: ScaleTransition(
//                     scale: _scaleAnimation,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.only(bottom: 20),
//                       child: Column(
//                         children: [
//                           // Profile Header
//                           _buildProfileHeader(),

//                           const SizedBox(height: 5),

//                           // Date & Time Section
//                           _buildDateTimeSection(isDarkMode),
//                           _buildWhiteHorizontalLine(isDarkMode),

//                           const SizedBox(height: 2),

//                           //Present Card Section
//                           _buildpresentdashboardCards(),

//                           const SizedBox(height: 2),

//                           // METRICS COUNTER Cards
//                           _buildMetricsCounterCards(),
//                           const SizedBox(height: 2),
//                           // _buildWhiteHorizontalLine(isDarkMode),
//                           // _buildWhiteHorizontalLine(isDarkMode),
//                           // Premium Dashboard Cards
//                           _buildDashboardCards(),

//                           const SizedBox(height: 2),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: _currentIndex,
//         onTabChanged: _handleTabChange,
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.primary, AppColors.primaryDark],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Menu Icon
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.25),
//                 width: 1,
//               ),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.menu_rounded, color: Colors.white, size: 20),
//               onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//             ),
//           ),
//           const SizedBox(width: 16),

//           // Profile Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   widget.user.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   widget.user.email,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     _getUserTypeDisplay(),
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // User Avatar
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 ClipOval(
//                   child: Container(
//                     color: Colors.white.withOpacity(0.1),
//                     child: Icon(
//                       Icons.person,
//                       color: Colors.white.withOpacity(0.8),
//                       size: 24,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 2,
//                   right: 2,
//                   child: Container(
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade500,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 1.5),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Notification Icon
//           Stack(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.25),
//                     width: 1,
//                   ),
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.notifications_outlined,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                   onPressed: () => _showNotifications(context),
//                 ),
//               ),
//               if (_showNotificationBadge && _notificationCount > 0)
//                 Positioned(
//                   right: 10,
//                   top: 10,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade400,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 1.5),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateTimeSection(bool isDarkMode) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDarkMode ? Colors.white.withOpacity(0.2) : AppColors.grey200,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _getFormattedDate(),
//                 style: TextStyle(
//                   color: isDarkMode ? Colors.white : AppColors.textPrimary,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 _currentTime,
//                 style: TextStyle(
//                   color: isDarkMode
//                       ? Colors.white.withOpacity(0.8)
//                       : AppColors.textSecondary,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppColors.success.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: AppColors.success.withOpacity(0.3)),
//             ),
//             child: Text(
//               'LIVE',
//               style: TextStyle(
//                 color: AppColors.success,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWhiteHorizontalLine(bool isDarkMode) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       height: 1,
//       color: isDarkMode ? Colors.white.withOpacity(0.2) : AppColors.grey200,
//     );
//   }

//   Widget _buildDateTimeItem({required String value, bool isLive = false}) {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (isLive)
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: AppColors.accent,
//               shape: BoxShape.circle,
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAttendanceTimer() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const AttendanceTimerSection(),
//     );
//   }

//   Widget whiteHorizontalLine({
//     double height = 1.0,
//     double thickness = 1.0,
//     Color color = Colors.white,
//     double opacity = 0.3,
//     EdgeInsets margin = EdgeInsets.zero,
//   }) {
//     return Container(
//       height: height,
//       margin: margin,
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: color.withOpacity(opacity),
//             width: thickness,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricsCounterCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: MetricsCounter(
//         totalAttendance: _calculateDynamicAttendance(),
//         teamMembers: _getDynamicTeamSize(),
//         projects: _getDynamicProjectCount(),
//         timeline: _getCurrentTimeline(),
//       ),
//     );
//   }

//   // Helper methods for dynamic data
//   int _calculateDynamicAttendance() {
//     final now = DateTime.now();
//     return (now.day * now.hour) ~/ 2;
//   }

//   int _getDynamicTeamSize() {
//     return 8 + (DateTime.now().day % 5);
//   }

//   int _getDynamicProjectCount() {
//     final now = DateTime.now();
//     return 5 + (now.weekday % 3);
//   }

//   String _getCurrentTimeline() {
//     final now = DateTime.now();
//     final quarter = ((now.month - 1) ~/ 3) + 1;
//     return 'Q$quarter ${now.year}';
//   }

//   Widget _buildDashboardCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const DashboardCardsSection(),
//     );
//   }

//   Widget _buildpresentdashboardCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const PresentDashboardCardSection(),
//     );
//   }

//   String _getFormattedDate() {
//     final now = DateTime.now();
//     return '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)} ${now.year}';
//   }

//   String _getLiveTime() {
//     final now = DateTime.now();
//     return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
//   }

//   String _getUserTypeDisplay() {
//     switch (widget.user.userType.toLowerCase()) {
//       case 'manager':
//         return 'MANAGER';
//       case 'admin':
//         return 'ADMIN';
//       case 'employee':
//         return 'EMPLOYEE';
//       case 'supervisor':
//         return 'SUPERVISOR';
//       default:
//         return widget.user.userType.toUpperCase();
//     }
//   }

//   String _getWeekday(int weekday) {
//     const days = [
//       'MONDAY',
//       'TUESDAY',
//       'WEDNESDAY',
//       'THURSDAY',
//       'FRIDAY',
//       'SATURDAY',
//       'SUNDAY',
//     ];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'JANUARY',
//       'FEBRUARY',
//       'MARCH',
//       'APRIL',
//       'MAY',
//       'JUNE',
//       'JULY',
//       'AUGUST',
//       'SEPTEMBER',
//       'OCTOBER',
//       'NOVEMBER',
//       'DECEMBER',
//     ];
//     return months[month - 1];
//   }
// }

// import 'dart:async';

// import 'package:attendanceapp/views/managerviews/leavescreen.dart';
// import 'package:attendanceapp/views/managerviews/regularisation_screen.dart';
// import 'package:attendanceapp/views/managerviews/timeline.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/manager_drawer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/matrix_counter.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/presentdashboard.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/attendance_timer.dart';
// import 'package:attendanceapp/widgets/mangerwidgets/dashboard_cards.dart';

// class ManagerDashboardScreen extends StatefulWidget {
//   final User user;

//   const ManagerDashboardScreen({super.key, required this.user});

//   @override
//   _ManagerDashboardScreenState createState() => _ManagerDashboardScreenState();
// }

// class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
//     with TickerProviderStateMixin {
//   String _currentTime = '';
//   Timer? _timer;
//   late TabController _tabController;
//   int _currentIndex = 0;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;

//   // Notification variables
//   int _notificationCount = 3;
//   bool _showNotificationBadge = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _initializeAnimations();
//     _initializeDashboard();
//     _startLiveTime();
//   }

//   // Navigation handle करने का method add करें
//   void _handleTabChange(int index) {
//     setState(() {
//       _currentIndex = index;
//     });

//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => RegularisationScreen(user: widget.user),
//         ),
//       );
//     } else if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => LeaveScreen(user: widget.user)),
//       );
//     } else if (index == 3) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => TimelineScreen(user: widget.user),
//         ),
//       );
//     } else {
//       _tabController.animateTo(index);
//     }
//   }

//   void _startLiveTime() {
//     _updateTime();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _updateTime();
//     });
//   }

//   void _updateTime() {
//     if (mounted) {
//       setState(() {
//         _currentTime = _getLiveTime();
//       });
//     }
//   }

//   void _initializeAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

//     _scaleAnimation = Tween<double>(
//       begin: 0.95,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();
//   }

//   void _initializeDashboard() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<ManagerDashboardViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.initializeDashboard(widget.user);
//     });
//   }

//   void _showNotifications(BuildContext context) {
//     setState(() {
//       _notificationCount = 0;
//       _showNotificationBadge = false;
//     });

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => _buildNotificationsSheet(),
//     );
//   }

//   Widget _buildNotificationsSheet() {
//     final notifications = [
//       {
//         'title': 'Team Meeting',
//         'message': 'Scheduled for 3:00 PM today',
//         'time': '10 min ago',
//         'read': false,
//       },
//       {
//         'title': 'Report Generated',
//         'message': 'Monthly attendance report is ready',
//         'time': '1 hour ago',
//         'read': false,
//       },
//       {
//         'title': 'New Employee',
//         'message': 'Rahul joined your team',
//         'time': '2 hours ago',
//         'read': true,
//       },
//       {
//         'title': 'System Update',
//         'message': 'New features available',
//         'time': '1 day ago',
//         'read': true,
//       },
//     ];

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.8,
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.95),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.close_rounded, color: Colors.white),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.notifications_active_rounded,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'NOTIFICATIONS',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: notifications.length,
//               itemBuilder: (context, index) {
//                 final notification = notifications[index];
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: notification['read'] as bool
//                         ? Colors.white.withOpacity(0.1)
//                         : AppColors.accent.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: notification['read'] as bool
//                           ? Colors.white.withOpacity(0.2)
//                           : AppColors.accent.withOpacity(0.4),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: notification['read'] as bool
//                               ? Colors.transparent
//                               : AppColors.accent,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               notification['title'] as String,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               notification['message'] as String,
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontSize: 14,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               notification['time'] as String,
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.6),
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.95),
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'LOGOUT',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Are you sure you want to logout?',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white.withOpacity(0.9),
//                   height: 1.4,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.3),
//                         ),
//                       ),
//                       child: TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.white.withOpacity(0.1),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           'CANCEL',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.error,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.error.withOpacity(0.3),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           // Add your logout logic here
//                         },
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         child: Text(
//                           'LOGOUT',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);

//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.transparent,
//       drawer: ManagerDrawer(
//         user: widget.user,
//         onLogout: () => _showLogoutConfirmation(context),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: RadialGradient(
//             center: Alignment.topLeft,
//             radius: 2.0,
//             colors: [
//               AppColors.primary.withOpacity(0.15),
//               AppColors.secondary.withOpacity(0.1),
//               Colors.black,
//             ],
//             stops: const [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (context, child) {
//               return FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: SlideTransition(
//                   position: _slideAnimation,
//                   child: ScaleTransition(
//                     scale: _scaleAnimation,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.only(bottom: 20),
//                       child: Column(
//                         children: [
//                           // Profile Header
//                           _buildProfileHeader(),

//                           const SizedBox(height: 5),

//                           // Date & Time Section
//                           _buildDateTimeSection(),
//                           whiteHorizontalLine(),

//                           const SizedBox(height: 2),

//                           //Present Card Section
//                           _buildpresentdashboardCards(),

//                           const SizedBox(height: 2),

//                           // METRICS COUNTER Cards
//                           _buildMetricsCounterCards(),
//                           const SizedBox(height: 2),
//                           // whiteHorizontalLine(),
//                           // whiteHorizontalLine(),
//                           // Premium Dashboard Cards
//                           _buildDashboardCards(),

//                           const SizedBox(height: 2),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: _currentIndex,
//         onTabChanged: _handleTabChange,
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.primary, AppColors.primaryDark],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Menu Icon
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.25),
//                 width: 1,
//               ),
//             ),
//             child: IconButton(
//               icon: Icon(Icons.menu_rounded, color: Colors.white, size: 20),
//               onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//             ),
//           ),
//           const SizedBox(width: 16),

//           // Profile Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   widget.user.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   widget.user.email,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     _getUserTypeDisplay(),
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.9),
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // User Avatar
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 ClipOval(
//                   child: Container(
//                     color: Colors.white.withOpacity(0.1),
//                     child: Icon(
//                       Icons.person,
//                       color: Colors.white.withOpacity(0.8),
//                       size: 24,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 2,
//                   right: 2,
//                   child: Container(
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade500,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 1.5),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Notification Icon
//           Stack(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.25),
//                     width: 1,
//                   ),
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.notifications_outlined,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                   onPressed: () => _showNotifications(context),
//                 ),
//               ),
//               if (_showNotificationBadge && _notificationCount > 0)
//                 Positioned(
//                   right: 10,
//                   top: 10,
//                   child: Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade400,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 1.5),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildDateTimeSection() {
//   //   return Container(
//   //     margin: const EdgeInsets.symmetric(horizontal: 16),
//   //     padding: const EdgeInsets.all(20),
//   //     // decoration: BoxDecoration(
//   //     //   borderRadius: BorderRadius.circular(16),
//   //     //   color: Colors.white.withOpacity(0.1),
//   //     //   border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
//   //     //   boxShadow: [
//   //     //     BoxShadow(
//   //     //       color: Colors.black.withOpacity(0.2),
//   //     //       blurRadius: 10,
//   //     //       offset: const Offset(0, 5),
//   //     //     ),
//   //     //   ],
//   //     // ),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //       children: [
//   //         // Date and Time
//   //         Expanded(
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               // Date Section
//   //               _buildDateTimeItem(
//   //                 icon: Icons.calendar_month_rounded,
//   //                 title: 'DATE',
//   //                 value: _getFormattedDate(),
//   //               ),
//   //               const SizedBox(height: 16),

//   //               // Time Section
//   //               _buildDateTimeItem(
//   //                 icon: Icons.access_time_filled_rounded,
//   //                 title: 'TIME',
//   //                 value: _getLiveTime(),
//   //                 isLive: true,
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Widget _buildDateTimeItem({
//   //   required IconData icon,
//   //   required String title,
//   //   required String value,
//   //   bool isLive = false,
//   // }) {
//   //   return Row(
//   //     children: [
//   //       Container(
//   //         width: 44,
//   //         height: 44,
//   //         decoration: BoxDecoration(
//   //           color: AppColors.primary,
//   //           borderRadius: BorderRadius.circular(12),
//   //           boxShadow: [
//   //             BoxShadow(
//   //               color: AppColors.primary.withOpacity(0.2),
//   //               blurRadius: 8,
//   //               offset: const Offset(0, 4),
//   //             ),
//   //           ],
//   //         ),
//   //         child: Icon(icon, color: Colors.white, size: 20),
//   //       ),
//   //       const SizedBox(width: 16),
//   //       Expanded(
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Text(
//   //               title,
//   //               style: TextStyle(
//   //                 fontSize: 13,
//   //                 fontWeight: FontWeight.w600,
//   //                 color: Colors.white.withOpacity(0.8),
//   //               ),
//   //             ),
//   //             const SizedBox(height: 4),
//   //             Text(
//   //               value,
//   //               style: const TextStyle(
//   //                 fontSize: 16,
//   //                 fontWeight: FontWeight.w700,
//   //                 color: Colors.white,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //       if (isLive)
//   //         Container(
//   //           width: 8,
//   //           height: 8,
//   //           decoration: BoxDecoration(
//   //             color: AppColors.accent,
//   //             shape: BoxShape.circle,
//   //           ),
//   //         ),
//   //     ],
//   //   );
//   // }

//   Widget _buildDateTimeSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       // decoration: BoxDecoration(
//       //   borderRadius: BorderRadius.circular(16),
//       //   color: Colors.white.withOpacity(0.1),
//       //   border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
//       //   boxShadow: [
//       //     BoxShadow(
//       //       color: Colors.black.withOpacity(0.2),
//       //       blurRadius: 10,
//       //       offset: const Offset(0, 5),
//       //     ),
//       //   ],
//       // ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Date and Time
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 // Time Section
//                 _buildDateTimeItem(value: _getLiveTime(), isLive: true),
//                 const SizedBox(height: 16),
//                 // Date Section
//                 _buildDateTimeItem(value: _getFormattedDate()),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateTimeItem({required String value, bool isLive = false}) {
//     return Row(
//       children: [
//         // Container(
//         //   width: 44,
//         //   height: 44,
//         //   decoration: BoxDecoration(
//         //     color: AppColors.primary,
//         //     borderRadius: BorderRadius.circular(12),
//         //     boxShadow: [
//         //       BoxShadow(
//         //         color: AppColors.primary.withOpacity(0.2),
//         //         blurRadius: 8,
//         //         offset: const Offset(0, 4),
//         //       ),
//         //     ],
//         //   ),
//         //   // child: Icon(
//         //   //   Icons.access_time_filled_rounded,
//         //   //   color: Colors.white,
//         //   //   size: 20,
//         //   // ),
//         // ),
//         //const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (isLive)
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: AppColors.accent,
//               shape: BoxShape.circle,
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAttendanceTimer() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const AttendanceTimerSection(),
//     );
//   }

//   Widget whiteHorizontalLine({
//     double height = 1.0,
//     double thickness = 1.0,
//     Color color = Colors.white,
//     double opacity = 0.3,
//     EdgeInsets margin = EdgeInsets.zero,
//   }) {
//     return Container(
//       height: height,
//       margin: margin,
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: color.withOpacity(opacity),
//             width: thickness,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricsCounterCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: MetricsCounter(
//         totalAttendance: _calculateDynamicAttendance(),
//         teamMembers: _getDynamicTeamSize(),
//         projects: _getDynamicProjectCount(),
//         timeline: _getCurrentTimeline(),
//       ),
//     );
//   }

//   // Helper methods for dynamic data
//   int _calculateDynamicAttendance() {
//     final now = DateTime.now();
//     return (now.day * now.hour) ~/ 2;
//   }

//   int _getDynamicTeamSize() {
//     return 8 + (DateTime.now().day % 5);
//   }

//   int _getDynamicProjectCount() {
//     final now = DateTime.now();
//     return 5 + (now.weekday % 3);
//   }

//   String _getCurrentTimeline() {
//     final now = DateTime.now();
//     final quarter = ((now.month - 1) ~/ 3) + 1;
//     return 'Q$quarter ${now.year}';
//   }

//   Widget _buildDashboardCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const DashboardCardsSection(),
//     );
//   }

//   Widget _buildpresentdashboardCards() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       child: const PresentDashboardCardSection(),
//     );
//   }

//   String _getFormattedDate() {
//     final now = DateTime.now();
//     return '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)} ${now.year}';
//   }

//   String _getLiveTime() {
//     final now = DateTime.now();
//     return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
//   }

//   String _getUserTypeDisplay() {
//     switch (widget.user.userType.toLowerCase()) {
//       case 'manager':
//         return 'MANAGER';
//       case 'admin':
//         return 'ADMIN';
//       case 'employee':
//         return 'EMPLOYEE';
//       case 'supervisor':
//         return 'SUPERVISOR';
//       default:
//         return widget.user.userType.toUpperCase();
//     }
//   }

//   String _getWeekday(int weekday) {
//     const days = [
//       'MONDAY',
//       'TUESDAY',
//       'WEDNESDAY',
//       'THURSDAY',
//       'FRIDAY',
//       'SATURDAY',
//       'SUNDAY',
//     ];
//     return days[weekday - 1];
//   }

//   String _getMonth(int month) {
//     const months = [
//       'JANUARY',
//       'FEBRUARY',
//       'MARCH',
//       'APRIL',
//       'MAY',
//       'JUNE',
//       'JULY',
//       'AUGUST',
//       'SEPTEMBER',
//       'OCTOBER',
//       'NOVEMBER',
//       'DECEMBER',
//     ];
//     return months[month - 1];
//   }
// }

/* ######################################################################################################################

***********************************************         A I S C R E E N C O D E            *******************************

#############################################################################################################################  */
