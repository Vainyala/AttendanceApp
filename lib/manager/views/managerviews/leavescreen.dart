// views/manager_leave_screen.dart
import 'package:AttendanceApp/manager/core/view_models/theme_view_model.dart';
import 'package:AttendanceApp/manager/core/widgets/bottom_navigation.dart';
import 'package:AttendanceApp/manager/models/leavemodels/leave_model.dart';
import 'package:AttendanceApp/manager/models/user_model.dart';
import 'package:AttendanceApp/manager/view_models/leaveviewmodels/leave_view_model.dart';
import 'package:AttendanceApp/manager/views/managerviews/leave_detail_screen.dart';
import 'package:AttendanceApp/manager/views/managerviews/manager_dashboard_screen.dart';
import 'package:AttendanceApp/manager/views/managerviews/manager_regularisation_screen.dart';
import 'package:AttendanceApp/manager/views/managerviews/timeline.dart';
import 'package:AttendanceApp/manager/widgets/leavewidgets/dashboard_counter.dart';
import 'package:AttendanceApp/manager/widgets/leavewidgets/leave_application_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManagerLeaveScreen extends StatefulWidget {
  final User user;

  const ManagerLeaveScreen({super.key, required this.user});

  @override
  State<ManagerLeaveScreen> createState() => _ManagerLeaveScreenState();
}

