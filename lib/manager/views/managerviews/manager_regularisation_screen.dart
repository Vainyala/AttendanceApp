// views/managerviews/manager_regularisation_screen.dart
import 'package:AttendanceApp/manager/models/regularisationmodels/manager_regularisation_model.dart';
import 'package:AttendanceApp/manager/view_models/regularisationviewmodel/manager_regularisation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/bottom_navigation.dart';
import '../../models/user_model.dart';
import 'leavescreen.dart';
import 'manager_dashboard_screen.dart';
import 'timeline.dart';
import '../../core/view_models/theme_view_model.dart';
import 'manager_regularisation_detail_screen.dart';

class ManagerRegularisationScreen extends StatefulWidget {
  final User user;

  const ManagerRegularisationScreen({super.key, required this.user});

  @override
  State<ManagerRegularisationScreen> createState() =>
      _ManagerRegularisationScreenState();
}

class _ManagerRegularisationScreenState
    extends State<ManagerRegularisationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ManagerRegularisationViewModel>()
          .loadManagerRegularisationData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppTheme>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Regularisation Requests',
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
      body: Consumer<ManagerRegularisationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.allRequests.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (viewModel.error.isNotEmpty) {
            return _buildErrorWidget(viewModel, isDarkMode);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.loadManagerRegularisationData();
            },
            child: Column(
              children: [
                // Header Stats - More Compact
                _buildHeaderStats(viewModel, isDarkMode),

                // Filter Section - Improved Design
                _buildFilterSection(viewModel, isDarkMode),

                // Requests List
                Expanded(child: _buildRequestsList(viewModel, isDarkMode)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: 1,
        onTabChanged: (index) => _handleBottomNavigation(index, context),
      ),
    );
  }

  Widget _buildErrorWidget(
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
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
              viewModel.error,
              style: TextStyle(
                color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.loadManagerRegularisationData(),
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

  Widget _buildHeaderStats(
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
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
                viewModel.stats.currentMonthRequests.toString(),
                AppColors.primary,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Pending',
                viewModel.stats.pendingRequests.toString(),
                AppColors.warning,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Approved',
                viewModel.stats.approvedRequests.toString(),
                AppColors.success,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Rejected',
                viewModel.stats.rejectedRequests.toString(),
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

  Widget _buildSearchButton(
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
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

  void _showSearchDialog(
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
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

  Widget _buildStatDivider(bool isDarkMode) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDarkMode ? AppColors.grey700 : AppColors.grey200,
    );
  }

  Widget _buildFilterSection(
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
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
                    ManagerRegularisationFilter.all,
                    viewModel,
                    isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    ManagerRegularisationFilter.pending,
                    viewModel,
                    isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Approved',
                    ManagerRegularisationFilter.approved,
                    viewModel,
                    isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Rejected',
                    ManagerRegularisationFilter.rejected,
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
    ManagerRegularisationFilter filter,
    ManagerRegularisationViewModel viewModel,
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
      onSelected: (_) => viewModel.changeFilter(filter),
      backgroundColor: isDarkMode ? AppColors.grey800 : AppColors.grey100,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildExportButton(
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
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
          onTap: viewModel.isExporting ? null : () => viewModel.exportToExcel(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: viewModel.isExporting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
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

  Widget _buildRequestsList(
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
    final requests = viewModel.filteredRequests;

    if (requests.isEmpty) {
      return _buildEmptyState(viewModel, isDarkMode);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request, viewModel, isDarkMode);
      },
    );
  }

  Widget _buildEmptyState(
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
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
                Icons.checklist_rounded,
                color: isDarkMode ? AppColors.grey500 : AppColors.grey400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${viewModel.currentFilter.name} Requests',
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
              'All ${viewModel.currentFilter.name.toLowerCase()} requests have been processed',
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

  // Widget _buildRequestCard(
  //   ManagerRegularisationRequest request,
  //   ManagerRegularisationViewModel viewModel,
  //   bool isDarkMode,
  // ) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(16),
  //       color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       borderRadius: BorderRadius.circular(16),
  //       child: InkWell(
  //         onTap: () => _navigateToDetailScreen(request, viewModel),
  //         borderRadius: BorderRadius.circular(16),
  //         child: Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Header Row
  //               Row(
  //                 children: [
  //                   // Avatar
  //                   Container(
  //                     width: 44,
  //                     height: 44,
  //                     decoration: BoxDecoration(
  //                       color: _getProfileColor(request.employeeName),
  //                       shape: BoxShape.circle,
  //                       image: request.employeePhoto.isNotEmpty
  //                           ? DecorationImage(
  //                               image: NetworkImage(request.employeePhoto),
  //                               fit: BoxFit.cover,
  //                             )
  //                           : null,
  //                     ),
  //                     child: request.employeePhoto.isEmpty
  //                         ? Center(
  //                             child: Text(
  //                               _getInitials(request.employeeName),
  //                               style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.w600,
  //                                 fontSize: 14,
  //                               ),
  //                             ),
  //                           )
  //                         : null,
  //                   ),
  //                   const SizedBox(width: 12),

  //                   // Employee Info
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           request.employeeName,
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w600,
  //                             fontSize: 15,
  //                             color: isDarkMode
  //                                 ? AppColors.textInverse
  //                                 : AppColors.textPrimary,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 2),
  //                         Text(
  //                           request.employeeRole,
  //                           style: TextStyle(
  //                             color: isDarkMode
  //                                 ? AppColors.grey400
  //                                 : AppColors.textSecondary,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),

  //                   // Status Badge
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 12,
  //                       vertical: 6,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: viewModel
  //                           .getStatusColor(request.status)
  //                           .withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(20),
  //                       border: Border.all(
  //                         color: viewModel
  //                             .getStatusColor(request.status)
  //                             .withOpacity(0.3),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       viewModel.getStatusText(request.status),
  //                       style: TextStyle(
  //                         color: viewModel.getStatusColor(request.status),
  //                         fontSize: 11,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 16),

  //               // Request Details Grid
  //               Container(
  //                 padding: const EdgeInsets.all(16),
  //                 decoration: BoxDecoration(
  //                   color: isDarkMode
  //                       ? AppColors.grey800.withOpacity(0.5)
  //                       : AppColors.grey50,
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     // Date and Type
  //                     Row(
  //                       children: [
  //                         _buildDetailItem(
  //                           Icons.calendar_today_rounded,
  //                           request.formattedDate,
  //                           isDarkMode,
  //                         ),
  //                         const Spacer(),
  //                         _buildDetailItem(
  //                           Icons.work_history_rounded,
  //                           viewModel.getTypeText(request.type),
  //                           isDarkMode,
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 12),

  //                     // Time Comparison
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: _buildTimeComparison(
  //                             'Actual',
  //                             '${_formatTime(request.actualCheckIn)} - ${_formatTime(request.actualCheckOut)}',
  //                             Colors.orange,
  //                             isDarkMode,
  //                           ),
  //                         ),
  //                         // const SizedBox(width: 12),
  //                         // Expanded(
  //                         //   child: _buildTimeComparison(
  //                         //     'Expected',
  //                         //     '${_formatTime(request.expectedCheckIn)} - ${_formatTime(request.expectedCheckOut)}',
  //                         //     Colors.green,
  //                         //     isDarkMode,
  //                         //   ),
  //                         // ),
  //                         const SizedBox(width: 12),
  //                         Expanded(
  //                           child: _buildTimeComparison(
  //                             'Shortfall',
  //                             request.formattedShortfallTime,
  //                             AppColors.error,
  //                             isDarkMode,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),

  //               const SizedBox(height: 12),

  //               // Reason Preview
  //               if (request.reason.isNotEmpty) ...[
  //                 Text(
  //                   request.reason,
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: isDarkMode
  //                         ? AppColors.grey400
  //                         : AppColors.textSecondary,
  //                     height: 1.4,
  //                   ),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 8),
  //               ],

  //               // Action Required Badge
  //               if (request.isPending) ...[
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 12,
  //                     vertical: 6,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: AppColors.warning.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(20),
  //                     border: Border.all(
  //                       color: AppColors.warning.withOpacity(0.3),
  //                     ),
  //                   ),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Icon(
  //                         Icons.warning_amber_rounded,
  //                         size: 12,
  //                         color: AppColors.warning,
  //                       ),
  //                       const SizedBox(width: 6),
  //                       Text(
  //                         'Action Required',
  //                         style: TextStyle(
  //                           color: AppColors.warning,
  //                           fontSize: 11,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildRequestCard(
    ManagerRegularisationRequest request,
    ManagerRegularisationViewModel viewModel,
    bool isDarkMode,
  ) {
    // ✅ Get employee projects from ViewModel
    final employeeProjects = viewModel.getEmployeeProjects(
      request.employeeEmail,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? AppColors.surfaceDark : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToDetailScreen(request, viewModel),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ UPDATED: Header Row with Project List on Right Side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar and Basic Info
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          // Employee Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _getProfileColor(request.employeeName),
                              shape: BoxShape.circle,
                              image: request.employeePhoto.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        request.employeePhoto,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: request.employeePhoto.isEmpty
                                ? Center(
                                    child: Text(
                                      _getInitials(request.employeeName),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),

                          // Employee Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.employeeName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? AppColors.textInverse
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  request.employeeRole,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.grey400
                                        : AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: viewModel
                                        .getStatusColor(request.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    viewModel.getStatusText(request.status),
                                    style: TextStyle(
                                      color: viewModel.getStatusColor(
                                        request.status,
                                      ),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ✅ ADDED: Project List - Right Side (IndividualGraph style)
                    Expanded(
                      flex: 2,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Projects:',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode
                                    ? AppColors.grey400
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: employeeProjects.take(3).map((
                                    project,
                                  ) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(
                                            0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.work_outline_rounded,
                                            size: 10,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              project,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            // Show more projects count if there are more than 3
                            if (employeeProjects.length > 3) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.grey200.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '+${employeeProjects.length - 3} more',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDarkMode
                                        ? AppColors.grey400
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Request Details Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.grey800.withOpacity(0.5)
                        : AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Date and Type
                      Row(
                        children: [
                          _buildDetailItem(
                            Icons.calendar_today_rounded,
                            request.formattedDate,
                            isDarkMode,
                          ),
                          const Spacer(),
                          _buildDetailItem(
                            Icons.work_history_rounded,
                            viewModel.getTypeText(request.type),
                            isDarkMode,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Time Comparison
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeComparison(
                              'Check IN & OUT Time',
                              '${_formatTime(request.actualCheckIn)} - ${_formatTime(request.actualCheckOut)}',
                              Colors.orange,
                              isDarkMode,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Expanded(
                          //   child: _buildTimeComparison(
                          //     'Expected',
                          //     '${_formatTime(request.expectedCheckIn)} - ${_formatTime(request.expectedCheckOut)}',
                          //     Colors.green,
                          //     isDarkMode,
                          //   ),
                          // ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimeComparison(
                              'Shortfall',
                              request.formattedShortfallTime,
                              AppColors.error,
                              isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Reason Preview
                if (request.reason.isNotEmpty) ...[
                  Text(
                    request.reason,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? AppColors.grey400
                          : AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],

                // Action Required Badge
                if (request.isPending) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Action Required',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.textInverse : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeComparison(
    String label,
    String time,
    Color color,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? AppColors.grey400 : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // Helper Methods
  String _getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
  }

  Color _getProfileColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.secondary,
      AppColors.error,
    ];
    final index = name.hashCode % colors.length;
    return colors[index];
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Navigation Methods
  void _navigateToDetailScreen(
    ManagerRegularisationRequest request,
    ManagerRegularisationViewModel viewModel,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerRegularisationDetailScreen(
          request: request,
          viewModel: viewModel,
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
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManagerLeaveScreen(user: widget.user),
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
