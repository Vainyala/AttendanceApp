import 'package:AttendanceApp/manager/core/view_models/theme_view_model.dart';
import 'package:AttendanceApp/manager/models/managermodels/manager_dashboard_model.dart';
import 'package:AttendanceApp/manager/view_models/managerviewmodels/manager_dashboard_view_model.dart';
import 'package:AttendanceApp/manager/view_models/projectviewmodels/project_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresentDashboardCardSection extends StatefulWidget {
  const PresentDashboardCardSection({super.key});

  @override
  State<PresentDashboardCardSection> createState() =>
      _PresentDashboardCardSectionState();
}

class _PresentDashboardCardSectionState
    extends State<PresentDashboardCardSection> {
  @override
  void initState() {
    super.initState();
    // Initialize project data when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectViewModel = Provider.of<ProjectViewModel>(
        context,
        listen: false,
      );
      projectViewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ManagerDashboardViewModel>(context);
    final theme = Provider.of<AppTheme>(context);
    final stats = viewModel.stats;
    final bool isDarkMode = theme.isDarkMode;

    // Color definitions based on your scheme
    final textColor = isDarkMode ? AppColors.white : AppColors.textPrimary;
    final borderColor = isDarkMode
        ? AppColors.white.withOpacity(0.2)
        : AppColors.black;
    final secondaryTextColor = isDarkMode
        ? AppColors.white.withOpacity(0.8)
        : AppColors.black;
    final iconColor = isDarkMode
        ? Colors.white.withOpacity(0.8)
        : AppColors.primaryDark;

    if (stats == null) {
      return Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stats Cards - Responsive Design
                _buildPremiumStatsRow(
                  stats,
                  constraints,
                  isDarkMode,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  iconColor: iconColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 2),
                whiteHorizontalLine(isDark: isDarkMode, color: borderColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumStatsRow(
    DashboardStats stats,
    BoxConstraints constraints,
    bool isDarkMode, {
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    required Color borderColor,
  }) {
    final isPortrait = constraints.maxHeight > constraints.maxWidth;
    final spacing = isPortrait ? 8.0 : 16.0;

    // ✅ SAFE Percentage Calculation with validation
    final totalTeamMembers = stats.totalTeamMembers;
    final overallPresentValue = stats.overallPresent;

    int overallPresentPercentage;

    if (totalTeamMembers <= 0) {
      overallPresentPercentage = 0;
    } else if (overallPresentValue > totalTeamMembers) {
      overallPresentPercentage = 100;
    } else {
      overallPresentPercentage = (overallPresentValue / totalTeamMembers * 100)
          .round();
    }

    return Container(
      //padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: isDarkMode ? AppColors.surfaceLight : AppColors.surfaceDark,
        //borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: borderColor, width: 1),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 8,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPremiumStatItem(
            'Team',
            stats.totalTeamMembers,
            Icons.people_alt_rounded,
            isDarkMode,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            iconColor: iconColor,
          ),
          SizedBox(width: spacing),
          _buildPremiumStatItem(
            'Present',
            stats.presentToday,
            Icons.verified_user_rounded,
            isDarkMode,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            iconColor: iconColor,
          ),
          SizedBox(width: spacing),
          _buildPremiumStatItem(
            'Leaves',
            stats.pendingLeaves,
            Icons.beach_access_rounded,
            isDarkMode,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            iconColor: iconColor,
          ),
          SizedBox(width: spacing),
          _buildPremiumStatItem(
            'Absent',

            stats.absentToday,
            Icons.person_off_rounded,
            isDarkMode,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            iconColor: iconColor,
          ),
          SizedBox(width: spacing),
          // ✅ Safe percentage display
          _buildPremiumStatItem(
            'OverAll Present',
            overallPresentPercentage,
            Icons.trending_up_rounded,
            isDarkMode,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            iconColor: iconColor,
            isPercentage: true,
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED METHOD with your color scheme
  Widget _buildPremiumStatItem(
    String label,
    int value,
    IconData icon,
    bool isDarkMode, {
    required Color textColor,
    required Color secondaryTextColor,
    required Color iconColor,
    bool isPercentage = false,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              isPercentage ? '$value%' : value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget whiteHorizontalLine({
    bool isDark = false,
    double height = 1.0,
    double thickness = 1.0,
    Color? color,
    double opacity = 0.3,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    final lineColor =
        color ??
        (isDark ? AppColors.white.withOpacity(0.2) : AppColors.grey300);

    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: lineColor.withOpacity(opacity),
            width: thickness,
          ),
        ),
      ),
    );
  }
}

// import 'package:AttendanceApp/models/managermodels/manager_dashboard_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:AttendanceApp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class PresentDashboardCardSection extends StatefulWidget {
//   const PresentDashboardCardSection({super.key});

//   @override
//   State<PresentDashboardCardSection> createState() =>
//       _PresentDashboardCardSectionState();
// }

// class _PresentDashboardCardSectionState
//     extends State<PresentDashboardCardSection> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize project data when widget loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final projectViewModel = Provider.of<ProjectViewModel>(
//         context,
//         listen: false,
//       );
//       projectViewModel.initialize();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final stats = viewModel.stats;

//     if (stats == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Stats Cards - Responsive Design
//                 _buildPremiumStatsRow(stats, constraints),
//                 const SizedBox(height: 2),
//                 whiteHorizontalLine(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPremiumStatsRow(
//     DashboardStats stats,
//     BoxConstraints constraints,
//   ) {
//     final isPortrait = constraints.maxHeight > constraints.maxWidth;
//     final spacing = isPortrait ? 8.0 : 16.0;

//     // ✅ SAFE Percentage Calculation with validation
//     final totalTeamMembers = stats.totalTeamMembers;
//     final overallPresentValue = stats.overallPresent;

//     int overallPresentPercentage;

//     if (totalTeamMembers <= 0) {
//       overallPresentPercentage = 0;
//     } else if (overallPresentValue > totalTeamMembers) {
//       overallPresentPercentage = 100;
//     } else {
//       overallPresentPercentage = (overallPresentValue / totalTeamMembers * 100)
//           .round();
//     }

//     return Container(
//       // padding: const EdgeInsets.all(20),
//       // decoration: BoxDecoration(
//       //   color: AppColors.primary,
//       //   borderRadius: BorderRadius.circular(16),
//       //   boxShadow: [
//       //     BoxShadow(
//       //       color: Colors.black.withOpacity(0.2),
//       //       blurRadius: 10,
//       //       offset: const Offset(0, 4),
//       //     ),
//       //   ],
//       // ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildPremiumStatItem(
//             'Team',
//             stats.totalTeamMembers,
//             Icons.people_alt_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Present',
//             stats.presentToday,
//             Icons.verified_user_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Leaves',
//             stats.pendingLeaves,
//             Icons.beach_access_rounded,
//           ),

//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Absent',
//             stats.absentToday,
//             Icons.person_off_rounded,
//           ),
//           SizedBox(width: spacing),

//           // ✅ Safe percentage display
//           _buildPremiumStatItem(
//             'OverAll Present',
//             overallPresentPercentage,
//             Icons.trending_up_rounded,
//             isPercentage: true,
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ UPDATED METHOD with isPercentage parameter
//   Widget _buildPremiumStatItem(
//     String label,
//     int value,
//     IconData icon, {
//     bool isPercentage = false,
//   }) {
//     return Flexible(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, size: 20, color: Colors.white),
//           ),
//           const SizedBox(height: 8),
//           FittedBox(
//             child: Text(
//               isPercentage ? '$value%' : value.toString(),
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
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
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/models/managermodels/manager_dashboard_model.dart';
// import 'package:AttendanceApp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:AttendanceApp/view_models/projectviewmodels/project_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class PresentDashboardCardSection extends StatefulWidget {
//   const PresentDashboardCardSection({super.key});

//   @override
//   State<PresentDashboardCardSection> createState() =>
//       _PresentDashboardCardSectionState();
// }

// class _PresentDashboardCardSectionState
//     extends State<PresentDashboardCardSection> {
//   @override
//   void initState() {
//     super.initState();
//     // Initialize project data when widget loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final projectViewModel = Provider.of<ProjectViewModel>(
//         context,
//         listen: false,
//       );
//       projectViewModel.initialize();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);
//     final stats = viewModel.stats;

//     if (stats == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Stats Cards - Responsive Design
//                 _buildPremiumStatsRow(stats, constraints),
//                 //const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPremiumStatsRow(
//     DashboardStats stats,
//     BoxConstraints constraints,
//   ) {
//     final isPortrait = constraints.maxHeight > constraints.maxWidth;
//     final spacing = isPortrait ? 8.0 : 16.0;

//     // ✅ DEBUG: Let's check what values we're getting
//     print('🔍 DEBUG STATS:');
//     print('Total Team Members: ${stats.totalTeamMembers}');
//     print('Overall Present: ${stats.overallPresent}');
//     print('Present Today: ${stats.presentToday}');
//     print('Absent Today: ${stats.absentToday}');

//     // ✅ SAFE Percentage Calculation with validation
//     final totalTeamMembers = stats.totalTeamMembers;
//     final overallPresentValue = stats.overallPresent;

//     int overallPresentPercentage;

//     if (totalTeamMembers <= 0) {
//       overallPresentPercentage = 0;
//     } else if (overallPresentValue > totalTeamMembers) {
//       // ✅ If overallPresent is greater than total members, cap at 100%
//       print(
//         '⚠️ WARNING: overallPresent ($overallPresentValue) > totalTeamMembers ($totalTeamMembers)',
//       );
//       overallPresentPercentage = 100;
//     } else {
//       overallPresentPercentage = (overallPresentValue / totalTeamMembers * 100)
//           .round();
//     }

//     print('📊 Calculated Percentage: $overallPresentPercentage%');

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.primary.withOpacity(0.8),
//             AppColors.secondary.withOpacity(0.6),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildPremiumStatItem(
//             'Team',
//             stats.totalTeamMembers,
//             Icons.people_alt_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Present',
//             stats.presentToday,
//             Icons.verified_user_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Absent',
//             stats.absentToday,
//             Icons.person_off_rounded,
//           ),
//           SizedBox(width: spacing),
//           _buildPremiumStatItem(
//             'Leaves',
//             stats.pendingLeaves,
//             Icons.beach_access_rounded,
//           ),
//           SizedBox(width: spacing),
//           // ✅ Safe percentage display
//           _buildPremiumStatItem(
//             'OverAll Present',
//             overallPresentPercentage,
//             Icons.trending_up_rounded,
//             isPercentage: true, // ✅ This parameter now exists
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ UPDATED METHOD with isPercentage parameter
//   Widget _buildPremiumStatItem(
//     String label,
//     int value,
//     IconData icon, {
//     bool isPercentage = false, // ✅ Add this optional parameter
//   }) {
//     return Flexible(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 2,
//               ),
//             ),
//             child: Icon(icon, size: 22, color: Colors.white),
//           ),
//           const SizedBox(height: 12),
//           FittedBox(
//             child: Text(
//               isPercentage
//                   ? '$value%'
//                   : value.toString(), // ✅ Conditional display
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.9),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
