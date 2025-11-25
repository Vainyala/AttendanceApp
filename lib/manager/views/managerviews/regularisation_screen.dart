// views/regularisation/regularisation_screen.dart
import 'package:attendanceapp/manager/models/regularisationmodels/regularisation_model.dart';
import 'package:attendanceapp/manager/view_models/regularisationviewmodel/regularisation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../core/widgets/bottom_navigation.dart';
import 'leavescreen.dart';
import 'manager_dashboard_screen.dart';
import 'timeline.dart';
import '../../core/view_models/theme_view_model.dart';

class RegularisationScreen extends StatefulWidget {
  final User user;

  const RegularisationScreen({super.key, required this.user});

  @override
  State<RegularisationScreen> createState() => _RegularisationScreenState();
}

class _RegularisationScreenState extends State<RegularisationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegularisationViewModel>().initialize(
        userId: widget.user.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Regularization',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        backgroundColor: AppColors.grey300,
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<RegularisationViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isSyncing) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.sync),
                onPressed: viewModel.syncData,
                tooltip: 'Sync Data',
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.secondary.withOpacity(0.1),
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Consumer<RegularisationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.requests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null && viewModel.requests.isEmpty) {
              return _buildErrorWidget(viewModel);
            }

            return Column(
              children: [
                // Stats Section
                _buildStatsSection(viewModel),

                // Filter Chips
                _buildFilterSection(viewModel),

                // Requests List
                Expanded(child: _buildRequestsList(viewModel)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRequestDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: 1,
        onTabChanged: (index) => _handleBottomNavigation(index, context),
      ),
    );
  }

  Widget _buildErrorWidget(RegularisationViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: viewModel.refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(RegularisationViewModel viewModel) {
    final stats = viewModel.requestStats;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Regulariszation Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                'Total',
                stats['total']?.toString() ?? '0',
                AppColors.primary,
              ),
              _buildStatItem(
                'Pending',
                stats['pending']?.toString() ?? '0',
                AppColors.warning,
              ),
              _buildStatItem(
                'Approved',
                stats['approved']?.toString() ?? '0',
                AppColors.success,
              ),
              _buildStatItem(
                'Rejected',
                stats['rejected']?.toString() ?? '0',
                AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
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
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(RegularisationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', RegularisationFilter.all, viewModel),
          _buildFilterChip('Pending', RegularisationFilter.pending, viewModel),
          _buildFilterChip(
            'Approved',
            RegularisationFilter.approved,
            viewModel,
          ),
          _buildFilterChip(
            'Rejected',
            RegularisationFilter.rejected,
            viewModel,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    RegularisationFilter filter,
    RegularisationViewModel viewModel,
  ) {
    final isSelected = viewModel.currentFilter == filter;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => viewModel.changeFilter(filter),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRequestsList(RegularisationViewModel viewModel) {
    final requests = viewModel.filteredRequests;

    if (requests.isEmpty) {
      return _buildEmptyState(viewModel);
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request, viewModel);
        },
      ),
    );
  }

  Widget _buildEmptyState(RegularisationViewModel viewModel) {
    String message;
    IconData icon;

    switch (viewModel.currentFilter) {
      case RegularisationFilter.pending:
        message = 'No pending regularization requests';
        icon = Icons.check_circle_outline;
        break;
      case RegularisationFilter.approved:
        message = 'No approved regularization requests';
        icon = Icons.thumb_up_outlined;
        break;
      case RegularisationFilter.rejected:
        message = 'No rejected regularization requests';
        icon = Icons.thumb_down_outlined;
        break;
      case RegularisationFilter.all:
      default:
        message = 'No regularization requests found';
        icon = Icons.description_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create a new request',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    RegularisationRequest request,
    RegularisationViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.getProjectName(request.projectId),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.formattedDate,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: request.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        request.statusIcon,
                        size: 14,
                        color: request.statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request.displayStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: request.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details
            Text(
              request.displayType,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 8),

            Text(
              request.reason,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Actions for pending requests
            if (request.isPending) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(request.id, viewModel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showEditDialog(request, viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Dialog methods
  void _showCreateRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Regularization Request'),
        content: const Text(
          'This feature will be implemented in the next phase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(String requestId, RegularisationViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await viewModel.cancelRegularisationRequest(
                requestId,
              );
              _showSnackBar(result.message, isSuccess: result.success);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    RegularisationRequest request,
    RegularisationViewModel viewModel,
  ) {
    // Implementation for edit dialog
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
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