class _ManagerLeaveScreenState extends State<ManagerLeaveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final viewModel = context.read<LeaveViewModel>();
    viewModel.loadLeaveApplications().then((_) {
      if (viewModel.leaveApplications.isEmpty) {
        viewModel.initializeSampleData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    final isDarkMode = theme.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Leave Management',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
        ),
      ),
      body: Consumer<LeaveViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.leaveApplications.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return _buildErrorWidget(viewModel, isDarkMode);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadLeaveApplications();
            },
            child: Column(
              children: [
                // Header Stats - More Compact (Regularisation Style)
                _buildHeaderStats(viewModel, isDarkMode),

                // Filter Section - Improved Design (Regularisation Style)
                _buildFilterSection(viewModel, isDarkMode),

                // Applications List
                Expanded(child: _buildApplicationsList(viewModel, isDarkMode)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: 2,
        onTabChanged: (index) => _handleBottomNavigation(index, context),
      ),
    );
  }

  Widget _buildErrorWidget(LeaveViewModel viewModel, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something Went Wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.textInverse
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage,
              style: TextStyle(
                color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.clearError();
                _initializeData();
              },
              icon: Icon(Icons.refresh, size: 18),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStats(LeaveViewModel viewModel, bool isDarkMode) {
    final counters = viewModel.dashboardCounters;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Monthly Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                'Total',
                counters['total']!.toString(),
                AppColors.primary,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Pending',
                counters['pending']!.toString(),
                AppColors.warning,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Approved',
                counters['approved']!.toString(),
                AppColors.success,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Rejected',
                counters['rejected']!.toString(),
                AppColors.error,
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDarkMode) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDarkMode ? AppColors.grey700 : AppColors.grey200,
    );
  }

  Widget _buildFilterSection(LeaveViewModel viewModel, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.grey700 : AppColors.grey100,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'All',
                    LeaveFilter.all,
                    viewModel,
                    isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    LeaveFilter.pending,
                    viewModel,
                    isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Approved',
                    LeaveFilter.approved,
                    viewModel,
                    isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Rejected',
                    LeaveFilter.rejected,
                    viewModel,
                    isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Team',
                    LeaveFilter.team,
                    viewModel,
                    isDarkMode,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildExportButton(viewModel, isDarkMode),
          const SizedBox(width: 8),
          _buildSearchButton(viewModel, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    LeaveFilter filter,
    LeaveViewModel viewModel,
    bool isDarkMode,
  ) {
    final isSelected = viewModel.currentFilter == filter;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDarkMode ? AppColors.grey300 : AppColors.grey700),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => viewModel.setFilter(filter),
      backgroundColor: isDarkMode ? AppColors.grey800 : AppColors.grey100,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildExportButton(LeaveViewModel viewModel, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _exportToExcel(viewModel),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.table_chart, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Export',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(LeaveViewModel viewModel, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showSearchDialog(viewModel, isDarkMode),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.search, color: AppColors.primary, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsList(LeaveViewModel viewModel, bool isDarkMode) {
    final applications = viewModel.filteredApplications;

    if (applications.isEmpty) {
      return _buildEmptyState(viewModel, isDarkMode);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final application = applications[index];
        return LeaveApplicationCard(
          application: application,
          onTap: () => _navigateToDetailScreen(context, application),
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildEmptyState(LeaveViewModel viewModel, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDarkMode ? AppColors.grey800 : AppColors.grey100)
                    .withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.beach_access_rounded,
                color: isDarkMode ? AppColors.grey500 : AppColors.grey400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${_getFilterText(viewModel.currentFilter)} Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? AppColors.textInverse
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All ${_getFilterText(viewModel.currentFilter).toLowerCase()} leave requests have been processed',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.grey500 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterText(LeaveFilter filter) {
    switch (filter) {
      case LeaveFilter.pending:
        return 'Pending';
      case LeaveFilter.approved:
        return 'Approved';
      case LeaveFilter.rejected:
        return 'Rejected';
      case LeaveFilter.query:
        return 'Query';
      case LeaveFilter.team:
        return 'Team';
      case LeaveFilter.all:
      default:
        return 'All';
    }
  }

  void _exportToExcel(LeaveViewModel viewModel) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting to Excel...'),
        backgroundColor: AppColors.primary,
      ),
    );

    try {
      final exportData = await viewModel.exportToExcel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exportData.length} records exported successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSearchDialog(LeaveViewModel viewModel, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        title: Text(
          'Search Leave Applications',
          style: TextStyle(
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
          ),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search by name, email, project...',
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDarkMode ? AppColors.grey700 : AppColors.grey300,
              ),
            ),
            hintStyle: TextStyle(
              color: isDarkMode ? AppColors.grey500 : AppColors.grey500,
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
          ),
          onChanged: (query) {
            // Real-time search could be implemented here
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? AppColors.grey400 : AppColors.grey600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement search functionality
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetailScreen(
    BuildContext context,
    LeaveApplication application,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaveDetailScreen(
          application: application,
          onStatusUpdated: () {
            context.read<LeaveViewModel>().loadLeaveApplications();
          },
        ),
      ),
    );
  }

  void _handleBottomNavigation(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ManagerDashboardScreen(user: widget.user),
          ),
          (route) => false,
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ManagerRegularisationScreen(user: widget.user),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimelineScreen(user: widget.user),
          ),
        );
        break;
    }
  }
}

// // views/manager_leave_screen.dart
// import 'package:AttendanceApp/manager/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/manager/core/widgets/bottom_navigation.dart';
// import 'package:AttendanceApp/manager/models/leavemodels/leave_model.dart';
// import 'package:AttendanceApp/manager/models/user_model.dart';
// import 'package:AttendanceApp/manager/view_models/leaveviewmodels/leave_view_model.dart';
// import 'package:AttendanceApp/manager/views/managerviews/leave_detail_screen.dart';
// import 'package:AttendanceApp/manager/views/managerviews/manager_dashboard_screen.dart';
// import 'package:AttendanceApp/manager/views/managerviews/manager_regularisation_screen.dart';
// import 'package:AttendanceApp/manager/views/managerviews/timeline.dart';
// import 'package:AttendanceApp/manager/widgets/leavewidgets/dashboard_counter.dart';
// import 'package:AttendanceApp/manager/widgets/leavewidgets/leave_application_card.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ManagerLeaveScreen extends StatefulWidget {
//   final User user;

