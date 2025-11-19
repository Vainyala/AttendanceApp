// employee_list_screen.dart
import 'package:AttendanceApp/manager/models/team_model.dart';
import 'package:AttendanceApp/manager/views/managerviews/employee_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/view_models/theme_view_model.dart';
import '../../view_models/managerviewmodels/manager_dashboard_view_model.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final viewModel = Provider.of<ManagerDashboardViewModel>(context);
    final teamMembers = viewModel.dashboard?.teamMembers ?? [];
    final isDark = theme.isDarkMode;

    // Filter team members based on search and status
    final filteredMembers = teamMembers.where((member) {
      final matchesSearch =
          member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          member.role.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _statusFilter == 'all' ||
          member.status.toLowerCase() == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Team Members'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 20,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          _buildSearchFilterBar(isDark),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${filteredMembers.length} ${filteredMembers.length == 1 ? 'member' : 'members'} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.grey400 : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Employee List
          Expanded(
            child: filteredMembers.isEmpty
                ? _buildEmptyState(isDark)
                : _buildEmployeeList(filteredMembers, context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search team members...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.grey400 : AppColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? AppColors.grey400 : AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark
                                ? AppColors.grey400
                                : AppColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _statusFilter = value;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'all',
                  child: Text(
                    'All Status',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'active',
                  child: Text(
                    'Active Only',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'inactive',
                  child: Text(
                    'Inactive Only',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: isDark
                          ? AppColors.grey400
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Filter',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.grey400
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(
    List<TeamMember> members,
    BuildContext context,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildEmployeeCard(member, context, isDark);
      },
    );
  }

  Widget _buildEmployeeCard(
    TeamMember member,
    BuildContext context,
    bool isDark,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: _buildAvatar(member, isDark),
        title: Text(
          member.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.role,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              member.email,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.grey400 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusBadge(member),
            const SizedBox(height: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? AppColors.grey400 : AppColors.textSecondary,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDetailsScreen(teamMember: member),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(TeamMember member, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: member.status == 'active'
                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                : (isDark
                      ? AppColors.warning.withOpacity(0.8)
                      : AppColors.warning),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.white, size: 24),
        ),
        if (member.status == 'active')
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(TeamMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: member.status == 'active'
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: member.status == 'active'
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Text(
        member.status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: member.status == 'active'
              ? AppColors.success
              : AppColors.warning,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800 : AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people,
              size: 40,
              color: isDark ? AppColors.grey400 : AppColors.grey400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Team Members Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No team members match your search criteria'
                : 'There are no team members assigned to you yet',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.grey400 : AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_searchQuery.isNotEmpty || _statusFilter != 'all')
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _statusFilter = 'all';
                  _searchController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.primaryLight
                    : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Clear Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// // employee_list_screen.dart
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/views/managerviews/employee_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class EmployeeListScreen extends StatefulWidget {
//   const EmployeeListScreen({super.key});

//   @override
//   State<EmployeeListScreen> createState() => _EmployeeListScreenState();
// }

// class _EmployeeListScreenState extends State<EmployeeListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _statusFilter = 'all';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];

//     // Filter team members based on search and status
//     final filteredMembers = teamMembers.where((member) {
//       final matchesSearch =
//           member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           member.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           member.role.toLowerCase().contains(_searchQuery.toLowerCase());

//       final matchesStatus =
//           _statusFilter == 'all' ||
//           member.status.toLowerCase() == _statusFilter.toLowerCase();

//       return matchesSearch && matchesStatus;
//     }).toList();

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Team Members'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: AppColors.textPrimary,
//       ),
//       body: Column(
//         children: [
//           // Search and Filter Bar
//           _buildSearchFilterBar(),

//           // Results Count
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               children: [
//                 Text(
//                   '${filteredMembers.length} ${filteredMembers.length == 1 ? 'member' : 'members'} found',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.textSecondary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Employee List
//           Expanded(
//             child: filteredMembers.isEmpty
//                 ? _buildEmptyState()
//                 : _buildEmployeeList(filteredMembers, context),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchFilterBar() {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           // Search Field
//           Expanded(
//             child: Container(
//               height: 50,
//               decoration: BoxDecoration(
//                 color: AppColors.grey100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (value) {
//                   setState(() {
//                     _searchQuery = value;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Search team members...',
//                   hintStyle: TextStyle(color: AppColors.textSecondary),
//                   prefixIcon: Icon(
//                     Icons.search,
//                     color: AppColors.textSecondary,
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                   suffixIcon: _searchQuery.isNotEmpty
//                       ? IconButton(
//                           icon: Icon(
//                             Icons.clear,
//                             color: AppColors.textSecondary,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _searchQuery = '';
//                               _searchController.clear();
//                             });
//                           },
//                         )
//                       : null,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Filter Button
//           Container(
//             height: 50,
//             decoration: BoxDecoration(
//               color: AppColors.grey100,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: PopupMenuButton<String>(
//               onSelected: (value) {
//                 setState(() {
//                   _statusFilter = value;
//                 });
//               },
//               itemBuilder: (context) => [
//                 const PopupMenuItem(value: 'all', child: Text('All Status')),
//                 const PopupMenuItem(
//                   value: 'active',
//                   child: Text('Active Only'),
//                 ),
//                 const PopupMenuItem(
//                   value: 'inactive',
//                   child: Text('Inactive Only'),
//                 ),
//               ],
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Icon(Icons.filter_list, color: AppColors.textSecondary),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Filter',
//                       style: TextStyle(color: AppColors.textSecondary),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmployeeList(List<TeamMember> members, BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       itemCount: members.length,
//       itemBuilder: (context, index) {
//         final member = members[index];
//         return _buildEmployeeCard(member, context);
//       },
//     );
//   }

//   Widget _buildEmployeeCard(TeamMember member, BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: _buildAvatar(member),
//         title: Text(
//           member.name,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               member.role,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.primary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Text(
//               member.email,
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildStatusBadge(member),
//             const SizedBox(height: 4),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: AppColors.textSecondary,
//             ),
//           ],
//         ),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => EmployeeDetailsScreen(teamMember: member),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAvatar(TeamMember member) {
//     return Stack(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: member.status == 'active'
//                 ? AppColors.primary
//                 : AppColors.warning,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(Icons.person, color: Colors.white, size: 24),
//         ),
//         if (member.status == 'active')
//           Positioned(
//             right: 2,
//             bottom: 2,
//             child: Container(
//               width: 12,
//               height: 12,
//               decoration: BoxDecoration(
//                 color: AppColors.success,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildStatusBadge(TeamMember member) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: member.status == 'active'
//             ? AppColors.success.withOpacity(0.1)
//             : AppColors.warning.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: member.status == 'active'
//               ? AppColors.success.withOpacity(0.3)
//               : AppColors.warning.withOpacity(0.3),
//         ),
//       ),
//       child: Text(
//         member.status.toUpperCase(),
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           color: member.status == 'active'
//               ? AppColors.success
//               : AppColors.warning,
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Padding(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               color: AppColors.grey100,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.people, size: 40, color: AppColors.grey400),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'No Team Members Found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _searchQuery.isNotEmpty
//                 ? 'No team members match your search criteria'
//                 : 'There are no team members assigned to you yet',
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.textSecondary,
//               height: 1.4,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           if (_searchQuery.isNotEmpty || _statusFilter != 'all')
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _searchQuery = '';
//                   _statusFilter = 'all';
//                   _searchController.clear();
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//               ),
//               child: const Text(
//                 'Clear Filters',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

/*  #####################################################################################################################

***************************************         A I S C R E E N C O D E             *****************************************

############################################################################################################################ */

// // employee_list_screen.dart
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/views/managerviews/employee_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class EmployeeListScreen extends StatefulWidget {
//   const EmployeeListScreen({super.key});

//   @override
//   State<EmployeeListScreen> createState() => _EmployeeListScreenState();
// }

// class _EmployeeListScreenState extends State<EmployeeListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _statusFilter = 'all';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];

//     // Filter team members based on search and status
//     final filteredMembers = teamMembers.where((member) {
//       final matchesSearch =
//           member.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           member.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           member.role.toLowerCase().contains(_searchQuery.toLowerCase());

//       final matchesStatus =
//           _statusFilter == 'all' ||
//           member.status.toLowerCase() == _statusFilter.toLowerCase();

//       return matchesSearch && matchesStatus;
//     }).toList();

//     final activeCount = teamMembers.where((m) => m.status == 'active').length;
//     final inactiveCount = teamMembers.where((m) => m.status != 'active').length;

//     return Scaffold(
//       // backgroundColor: Colors.black,
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Team Members'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: AppColors.textPrimary,
//       ),
//       body: Container(
//         // decoration: BoxDecoration(
//         //   // ✅ Gradient decoration add kiya
//         //   gradient: RadialGradient(
//         //     center: Alignment.topLeft,
//         //     radius: 2.0,
//         //     colors: [
//         //       QuickAIColors.cyber.primary.withOpacity(0.3),
//         //       QuickAIColors.cyber.secondary.withOpacity(0.2),
//         //       Colors.black,
//         //     ],
//         //     stops: const [0.0, 0.5, 1.0],
//         //   ),
//         // ),
//         child: Column(
//           children: [
//             // Header Stats
//             //_buildStatsHeader(activeCount, inactiveCount, teamMembers.length),

//             // Search and Filter Bar
//             _buildSearchFilterBar(),

//             // Results Count
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               child: Row(
//                 children: [
//                   Text(
//                     '${filteredMembers.length} ${filteredMembers.length == 1 ? 'member' : 'members'} found',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSecondary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Employee List
//             Expanded(
//               child: filteredMembers.isEmpty
//                   ? _buildEmptyState()
//                   : _buildEmployeeList(filteredMembers, context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: RadialGradient(
//           center: Alignment.topLeft,
//           radius: 2.0,
//           colors: [
//             QuickAIColors.cyber.primary.withOpacity(0.3),
//             QuickAIColors.cyber.secondary.withOpacity(0.2),
//             Colors.black,
//           ],
//           stops: const [0.0, 0.5, 1.0],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsHeader(int activeCount, int inactiveCount, int total) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary.withOpacity(0.8),
//             AppColors.primary.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem('Total', total.toString(), Icons.people_rounded),
//           _buildStatItem(
//             'Active',
//             activeCount.toString(),
//             Icons.check_circle_rounded,
//           ),
//           _buildStatItem(
//             'Inactive',
//             inactiveCount.toString(),
//             Icons.pause_circle_rounded,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.white, size: 24),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchFilterBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: [
//           // Search Field
//           Expanded(
//             child: Container(
//               height: 50,
//               decoration: BoxDecoration(
//                 color: AppColors.grey100,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (value) {
//                   setState(() {
//                     _searchQuery = value;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Search team members...',
//                   hintStyle: TextStyle(color: AppColors.textSecondary),
//                   prefixIcon: Icon(
//                     Icons.search_rounded,
//                     color: AppColors.textSecondary,
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                   suffixIcon: _searchQuery.isNotEmpty
//                       ? IconButton(
//                           icon: Icon(
//                             Icons.clear_rounded,
//                             color: AppColors.textSecondary,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _searchQuery = '';
//                               _searchController.clear();
//                             });
//                           },
//                         )
//                       : null,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Filter Button
//           Container(
//             height: 50,
//             decoration: BoxDecoration(
//               color: AppColors.grey100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: PopupMenuButton<String>(
//               onSelected: (value) {
//                 setState(() {
//                   _statusFilter = value;
//                 });
//               },
//               itemBuilder: (context) => [
//                 const PopupMenuItem(value: 'all', child: Text('All Status')),
//                 const PopupMenuItem(
//                   value: 'active',
//                   child: Text('Active Only'),
//                 ),
//                 const PopupMenuItem(
//                   value: 'inactive',
//                   child: Text('Inactive Only'),
//                 ),
//               ],
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.filter_list_rounded,
//                       color: AppColors.textSecondary,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Filter',
//                       style: TextStyle(color: AppColors.textSecondary),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmployeeList(List<TeamMember> members, BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       itemCount: members.length,
//       itemBuilder: (context, index) {
//         final member = members[index];
//         return _buildEmployeeCard(member, context, index);
//       },
//     );
//   }

//   Widget _buildEmployeeCard(
//     TeamMember member,
//     BuildContext context,
//     int index,
//   ) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 200 + (index * 100)),
//       curve: Curves.easeOut,
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Card(
//         elevation: 4,
//         margin: EdgeInsets.zero,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: member.status == 'active'
//                 ? LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Colors.white, AppColors.primary.withOpacity(0.02)],
//                   )
//                 : LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Colors.white, AppColors.warning.withOpacity(0.02)],
//                   ),
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(16),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (context, animation, secondaryAnimation) =>
//                         EmployeeDetailsScreen(teamMember: member),
//                     transitionsBuilder:
//                         (context, animation, secondaryAnimation, child) {
//                           const begin = Offset(1.0, 0.0);
//                           const end = Offset.zero;
//                           const curve = Curves.easeInOut;
//                           var tween = Tween(
//                             begin: begin,
//                             end: end,
//                           ).chain(CurveTween(curve: curve));
//                           return SlideTransition(
//                             position: animation.drive(tween),
//                             child: child,
//                           );
//                         },
//                   ),
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     // Avatar
//                     _buildAvatar(member),
//                     const SizedBox(width: 16),

//                     // Employee Info
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             member.name,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: AppColors.textPrimary,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             member.role,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: AppColors.primary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             member.email,
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppColors.textSecondary,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Status and Arrow
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         _buildStatusBadge(member),
//                         const SizedBox(height: 8),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 16,
//                           color: AppColors.textSecondary,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAvatar(TeamMember member) {
//     return Stack(
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: member.status == 'active'
//                   ? [AppColors.primary, AppColors.primary.withOpacity(0.7)]
//                   : [AppColors.warning, AppColors.warning.withOpacity(0.7)],
//             ),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
//         ),
//         // Online Status Indicator
//         if (member.status == 'active')
//           Positioned(
//             right: 2,
//             bottom: 2,
//             child: Container(
//               width: 14,
//               height: 14,
//               decoration: BoxDecoration(
//                 color: AppColors.success,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildStatusBadge(TeamMember member) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: member.status == 'active'
//             ? AppColors.success.withOpacity(0.1)
//             : AppColors.warning.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: member.status == 'active'
//               ? AppColors.success.withOpacity(0.3)
//               : AppColors.warning.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Text(
//         member.status.toUpperCase(),
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w700,
//           color: member.status == 'active'
//               ? AppColors.success
//               : AppColors.warning,
//           letterSpacing: 0.5,
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Padding(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               color: AppColors.grey100,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.people_alt_rounded,
//               size: 50,
//               color: AppColors.grey400,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Team Members Found',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             _searchQuery.isNotEmpty
//                 ? 'No team members match your search criteria'
//                 : 'There are no team members assigned to you yet',
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.textSecondary,
//               height: 1.4,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           if (_searchQuery.isNotEmpty || _statusFilter != 'all')
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _searchQuery = '';
//                   _statusFilter = 'all';
//                   _searchController.clear();
//                 });
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//               ),
//               child: const Text(
//                 'Clear Filters',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

/*  #####################################################################################################################

***************************************         A I S C R E E N C O D E             *****************************************

############################################################################################################################ */

// // employee_list_screen.dart
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:attendanceapp/views/managerviews/employee_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class EmployeeListScreen extends StatelessWidget {
//   const EmployeeListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final teamMembers = viewModel.dashboard?.teamMembers ?? [];

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         title: const Text('Team Members'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: teamMembers.isEmpty
//           ? _buildEmptyState()
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: teamMembers.length,
//               itemBuilder: (context, index) {
//                 final member = teamMembers[index];
//                 return _buildEmployeeCard(member, context);
//               },
//             ),
//     );
//   }

//   Widget _buildEmployeeCard(TeamMember member, BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(Icons.person_rounded, color: AppColors.primary),
//         ),
//         title: Text(
//           member.name,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(member.role),
//             Text(
//               member.email,
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//           ],
//         ),
//         trailing: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: member.status == 'active'
//                 ? AppColors.success.withOpacity(0.1)
//                 : AppColors.warning.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             member.status.toUpperCase(),
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//               color: member.status == 'active'
//                   ? AppColors.success
//                   : AppColors.warning,
//             ),
//           ),
//         ),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => EmployeeDetailsScreen(teamMember: member),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.people_outline_rounded,
//             size: 64,
//             color: AppColors.grey400,
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'No Team Members',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'There are no team members assigned to you',
//             style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
//           ),
//         ],
//       ),
//     );
//   }
// }
