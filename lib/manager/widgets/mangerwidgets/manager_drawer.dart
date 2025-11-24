// widgets/manager/manager_drawer.dart
import 'package:attendanceapp/manager/views/managerviews/attendance_detail_screen.dart';
import 'package:attendanceapp/manager/views/managerviews/employee_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:attendanceapp/manager/models/user_model.dart';
import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:provider/provider.dart';

class ManagerDrawer extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const ManagerDrawer({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final drawerWidth = (constraints.maxWidth * 0.85).clamp(280.0, 540.0);

        return Drawer(
          width: drawerWidth,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade900.withOpacity(0.95),
                  Colors.purple.shade800.withOpacity(0.9),
                  Colors.deepPurple.shade900.withOpacity(0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade700.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 10),
                    _buildMenuSection(context, theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------  HEADER --------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          //  Avatar
          Stack(
            children: [
              // Outer Glow
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan.shade400.withOpacity(0.8),
                      Colors.blue.shade400.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.shade400.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
              // Profile Container
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Online Status
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade400.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Info
          Text(
            user.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getRoleTitle(),
            style: TextStyle(
              color: Colors.cyan.shade300,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 15),

          //  Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.shade400.withOpacity(0.3),
                  Colors.blue.shade400.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.shade400.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Colors.cyan.shade300,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getBadgeText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------  MENU SECTION --------------------
  Widget _buildMenuSection(BuildContext context, AppTheme theme) {
    final menuItems = [
      _MenuItem(
        icon: Icons.dashboard_rounded,
        title: ' DASHBOARD',
        subtitle: '',
        color: Colors.cyan.shade400,
        onTap: () => Navigator.pop(context),
      ),
      _MenuItem(
        icon: Icons.calendar_today_rounded,
        title: 'ATTENDANCE',
        subtitle: '',
        color: Colors.blue.shade400,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AttendanceDetailScreen(),
          ),
        ),
      ),
      _MenuItem(
        icon: Icons.analytics_rounded,
        title: 'TEAM MEMBERS',
        subtitle: '',
        color: Colors.green.shade400,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
        ),
      ),
      // _MenuItem(
      //   icon: Icons.work_history_rounded,
      //   title: 'PROJECT',
      //   subtitle: '',
      //   color: Colors.orange.shade400,
      //   onTap: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const ProjectDetailScreen()),
      //   ),
      // ),
      _MenuItem(
        icon: Icons.settings_rounded,
        title: 'APP SETTING',
        subtitle: '',
        color: Colors.purple.shade400,
        onTap: () => Navigator.pop(context),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.themeMode == ThemeMode.dark
            ? Colors.grey.shade900.withOpacity(0.9)
            : Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 25),
          //  Menu Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan.shade400, Colors.blue.shade400],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'NAVIGATION',
                  style: TextStyle(
                    color: theme.themeMode == ThemeMode.dark
                        ? Colors.cyan.shade300
                        : Colors.blue.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          //  Menu Items
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: menuItems.length,
            itemBuilder: (context, index) =>
                _buildMenuItem(menuItems[index], theme),
          ),
          const SizedBox(height: 20),
          _buildLogoutButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --------------------  LOGOUT BUTTON --------------------
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.red.shade600, Colors.orange.shade600],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade600.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onLogout,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOGOUT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        // const SizedBox(height: 2),
                        // Text(
                        //   'Disconnect from neural network',
                        //   style: TextStyle(
                        //     color: Colors.white.withOpacity(0.9),
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------  MENU ITEM --------------------
  Widget _buildMenuItem(_MenuItem item, AppTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [item.color.withOpacity(0.15), item.color.withOpacity(0.05)],
        ),
        border: Border.all(color: item.color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item.color.withOpacity(0.3),
                        item.color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.color.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(width: 15),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.themeMode == ThemeMode.dark
                              ? Colors.white
                              : Colors.grey.shade800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.themeMode == ThemeMode.dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------  TEXT HELPERS --------------------
  String _getRoleTitle() {
    final type = user.userType.trim().toLowerCase();
    switch (type) {
      case 'manager':
        return ' MANAGER';
      case 'admin':
        return 'SYSTEM ADMIN';
      case 'supervisor':
        return 'TEAM LEADER';
      default:
        return ' USER';
    }
  }

  String _getBadgeText() {
    final type = user.userType.trim().toLowerCase();
    switch (type) {
      case 'manager':
        return 'MANAGER';
      case 'admin':
        return 'SYSTEM ADMIN';
      case 'supervisor':
        return 'TEAM LEAD';
      default:
        return ' USER';
    }
  }
}

// --------------------  MENU ITEM MODEL --------------------
class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

// // widgets/manager/manager_drawer.dart
// import 'package:attendanceapp/views/managerviews/attendance_detail_screen.dart';
// import 'package:attendanceapp/views/managerviews/employee_list_screen.dart';
// import 'package:attendanceapp/views/managerviews/project_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:provider/provider.dart';

// class ManagerDrawer extends StatelessWidget {
//   final User user;
//   final VoidCallback onLogout;

//   const ManagerDrawer({super.key, required this.user, required this.onLogout});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Use a fraction of available width, but guard min/max
//         final drawerWidth = (constraints.maxWidth * 0.85).clamp(280.0, 540.0);

//         return Drawer(
//           width: drawerWidth,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: AppColors.gradientColors,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primary.withOpacity(0.3),
//                   blurRadius: 20,
//                   spreadRadius: 2,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: SafeArea(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     _buildDrawerHeader(),
//                     const SizedBox(height: 10),
//                     _buildMenuSection(context, theme),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // -------------------- HEADER --------------------
//   Widget _buildDrawerHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
//       child: Column(
//         children: [
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [AppColors.white, AppColors.white.withOpacity(0.8)],
//               ),
//               border: Border.all(color: AppColors.white, width: 4),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primary.withOpacity(0.3),
//                   blurRadius: 15,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Stack(
//               children: [
//                 const Center(
//                   child: Icon(
//                     Icons.person_rounded,
//                     size: 45,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 Positioned(
//                   right: 8,
//                   bottom: 8,
//                   child: Container(
//                     width: 18,
//                     height: 18,
//                     decoration: BoxDecoration(
//                       color: AppColors.success,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: AppColors.white, width: 3),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.success.withOpacity(0.5),
//                           blurRadius: 8,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 15),
//           Text(
//             user.name,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 0.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             user.email,
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.9),
//               fontSize: 13,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             _getFormattedUserType(),
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.9),
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppColors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: AppColors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.verified_rounded,
//                   color: AppColors.white,
//                   size: 14,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   _getUserBadgeText(),
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // -------------------- USER TYPE --------------------
//   String _getFormattedUserType() {
//     try {
//       final type = user.userType.trim().toLowerCase();
//       switch (type) {
//         case 'manager':
//           return 'Manager';
//         case 'admin':
//           return 'Administrator';
//         case 'employee':
//           return 'Employee';
//         case 'supervisor':
//           return 'Supervisor';
//         default:
//           return user.userType;
//       }
//     } catch (e) {
//       return '';
//     }
//   }

//   String _getUserBadgeText() {
//     try {
//       final type = user.userType.trim().toLowerCase();
//       switch (type) {
//         case 'manager':
//           return 'MANAGER PROFILE';
//         case 'admin':
//           return 'ADMIN PROFILE';
//         case 'employee':
//           return 'EMPLOYEE PROFILE';
//         case 'supervisor':
//           return 'SUPERVISOR PROFILE';
//         default:
//           return 'USER PROFILE';
//       }
//     } catch (e) {
//       return 'USER PROFILE';
//     }
//   }

//   // -------------------- MENU SECTION --------------------
//   Widget _buildMenuSection(BuildContext context, AppTheme theme) {
//     final menuItems = [
//       _MenuItem(
//         icon: Icons.dashboard_rounded,
//         title: 'Dashboard',
//         subtitle: 'Main dashboard view',
//         color: AppColors.primary,
//         onTap: () => Navigator.pop(context),
//       ),

//       _MenuItem(
//         icon: Icons.calendar_today_rounded,
//         title: 'Attendance Details',
//         subtitle: '',
//         color: AppColors.warning,
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const AttendanceDetailScreen(),
//           ),
//         ),
//       ),
//       _MenuItem(
//         icon: Icons.analytics_rounded,
//         title: 'Employee Details',
//         subtitle: '',
//         color: AppColors.info,
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const EmployeeListScreen()),
//         ),
//       ),
//       _MenuItem(
//         icon: Icons.people_alt_rounded,
//         title: 'Project Details',
//         subtitle: '',
//         color: AppColors.secondary,
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const ProjectDetailsScreen()),
//         ),
//       ),
//       // _MenuItem(
//       //   icon: Icons.location_on_rounded,
//       //   title: 'Geofence Setup',
//       //   subtitle: 'Manage locations',
//       //   color: AppColors.success,
//       //   onTap: () => Navigator.pop(context),
//       // ),
//       _MenuItem(
//         icon: Icons.settings_rounded,
//         title: 'Settings',
//         subtitle: 'App preferences',
//         color: AppColors.grey600,
//         onTap: () => Navigator.pop(context),
//       ),
//     ];

//     return Container(
//       decoration: BoxDecoration(
//         color: theme.themeMode == ThemeMode.dark
//             ? AppColors.backgroundDark
//             : AppColors.backgroundLight,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 25),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.menu_rounded,
//                   color: theme.themeMode == ThemeMode.dark
//                       ? AppColors.primaryLight
//                       : AppColors.primary,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   'MAIN MENU',
//                   style: TextStyle(
//                     color: theme.themeMode == ThemeMode.dark
//                         ? AppColors.grey400
//                         : AppColors.textSecondary,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           // Using shrinkWrap ListView so whole drawer can scroll (SingleChildScrollView wraps parent)
//           ListView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             itemCount: menuItems.length,
//             itemBuilder: (context, index) =>
//                 _buildMenuItemCard(menuItems[index], theme),
//           ),
//           const SizedBox(height: 15),
//           _buildLogoutButton(),
//           const SizedBox(height: 15),
//         ],
//       ),
//     );
//   }

//   // -------------------- LOGOUT BUTTON --------------------
//   Widget _buildLogoutButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: LinearGradient(
//             colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.error.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ListTile(
//           leading: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppColors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(
//               Icons.logout_rounded,
//               color: AppColors.white,
//               size: 20,
//             ),
//           ),
//           title: const Text(
//             'Logout',
//             style: TextStyle(
//               color: AppColors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           subtitle: Text(
//             'Sign out from app',
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.8),
//               fontSize: 12,
//             ),
//           ),
//           trailing: Icon(
//             Icons.arrow_forward_ios_rounded,
//             color: AppColors.white.withOpacity(0.7),
//             size: 16,
//           ),
//           onTap: onLogout,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),
//       ),
//     );
//   }

