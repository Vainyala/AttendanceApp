import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/models/team_model.dart';
import 'package:attendanceapp/manager/view_models/employeeviewmodels/employee_details_view_model.dart';
import 'package:attendanceapp/manager/widgets/employee/attendance_history_list.dart';
import 'package:attendanceapp/manager/widgets/employee/attendance_summary_cards.dart';
import 'package:attendanceapp/manager/widgets/employee/employee_profile_header.dart';
import 'package:attendanceapp/manager/widgets/employee/performance_metrics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final TeamMember teamMember;

  const EmployeeDetailsScreen({super.key, required this.teamMember});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEmployeeDetails();
  }

  void _loadEmployeeDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<EmployeeDetailsViewModel>(
        context,
        listen: false,
      );
      viewModel.loadEmployeeDetails(widget.teamMember);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final viewModel = Provider.of<EmployeeDetailsViewModel>(context);

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Employee Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
            color: isDarkMode ? AppColors.grey300 : AppColors.grey700,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: isDarkMode
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
        ),
      ),
      body: viewModel.isLoading
          ? _buildLoadingState(isDarkMode)
          : viewModel.employeeDetails == null
          ? _buildErrorState(viewModel.errorMessage, isDarkMode)
          : _buildContent(viewModel, isDarkMode),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading employee details...',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.grey400 : AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 28,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load',
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
              errorMessage ?? 'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.grey400 : AppColors.grey600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadEmployeeDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? AppColors.primaryLight
                    : AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(EmployeeDetailsViewModel viewModel, bool isDarkMode) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          EmployeeProfileHeader(viewModel: viewModel),

          const SizedBox(height: 24),

          // Attendance Summary
          _buildSectionHeader('Attendance Overview', isDarkMode),
          const SizedBox(height: 16),
          AttendanceSummaryCards(viewModel: viewModel),

          const SizedBox(height: 24),

          // Performance Metrics
          _buildSectionHeader('Performance Metrics', isDarkMode),
          const SizedBox(height: 16),
          PerformanceMetricsSection(viewModel: viewModel),

          const SizedBox(height: 24),

          // Attendance History
          _buildSectionHeader('Recent Attendance', isDarkMode),
          const SizedBox(height: 16),
          AttendanceHistoryList(viewModel: viewModel),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:attendanceapp/widgets/employee/attendance_history_list.dart';
// import 'package:attendanceapp/widgets/employee/attendance_summary_cards.dart';
// import 'package:attendanceapp/widgets/employee/employee_profile_header.dart';
// import 'package:attendanceapp/widgets/employee/performance_metrics.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class EmployeeDetailsScreen extends StatefulWidget {
//   final TeamMember teamMember;

//   const EmployeeDetailsScreen({super.key, required this.teamMember});

//   @override
//   State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
// }

// class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _loadEmployeeDetails();
//   }

//   void _loadEmployeeDetails() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<EmployeeDetailsViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.loadEmployeeDetails(widget.teamMember);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final viewModel = Provider.of<EmployeeDetailsViewModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: Text(
//           'Employee Profile',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade800,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios_rounded,
//             size: 20,
//             color: Colors.grey.shade700,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         centerTitle: true,
//       ),
//       body: viewModel.isLoading
//           ? _buildLoadingState()
//           : viewModel.employeeDetails == null
//           ? _buildErrorState(viewModel.errorMessage)
//           : _buildContent(viewModel),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 24,
//             height: 24,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading employee details...',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String? errorMessage) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.error_outline_rounded,
//                 size: 28,
//                 color: Colors.red.shade600,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Unable to Load',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               errorMessage ?? 'Please check your connection and try again.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade600,
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _loadEmployeeDetails,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue.shade600,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'Try Again',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(EmployeeDetailsViewModel viewModel) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Profile Header
//           EmployeeProfileHeader(viewModel: viewModel),

//           const SizedBox(height: 20),

//           // Attendance Summary
//           _buildSectionHeader('Attendance Overview'),
//           const SizedBox(height: 12),
//           AttendanceSummaryCards(viewModel: viewModel),

//           const SizedBox(height: 20),

//           // Performance Metrics
//           _buildSectionHeader('Performance Metrics'),
//           const SizedBox(height: 12),
//           PerformanceMetricsSection(viewModel: viewModel),

//           const SizedBox(height: 20),

//           // Attendance History
//           _buildSectionHeader('Recent Attendance'),
//           const SizedBox(height: 12),
//           AttendanceHistoryList(viewModel: viewModel),

//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: Colors.grey.shade800,
//         letterSpacing: -0.2,
//       ),
//     );
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:attendanceapp/widgets/employee/attendance_history_list.dart';
// import 'package:attendanceapp/widgets/employee/attendance_summary_cards.dart';
// import 'package:attendanceapp/widgets/employee/employee_profile_header.dart';
// import 'package:attendanceapp/widgets/employee/performance_metrics.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class EmployeeDetailsScreen extends StatefulWidget {
//   final TeamMember teamMember;

//   const EmployeeDetailsScreen({super.key, required this.teamMember});