//   const ManagerLeaveScreen({super.key, required this.user});

//   @override
//   State<ManagerLeaveScreen> createState() => _ManagerLeaveScreenState();
// }

// class _ManagerLeaveScreenState extends State<ManagerLeaveScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeData();
//     });
//   }

//   void _initializeData() {
//     final viewModel = context.read<LeaveViewModel>();
//     viewModel.loadLeaveApplications().then((_) {
//       if (viewModel.leaveApplications.isEmpty) {
//         viewModel.initializeSampleData();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final isDarkMode = theme.isDarkMode;

//     // Color definitions based on theme
//     final textColor = isDarkMode ? AppColors.white : AppColors.textPrimary;
//     final borderColor = isDarkMode
//         ? AppColors.white.withOpacity(0.2)
//         : AppColors.grey300;
//     final secondaryTextColor = isDarkMode
//         ? AppColors.white.withOpacity(0.8)
//         : AppColors.textSecondary;
//     final backgroundColor = isDarkMode
//         ? AppColors.backgroundDark
//         : AppColors.backgroundLight;
//     final surfaceColor = isDarkMode
//         ? AppColors.surfaceDark
//         : AppColors.surfaceLight;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         title: Text(
//           'Leave Management',
//           style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
//         ),
//         backgroundColor: surfaceColor,
//         elevation: 1,
//         centerTitle: true,
//         iconTheme: IconThemeData(color: textColor),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: textColor),
//             onPressed: () {
//               context.read<LeaveViewModel>().loadLeaveApplications();
//             },
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: Consumer<LeaveViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading && viewModel.leaveApplications.isEmpty) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: isDarkMode ? AppColors.primaryLight : AppColors.primary,
//               ),
//             );
//           }

//           if (viewModel.errorMessage.isNotEmpty) {
//             return _buildErrorWidget(viewModel, isDarkMode);
//           }

//           return Container(
//             decoration: BoxDecoration(
//               gradient: isDarkMode
//                   ? RadialGradient(
//                       center: Alignment.topLeft,
//                       radius: 2.0,
//                       colors: [
//                         AppColors.primary.withOpacity(0.15),
//                         AppColors.secondary.withOpacity(0.1),
//                         AppColors.backgroundDark,
//                       ],
//                       stops: const [0.0, 0.5, 1.0],
//                     )
//                   : LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         AppColors.primary.withOpacity(0.05),
//                         AppColors.secondary.withOpacity(0.03),
//                         AppColors.backgroundLight,
//                       ],
//                     ),
//             ),
//             // YEH LINE CHANGE KARO - SingleChildScrollView add karo
//             child: SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: MediaQuery.of(context).size.height,
//                 ),
//                 child: Column(
//                   children: [
//                     // Dashboard Counters
//                     _buildDashboardSection(
//                       viewModel,
//                       isDarkMode,
//                       surfaceColor,
//                       textColor,
//                     ),

//                     // Filter and Export Section
//                     _buildFilterSection(
//                       viewModel,
//                       isDarkMode,
//                       surfaceColor,
//                       borderColor,
//                     ),

//                     // Applications List - YEH WALA EXPANDED RAHEGA
//                     _buildApplicationsList(viewModel, isDarkMode),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: 2,
//         onTabChanged: (index) {
//           _handleNavigation(context, index);
//         },
//       ),
//     );
//   }

//   Widget _buildErrorWidget(LeaveViewModel viewModel, bool isDarkMode) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, color: AppColors.error, size: 64),
//           const SizedBox(height: 16),
//           Text(
//             viewModel.errorMessage,
//             style: TextStyle(color: AppColors.error, fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               viewModel.clearError();
//               _initializeData();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDashboardSection(
//     LeaveViewModel viewModel,
//     bool isDarkMode,
//     Color surfaceColor,
//     Color textColor,
//   ) {
//     final counters = viewModel.dashboardCounters;

