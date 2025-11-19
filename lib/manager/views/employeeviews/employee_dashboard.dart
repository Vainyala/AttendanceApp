// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/view_models/theme_view_model.dart';
// import '../../models/user_model.dart';
// import '../../view_models/auth_view_model.dart';

// class EmployeeDashboardScreen extends StatelessWidget {
//   final User user;

//   const EmployeeDashboardScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final authViewModel = Provider.of<AuthViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.background,
//       appBar: AppBar(
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: theme.colorScheme.surface,
//         elevation: 0,
//         scrolledUnderElevation: 1,
//         shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.notifications_outlined,
//               color: theme.colorScheme.onSurface,
//             ),
//             onPressed: () {
//               _showComingSoonSnackbar(context, 'Notifications');
//             },
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'logout') {
//                 authViewModel.clearError();
//                 Navigator.pushReplacementNamed(context, '/login');
//               } else if (value == 'profile') {
//                 _showComingSoonSnackbar(context, 'Profile Settings');
//               }
//             },
//             icon: Icon(
//               Icons.more_vert_rounded,
//               color: theme.colorScheme.onSurface,
//             ),
//             itemBuilder: (BuildContext context) => [
//               PopupMenuItem<String>(
//                 value: 'profile',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.person_rounded,
//                       size: 20,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Profile',
//                       style: TextStyle(color: theme.colorScheme.onSurface),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.logout_rounded,
//                       size: 20,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Log Out',
//                       style: TextStyle(color: theme.colorScheme.onSurface),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // Welcome Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
//               child: _buildWelcomeSection(theme),
//             ),
//           ),

//           // Today's Status Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 "Today's Status",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildStatusGrid(theme),
//             ),
//           ),

//           // Quick Actions Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Quick Actions',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildActionsGrid(context, theme),
//             ),
//           ),

//           // Upcoming Events Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Upcoming Events',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildUpcomingEvents(theme),
//             ),
//           ),

//           // Recent Activities Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Recent Activities',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: theme.colorScheme.onBackground,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: _buildRecentActivities(theme),
//             ),
//           ),

//           // Bottom Padding
//           const SliverToBoxAdapter(child: SizedBox(height: 20)),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showComingSoonSnackbar(context, 'Quick Action');
//         },
//         backgroundColor: theme.colorScheme.primary,
//         foregroundColor: Colors.white,
//         child: const Icon(Icons.add_rounded),
//       ),
//     );
//   }

//   Widget _buildWelcomeSection(ThemeData theme) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primary,
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   user.name[0].toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome back,',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     user.name,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     'Employee',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: theme.colorScheme.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     user.email,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'Present',
//                 style: TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusGrid(ThemeData theme) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       children: [
//         _buildStatusCard(
//           theme,
//           'Check In',
//           '09:00 AM',
//           Icons.login_rounded,
//           Colors.green,
//         ),
//         _buildStatusCard(
//           theme,
//           'Check Out',
//           '--:--',
//           Icons.logout_rounded,
//           Colors.orange,
//         ),
//         _buildStatusCard(
//           theme,
//           'Hours Worked',
//           '8.5 hrs',
//           Icons.access_time_rounded,
//           Colors.blue,
//         ),
//         _buildStatusCard(
//           theme,
//           'Break Time',
//           '45 mins',
//           Icons.free_breakfast_rounded,
//           Colors.purple,
//         ),
//       ],
//     );
//   }

//   Widget _buildStatusCard(
//     ThemeData theme,
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 28, color: color),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionsGrid(BuildContext context, ThemeData theme) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       children: [
//         _buildActionCard(
//           context,
//           theme,
//           'Mark Attendance',
//           Icons.fingerprint_rounded,
//           theme.colorScheme.primary,
//         ),
//         _buildActionCard(
//           context,
//           theme,
//           'Apply Leave',
//           Icons.beach_access_rounded,
//           Colors.orange,
//         ),
//         _buildActionCard(
//           context,
//           theme,
//           'View Schedule',
//           Icons.calendar_today_rounded,
//           Colors.blue,
//         ),
//         _buildActionCard(
//           context,
//           theme,
//           'My Attendance',
//           Icons.analytics_rounded,
//           Colors.green,
//         ),
//       ],
//     );
//   }

//   Widget _buildActionCard(
//     BuildContext context,
//     ThemeData theme,
//     String title,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Material(
//         color: theme.colorScheme.surface,
//         child: InkWell(
//           onTap: () {
//             _showComingSoonSnackbar(context, title);
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, size: 32, color: color),
//                 const SizedBox(height: 12),
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUpcomingEvents(ThemeData theme) {
//     final events = [
//       {
//         'title': 'Team Meeting',
//         'subtitle': 'Today, 2:00 PM - Conference Room',
//         'icon': Icons.meeting_room_rounded,
//         'color': theme.colorScheme.primary,
//       },
//       {
//         'title': 'Project Deadline',
//         'subtitle': 'Tomorrow - Project Alpha',
//         'icon': Icons.assignment_rounded,
//         'color': Colors.orange,
//       },
//       {
//         'title': 'Training Session',
//         'subtitle': 'Friday, 10:00 AM - Training Room',
//         'icon': Icons.school_rounded,
//         'color': Colors.blue,
//       },
//       {
//         'title': 'Team Lunch',
//         'subtitle': 'Next Monday, 1:00 PM - Cafeteria',
//         'icon': Icons.restaurant_rounded,
//         'color': Colors.green,
//       },
//     ];

//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ...events.map(
//               (event) => _buildEventItem(
//                 theme,
//                 event['title'] as String,
//                 event['subtitle'] as String,
//                 event['icon'] as IconData,
//                 event['color'] as Color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEventItem(
//     ThemeData theme,
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 20, color: color),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentActivities(ThemeData theme) {
//     final activities = [
//       {
//         'title': 'Attendance marked',
//         'subtitle': 'Checked in at 9:00 AM today',
//         'icon': Icons.check_circle_rounded,
//         'color': Colors.green,
//       },
//       {
//         'title': 'Leave applied',
//         'subtitle': 'Sick leave approved for tomorrow',
//         'icon': Icons.verified_rounded,
//         'color': Colors.blue,
//       },
//       {
//         'title': 'Task completed',
//         'subtitle': 'Project Alpha milestone achieved',
//         'icon': Icons.assignment_turned_in_rounded,
//         'color': theme.colorScheme.primary,
//       },
//     ];

//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             ...activities.map(
//               (activity) => _buildActivityItem(
//                 theme,
//                 activity['title'] as String,
//                 activity['subtitle'] as String,
//                 activity['icon'] as IconData,
//                 activity['color'] as Color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActivityItem(
//     ThemeData theme,
//     String title,
//     String subtitle,
//     IconData icon,
//     Color color,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 20, color: color),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             '2h ago',
//             style: TextStyle(
//               fontSize: 13,
//               color: theme.colorScheme.onSurface.withOpacity(0.5),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showComingSoonSnackbar(BuildContext context, String featureName) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$featureName - Coming Soon!'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }

/*  #####################################################################################################################

***************************************         A I S C R E E N C O D E             *****************************************

############################################################################################################################ */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/view_models/theme_view_model.dart';
import '../../models/user_model.dart';
import '../../view_models/auth_view_model.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  final User user;

  const EmployeeDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: theme.themeMode == ThemeMode.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showComingSoonSnackbar(context, 'Notifications');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authViewModel.clearError();
                Navigator.pushReplacementNamed(context, '/login');
              } else if (value == 'profile') {
                _showComingSoonSnackbar(context, 'Profile Settings');
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 30,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user.name}!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Employee',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Text(
                        'Present',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Today's Status
            const Text(
              "Today's Status",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatusCard(
                  'Check In',
                  '09:00 AM',
                  Icons.login,
                  AppColors.success,
                ),
                _buildStatusCard(
                  'Check Out',
                  '--:--',
                  Icons.logout,
                  AppColors.warning,
                ),
                _buildStatusCard(
                  'Hours Worked',
                  '8.5 hrs',
                  Icons.access_time,
                  AppColors.info,
                ),
                _buildStatusCard(
                  'Break Time',
                  '45 mins',
                  Icons.free_breakfast,
                  AppColors.secondary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildActionCard(
                  'Mark Attendance',
                  Icons.fingerprint,
                  AppColors.primary,
                  () {
                    _showComingSoonSnackbar(context, 'Mark Attendance');
                  },
                ),
                _buildActionCard(
                  'Apply Leave',
                  Icons.beach_access,
                  AppColors.warning,
                  () {
                    _showComingSoonSnackbar(context, 'Leave Application');
                  },
                ),
                _buildActionCard(
                  'View Schedule',
                  Icons.calendar_today,
                  AppColors.info,
                  () {
                    _showComingSoonSnackbar(context, 'Work Schedule');
                  },
                ),
                _buildActionCard(
                  'My Attendance',
                  Icons.analytics,
                  AppColors.success,
                  () {
                    _showComingSoonSnackbar(context, 'Attendance History');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Upcoming Events
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEventItem(
                      'Team Meeting',
                      'Today, 2:00 PM - Conference Room',
                      Icons.meeting_room,
                      AppColors.primary,
                    ),
                    _buildEventItem(
                      'Project Deadline',
                      'Tomorrow - Project Alpha',
                      Icons.assignment,
                      AppColors.warning,
                    ),
                    _buildEventItem(
                      'Training Session',
                      'Friday, 10:00 AM - Training Room',
                      Icons.school,
                      AppColors.info,
                    ),
                    _buildEventItem(
                      'Team Lunch',
                      'Next Monday, 1:00 PM - Cafeteria',
                      Icons.restaurant,
                      AppColors.success,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Activities
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityItem(
                      'Attendance marked',
                      'Checked in at 9:00 AM today',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                    _buildActivityItem(
                      'Leave applied',
                      'Sick leave approved for tomorrow',
                      Icons.verified,
                      AppColors.info,
                    ),
                    _buildActivityItem(
                      'Task completed',
                      'Project Alpha milestone achieved',
                      Icons.assignment_turned_in,
                      AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showComingSoonSnackbar(context, 'Quick Action');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '2h ago',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Coming Soon!'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