//   @override
//   State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
// }

// class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _loadEmployeeDetails();
//   }

//   void _loadEmployeeDetails() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<EmployeeDetailsViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.loadEmployeeDetails(widget.teamMember);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final viewModel = Provider.of<EmployeeDetailsViewModel>(context);

//     return Scaffold(
//       backgroundColor: AppColors.grey400,
//       appBar: AppBar(
//         title: const Text(
//           'Employee Details',
//           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: theme.colorScheme.surface,
//         elevation: 0,
//         scrolledUnderElevation: 1,
//         shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
//       ),
//       body: viewModel.isLoading
//           ? _buildAppleLoadingState(theme)
//           : viewModel.employeeDetails == null
//           ? _buildAppleErrorState(theme, viewModel.errorMessage)
//           : _buildContent(theme, viewModel),
//     );
//   }

//   Widget _buildAppleLoadingState(ThemeData theme) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 22,
//             height: 22,
//             child: CircularProgressIndicator(
//               strokeWidth: 2.5,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 theme.colorScheme.primary,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Loading Employee Details',
//             style: TextStyle(
//               fontSize: 15,
//               color: theme.colorScheme.onBackground.withOpacity(0.6),
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppleErrorState(ThemeData theme, String? errorMessage) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 64,
//               height: 64,
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.error_outline_rounded,
//                 size: 32,
//                 color: Colors.red,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Unable to Load Details',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.onBackground,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               errorMessage ??
//                   'An unexpected error occurred while loading employee details.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: theme.colorScheme.onBackground.withOpacity(0.6),
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _loadEmployeeDetails,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: theme.colorScheme.primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Try Again',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent(ThemeData theme, EmployeeDetailsViewModel viewModel) {
//     return CustomScrollView(
//       physics: const BouncingScrollPhysics(),
//       slivers: [
//         // Profile Header
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
//             child: EmployeeProfileHeader(viewModel: viewModel),
//           ),
//         ),

//         // Attendance Summary Cards
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: AttendanceSummaryCards(viewModel: viewModel),
//           ),
//         ),

//         // Performance Metrics
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: PerformanceMetricsSection(viewModel: viewModel),
//           ),
//         ),

//         // Attendance History Header
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//             child: Row(
//               children: [
//                 Text(
//                   'Attendance History',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: theme.colorScheme.onBackground,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   'Recent',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: theme.colorScheme.onBackground.withOpacity(0.6),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Attendance History List
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: AttendanceHistoryList(viewModel: viewModel),
//           ),
//         ),

//         // Bottom Padding
//         const SliverToBoxAdapter(child: SizedBox(height: 20)),
//       ],
//     );
//   }
// }

/*  #####################################################################################################################

***************************************         A I S C R E E N C O D E             *****************************************

############################################################################################################################ */

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:attendanceapp/widgets/employee/attendance_history_list.dart';
// import 'package:attendanceapp/widgets/employee/attendance_summary_cards.dart';
// import 'package:attendanceapp/widgets/employee/employee_profile_header.dart';
// import 'package:attendanceapp/widgets/employee/performance_metrics.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class EmployeeDetailsScreen extends StatefulWidget {
//   final TeamMember teamMember;

//   const EmployeeDetailsScreen({super.key, required this.teamMember});

//   @override
//   State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
// }

// class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _loadEmployeeDetails();
//   }

//   void _loadEmployeeDetails() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final viewModel = Provider.of<EmployeeDetailsViewModel>(
//         context,
//         listen: false,
//       );
//       viewModel.loadEmployeeDetails(widget.teamMember);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<AppTheme>(context);
//     final viewModel = Provider.of<EmployeeDetailsViewModel>(context);

//     return Scaffold(
//       backgroundColor: theme.themeMode == ThemeMode.dark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         title: Text(
//           'Employee Details',
//           style: TextStyle(
//             color: theme.themeMode == ThemeMode.dark
//                 ? AppColors.textInverse
//                 : AppColors.textPrimary,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_rounded),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: theme.themeMode == ThemeMode.dark
//             ? AppColors.grey900
//             : AppColors.white,
//         elevation: 0,
//       ),
//       body: viewModel.isLoading
//           ? _buildLoadingState()
//           : viewModel.employeeDetails == null
//           ? _buildErrorState(viewModel.errorMessage)
//           : _buildContent(viewModel),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Loading employee details...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String? errorMessage) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
//           const SizedBox(height: 16),
//           Text(
//             'Failed to load details',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             errorMessage ?? 'Unknown error occurred',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: AppColors.textSecondary),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _loadEmployeeDetails,
//             child: const Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent(EmployeeDetailsViewModel viewModel) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           EmployeeProfileHeader(viewModel: viewModel),
//           const SizedBox(height: 20),
//           AttendanceSummaryCards(viewModel: viewModel),
//           const SizedBox(height: 20),
//           PerformanceMetricsSection(viewModel: viewModel),
//           const SizedBox(height: 20),
//           AttendanceHistoryList(viewModel: viewModel),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