//     return Card(
//       margin: const EdgeInsets.all(16),
//       elevation: 2,
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Current Month Overview',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 DashboardCounter(
//                   count: counters['total']!,
//                   label: 'Total',
//                   color: Colors.blue,
//                   icon: Icons.list_alt,
//                   isDarkMode: isDarkMode,
//                 ),
//                 DashboardCounter(
//                   count: counters['pending']!,
//                   label: 'Pending',
//                   color: Colors.orange,
//                   icon: Icons.pending_actions,
//                   isDarkMode: isDarkMode,
//                 ),
//                 DashboardCounter(
//                   count: counters['approved']!,
//                   label: 'Approved',
//                   color: Colors.green,
//                   icon: Icons.check_circle,
//                   isDarkMode: isDarkMode,
//                 ),
//                 DashboardCounter(
//                   count: counters['rejected']!,
//                   label: 'Rejected',
//                   color: Colors.red,
//                   icon: Icons.cancel,
//                   isDarkMode: isDarkMode,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterSection(
//     LeaveViewModel viewModel,
//     bool isDarkMode,
//     Color surfaceColor,
//     Color borderColor,
//   ) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       elevation: 2,
//       color: surfaceColor,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Expanded(
//               child: DropdownButtonFormField<LeaveFilter>(
//                 value: viewModel.currentFilter,
//                 items: const [
//                   DropdownMenuItem(
//                     value: LeaveFilter.all,
//                     child: Text('All Requests'),
//                   ),
//                   DropdownMenuItem(
//                     value: LeaveFilter.pending,
//                     child: Text('Pending'),
//                   ),
//                   DropdownMenuItem(
//                     value: LeaveFilter.approved,
//                     child: Text('Approved'),
//                   ),
//                   DropdownMenuItem(
//                     value: LeaveFilter.rejected,
//                     child: Text('Rejected'),
//                   ),
//                 ],
//                 onChanged: (value) {
//                   if (value != null) {
//                     viewModel.setFilter(value);
//                   }
//                 },
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: borderColor),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   labelText: 'Filter by Status',
//                   labelStyle: TextStyle(
//                     color: isDarkMode ? AppColors.grey400 : AppColors.grey600,
//                   ),
//                 ),
//                 dropdownColor: surfaceColor,
//                 style: TextStyle(
//                   color: isDarkMode
//                       ? AppColors.textInverse
//                       : AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             IconButton(
//               icon: Icon(Icons.download, size: 28, color: Colors.green),
//               onPressed: () => _exportToExcel(viewModel),
//               tooltip: 'Export to Excel',
//               style: IconButton.styleFrom(
//                 backgroundColor: Colors.green.withOpacity(0.1),
//                 padding: const EdgeInsets.all(12),
//               ),
//             ),
//             const SizedBox(width: 8),
//             IconButton(
//               icon: Icon(Icons.search, size: 28, color: Colors.blue),
//               onPressed: () =>
//                   _showSearchDialog(viewModel, isDarkMode, surfaceColor),
//               tooltip: 'Search Applications',
//               style: IconButton.styleFrom(
//                 backgroundColor: Colors.blue.withOpacity(0.1),
//                 padding: const EdgeInsets.all(12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildApplicationsList(LeaveViewModel viewModel, bool isDarkMode) {
//     final applications = viewModel.filteredApplications;

//     return applications.isEmpty
//         ? _buildEmptyState(viewModel, isDarkMode)
//         : Expanded(
//             child: RefreshIndicator(
//               onRefresh: () async {
//                 await viewModel.loadLeaveApplications();
//               },
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: applications.length,
//                 itemBuilder: (context, index) {
//                   final application = applications[index];
//                   return LeaveApplicationCard(
//                     application: application,
//                     onTap: () => _navigateToDetailScreen(context, application),
//                     isDarkMode: isDarkMode,
//                   );
//                 },
//               ),
//             ),
//           );
//   }

