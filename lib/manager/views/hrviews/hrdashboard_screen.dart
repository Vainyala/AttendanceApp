// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/view_models/theme_view_model.dart';
// import '../../models/user_model.dart';
// import '../../view_models/auth_view_model.dart';

// class HRDashboardScreen extends StatelessWidget {
//   final User user;

//   const HRDashboardScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final authViewModel = Provider.of<AuthViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.background,
//       appBar: AppBar(
//         title: const Text(
//           'HR Dashboard',
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
//               }
//             },
//             icon: Icon(
//               Icons.more_vert_rounded,
//               color: theme.colorScheme.onSurface,
//             ),
//             itemBuilder: (BuildContext context) => [
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

//           // Quick Stats Section
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Text(
//                 'Overview',
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
//               child: _buildStatsGrid(theme),
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
//                     'HR Manager',
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
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsGrid(ThemeData theme) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       crossAxisSpacing: 12,
//       mainAxisSpacing: 12,
//       children: [
//         _buildStatCard(
//           theme,
//           'Total Employees',
//           '47',
//           Icons.people_alt_rounded,
//           theme.colorScheme.primary,
//         ),
//         _buildStatCard(
//           theme,
//           'Pending Leaves',
//           '12',
//           Icons.beach_access_rounded,
//           Colors.orange,
//         ),
//         _buildStatCard(
//           theme,
//           'New Hires',
//           '5',
//           Icons.person_add_rounded,
//           Colors.green,
//         ),
//         _buildStatCard(
//           theme,
//           'Attendance Issues',
//           '3',
//           Icons.warning_rounded,
//           Colors.red,
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(
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
//                 fontSize: 24,
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
//           'Manage Employees',
//           Icons.manage_accounts_rounded,
//           theme.colorScheme.primary,
//         ),
//         _buildActionCard(
//           context,
//           theme,
//           'Leave Approvals',
//           Icons.assignment_turned_in_rounded,
//           Colors.green,
//         ),
//         _buildActionCard(
//           context,
//           theme,
//           'Attendance Reports',
//           Icons.analytics_rounded,
//           Colors.blue,
//         ),
//         _buildActionCard(
//           context,
//           theme,
//           'Payroll Management',
//           Icons.attach_money_rounded,
//           Colors.purple,
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

//   Widget _buildRecentActivities(ThemeData theme) {
//     final activities = [
//       {
//         'title': 'New employee registration',
//         'subtitle': 'John Doe joined as Software Engineer',
//         'icon': Icons.person_add_rounded,
//         'color': Colors.green,
//       },
//       {
//         'title': 'Leave request pending',
//         'subtitle': 'Sarah Wilson applied for 3 days leave',
//         'icon': Icons.beach_access_rounded,
//         'color': Colors.orange,
//       },
//       {
//         'title': 'Attendance marked late',
//         'subtitle': 'Mike Johnson was 30 minutes late',
//         'icon': Icons.schedule_rounded,
//         'color': Colors.red,
//       },
//       {
//         'title': 'Salary processed',
//         'subtitle': 'February salaries processed successfully',
//         'icon': Icons.attach_money_rounded,
//         'color': Colors.blue,
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

class HRDashboardScreen extends StatelessWidget {
  final User user;

  const HRDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: theme.themeMode == ThemeMode.dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('HR Dashboard'),
        backgroundColor: AppColors.info,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authViewModel.clearError();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) => [
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
                      backgroundColor: AppColors.info,
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
                            'HR Manager',
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            const Text(
              'Quick Overview',
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
                _buildStatCard(
                  'Total Employees',
                  '47',
                  Icons.people,
                  AppColors.primary,
                ),
                _buildStatCard(
                  'Pending Leaves',
                  '12',
                  Icons.beach_access,
                  AppColors.warning,
                ),
                _buildStatCard(
                  'New Hires',
                  '5',
                  Icons.person_add,
                  AppColors.success,
                ),
                _buildStatCard(
                  'Attendance Issues',
                  '3',
                  Icons.warning,
                  AppColors.error,
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
                  'Manage Employees',
                  Icons.manage_accounts,
                  AppColors.primary,
                  () {
                    _showComingSoonSnackbar(context, 'Employee Management');
                  },
                ),
                _buildActionCard(
                  'Leave Approvals',
                  Icons.assignment_turned_in,
                  AppColors.success,
                  () {
                    _showComingSoonSnackbar(context, 'Leave Approvals');
                  },
                ),
                _buildActionCard(
                  'Attendance Reports',
                  Icons.analytics,
                  AppColors.info,
                  () {
                    _showComingSoonSnackbar(context, 'Attendance Reports');
                  },
                ),
                _buildActionCard(
                  'Payroll Management',
                  Icons.attach_money,
                  AppColors.secondary,
                  () {
                    _showComingSoonSnackbar(context, 'Payroll Management');
                  },
                ),
              ],
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
                      'New employee registration',
                      'John Doe joined as Software Engineer',
                      Icons.person_add,
                      AppColors.success,
                    ),
                    _buildActivityItem(
                      'Leave request pending',
                      'Sarah Wilson applied for 3 days leave',
                      Icons.beach_access,
                      AppColors.warning,
                    ),
                    _buildActivityItem(
                      'Attendance marked late',
                      'Mike Johnson was 30 minutes late',
                      Icons.schedule,
                      AppColors.error,
                    ),
                    _buildActivityItem(
                      'Salary processed',
                      'February salaries processed successfully',
                      Icons.attach_money,
                      AppColors.info,
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
        backgroundColor: AppColors.info,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
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
                fontSize: 24,
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
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Coming Soon!'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