//   // -------------------- MENU ITEM CARD --------------------
//   Widget _buildMenuItemCard(_MenuItem item, AppTheme theme) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 5),
//       elevation: theme.themeMode == ThemeMode.dark ? 4 : 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       color: theme.themeMode == ThemeMode.dark
//           ? AppColors.grey800
//           : AppColors.white,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             colors: [item.color.withOpacity(0.1), item.color.withOpacity(0.05)],
//           ),
//         ),
//         child: ListTile(
//           leading: Container(
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               color: item.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: item.color.withOpacity(0.2), width: 1),
//             ),
//             child: Icon(item.icon, color: item.color, size: 22),
//           ),
//           title: Text(
//             item.title,
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//               color: theme.themeMode == ThemeMode.dark
//                   ? AppColors.textInverse
//                   : AppColors.textPrimary,
//             ),
//           ),
//           subtitle: Text(
//             item.subtitle,
//             style: TextStyle(
//               fontSize: 12,
//               color: theme.themeMode == ThemeMode.dark
//                   ? AppColors.grey400
//                   : AppColors.textSecondary,
//             ),
//           ),
//           trailing: Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: item.color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 14,
//               color: item.color,
//             ),
//           ),
//           onTap: item.onTap,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 15,
//             vertical: 5,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // -------------------- MENU ITEM MODEL --------------------
// class _MenuItem {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final Color color;
//   final VoidCallback onTap;

//   _MenuItem({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.color,
//     required this.onTap,
//   });
// }