//   Widget _buildEmptyState(LeaveViewModel viewModel, bool isDarkMode) {
//     return Container(
//       height: 200, // Fixed height for empty state
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.beach_access,
//               size: 64,
//               color: isDarkMode ? AppColors.grey500 : AppColors.grey400,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No leave applications found',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: isDarkMode ? AppColors.grey400 : AppColors.grey600,
//               ),
//             ),
//             if (viewModel.currentFilter != LeaveFilter.all)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   'for ${_getFilterText(viewModel.currentFilter)} status',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: isDarkMode ? AppColors.grey500 : AppColors.grey500,
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 viewModel.setFilter(LeaveFilter.all);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Show All Applications'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getFilterText(LeaveFilter filter) {
//     switch (filter) {
//       case LeaveFilter.pending:
//         return 'Pending';
//       case LeaveFilter.approved:
//         return 'Approved';
//       case LeaveFilter.rejected:
//         return 'Rejected';
//       case LeaveFilter.query:
//         return 'Query';
//       case LeaveFilter.all:
//       default:
//         return 'All';
//     }
//   }

//   void _exportToExcel(LeaveViewModel viewModel) async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Exporting to Excel...'),
//         backgroundColor: AppColors.primary,
//       ),
//     );

//     try {
//       final exportData = await viewModel.exportToExcel();

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${exportData.length} records exported successfully'),
//             backgroundColor: AppColors.success,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Export failed: $e'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     }
//   }

//   void _showSearchDialog(
//     LeaveViewModel viewModel,
//     bool isDarkMode,
//     Color surfaceColor,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: surfaceColor,
//         title: Text(
//           'Search Leave Applications',
//           style: TextStyle(
//             color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
//           ),
//         ),
//         content: TextField(
//           decoration: InputDecoration(
//             hintText: 'Search by name, email, project...',
//             border: const OutlineInputBorder(),
//             hintStyle: TextStyle(
//               color: isDarkMode ? AppColors.grey500 : AppColors.grey500,
//             ),
//           ),
//           style: TextStyle(
//             color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
//           ),
//           onChanged: (query) {
//             // Real-time search could be implemented here
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: isDarkMode ? AppColors.grey400 : AppColors.grey600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Implement search functionality
//               Navigator.of(context).pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Search'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToDetailScreen(
//     BuildContext context,
//     LeaveApplication application,
//   ) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LeaveDetailScreen(
//           application: application,
//           onStatusUpdated: () {
//             context.read<LeaveViewModel>().loadLeaveApplications();
//           },
//         ),
//       ),
//     );
//   }

//   void _handleNavigation(BuildContext context, int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ManagerDashboardScreen(user: widget.user),
//           ),
//           (route) => false,
//         );
//         break;
//       case 1:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ManagerRegularisationScreen(user: widget.user),
//           ),
//         );
//         break;
//       case 3:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TimelineScreen(user: widget.user),
//           ),
//         );
//         break;
//     }
//   }
// }

// // views/manager_leave_screen.dart
// import 'package:AttendanceApp/manager/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/manager/core/widgets/bottom_navigation.dart';
// import 'package:AttendanceApp/manager/models/leavemodels/leave_model.dart';
// import 'package:AttendanceApp/manager/models/user_model.dart';
// import 'package:AttendanceApp/manager/view_models/leaveviewmodels/leave_view_model.dart';
// import 'package:AttendanceApp/manager/views/managerviews/leave_detail_screen.dart';
// import 'package:AttendanceApp/manager/views/managerviews/manager_dashboard_screen.dart';
// import 'package:AttendanceApp/manager/views/managerviews/manager_regularisation_screen.dart';
// import 'package:AttendanceApp/manager/views/managerviews/timeline.dart';
// import 'package:AttendanceApp/manager/widgets/leavewidgets/dashboard_counter.dart';
// import 'package:AttendanceApp/manager/widgets/leavewidgets/leave_application_card.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ManagerLeaveScreen extends StatefulWidget {
//   final User user;

//   const ManagerLeaveScreen({super.key, required this.user});

//   @override
//   State<ManagerLeaveScreen> createState() => _ManagerLeaveScreenState();
// }

// class _ManagerLeaveScreenState extends State<ManagerLeaveScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeData();
//     });
//   }

//   void _initializeData() {
//     final viewModel = context.read<LeaveViewModel>();
//     viewModel.loadLeaveApplications().then((_) {
//       if (viewModel.leaveApplications.isEmpty) {
//         viewModel.initializeSampleData();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         title: const Text(
//           'Leave Management',
//           style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
//         ),
//         backgroundColor: AppColors.grey300,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               context.read<LeaveViewModel>().loadLeaveApplications();
//             },
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       body: Consumer<LeaveViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading && viewModel.leaveApplications.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (viewModel.errorMessage.isNotEmpty) {
//             return _buildErrorWidget(viewModel);
//           }

//           return Container(
//             decoration: BoxDecoration(
//               gradient: RadialGradient(
//                 center: Alignment.topLeft,
//                 radius: 2.0,
//                 colors: [
//                   AppColors.primary.withOpacity(0.15),
//                   AppColors.secondary.withOpacity(0.1),
//                   Colors.black,
//                 ],
//                 stops: const [0.0, 0.5, 1.0],
//               ),
//             ),
//             child: Column(
//               children: [
//                 // Dashboard Counters
//                 _buildDashboardSection(viewModel),

//                 // Filter and Export Section
//                 _buildFilterSection(viewModel),

//                 // Applications List
//                 _buildApplicationsList(viewModel),
//               ],
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: 2,
//         onTabChanged: (index) {
//           _handleNavigation(context, index);
//         },
//       ),
//     );
//   }

//   Widget _buildErrorWidget(LeaveViewModel viewModel) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, color: Colors.red, size: 64),
//           const SizedBox(height: 16),
//           Text(
//             viewModel.errorMessage,
//             style: const TextStyle(color: Colors.red, fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               viewModel.clearError();
//               _initializeData();
//             },
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDashboardSection(LeaveViewModel viewModel) {
//     final counters = viewModel.dashboardCounters;

//     return Card(
//       margin: const EdgeInsets.all(16),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Current Month Overview',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 DashboardCounter(
//                   count: counters['total']!,
//                   label: 'Total',
//                   color: Colors.blue,
//                   icon: Icons.list_alt,
//                 ),
//                 DashboardCounter(
//                   count: counters['pending']!,
//                   label: 'Pending',
//                   color: Colors.orange,
//                   icon: Icons.pending_actions,
//                 ),
//                 DashboardCounter(
//                   count: counters['approved']!,
//                   label: 'Approved',
//                   color: Colors.green,
//                   icon: Icons.check_circle,
//                 ),
//                 DashboardCounter(
//                   count: counters['rejected']!,
//                   label: 'Rejected',
//                   color: Colors.red,
//                   icon: Icons.cancel,
//                 ),
//                 // DashboardCounter(
//                 //   count: counters['query']!,
//                 //   label: 'Query',
//                 //   color: Colors.orange,
//                 //   icon: Icons.help_outline,
//                 // ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterSection(LeaveViewModel viewModel) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Expanded(
//               child: DropdownButtonFormField<LeaveFilter>(
//                 value: viewModel.currentFilter,
//                 items: const [
//                   DropdownMenuItem(
//                     value: LeaveFilter.all,
//                     child: Text('All Requests'),
//                   ),
//                   DropdownMenuItem(
//                     value: LeaveFilter.pending,
//                     child: Text('Pending'),
//                   ),
//                   DropdownMenuItem(
//                     value: LeaveFilter.approved,
//                     child: Text('Approved'),
//                   ),
//                   DropdownMenuItem(
//                     value: LeaveFilter.rejected,
//                     child: Text('Rejected'),
//                   ),
//                   // DropdownMenuItem(
//                   //   value: LeaveFilter.query,
//                   //   child: Text('Query'),
//                   // ),
//                 ],
//                 onChanged: (value) {
//                   if (value != null) {
//                     viewModel.setFilter(value);
//                   }
//                 },
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                   labelText: 'Filter by Status',
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             IconButton(
//               icon: const Icon(Icons.download, size: 28),
//               onPressed: () => _exportToExcel(viewModel),
//               tooltip: 'Export to Excel',
//               style: IconButton.styleFrom(
//                 backgroundColor: Colors.green.withOpacity(0.1),
//                 padding: const EdgeInsets.all(12),
//               ),
//             ),
//             const SizedBox(width: 8),
//             IconButton(
//               icon: const Icon(Icons.search, size: 28),
//               onPressed: () => _showSearchDialog(viewModel),
//               tooltip: 'Search Applications',
//               style: IconButton.styleFrom(
//                 backgroundColor: Colors.blue.withOpacity(0.1),
//                 padding: const EdgeInsets.all(12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildApplicationsList(LeaveViewModel viewModel) {
//     final applications = viewModel.filteredApplications;

//     return Expanded(
//       child: applications.isEmpty
//           ? _buildEmptyState(viewModel)
//           : RefreshIndicator(
//               onRefresh: () async {
//                 await viewModel.loadLeaveApplications();
//               },
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: applications.length,
//                 itemBuilder: (context, index) {
//                   final application = applications[index];
//                   return LeaveApplicationCard(
//                     application: application,
//                     onTap: () => _navigateToDetailScreen(context, application),
//                   );
//                 },
//               ),
//             ),
//     );
//   }

//   Widget _buildEmptyState(LeaveViewModel viewModel) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.beach_access, size: 64, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           const Text(
//             'No leave applications found',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           if (viewModel.currentFilter != LeaveFilter.all)
//             Text(
//               'for ${_getFilterText(viewModel.currentFilter)} status',
//               style: const TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               viewModel.setFilter(LeaveFilter.all);
//             },
//             child: const Text('Show All Applications'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getFilterText(LeaveFilter filter) {
//     switch (filter) {
//       case LeaveFilter.pending:
//         return 'Pending';
//       case LeaveFilter.approved:
//         return 'Approved';
//       case LeaveFilter.rejected:
//         return 'Rejected';
//       case LeaveFilter.query:
//         return 'Query';
//       case LeaveFilter.all:
//       default:
//         return 'All';
//     }
//   }

//   void _exportToExcel(LeaveViewModel viewModel) async {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Exporting to Excel...')));

//     try {
//       final exportData = await viewModel.exportToExcel();

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${exportData.length} records exported successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Export failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _showSearchDialog(LeaveViewModel viewModel) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Search Leave Applications'),
//         content: TextField(
//           decoration: const InputDecoration(
//             hintText: 'Search by name, email, project...',
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (query) {
//             // Real-time search could be implemented here
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Implement search functionality
//               Navigator.of(context).pop();
//             },
//             child: const Text('Search'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToDetailScreen(
//     BuildContext context,
//     LeaveApplication application,
//   ) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LeaveDetailScreen(
//           application: application,
//           onStatusUpdated: () {
//             context.read<LeaveViewModel>().loadLeaveApplications();
//           },
//         ),
//       ),
//     );
//   }

//   void _handleNavigation(BuildContext context, int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ManagerDashboardScreen(user: widget.user),
//           ),
//           (route) => false,
//         );
//         break;
//       case 1:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ManagerRegularisationScreen(user: widget.user),
//           ),
//         );
//         break;
//       case 3:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TimelineScreen(user: widget.user),
//           ),
//         );
//         break;
//     }
//   }
// }
