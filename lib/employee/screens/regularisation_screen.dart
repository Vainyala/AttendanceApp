import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/regularisation_provider.dart';
import '../models/attendance_model.dart';
import '../utils/app_styles.dart';
import '../utils/app_helpers.dart';
import '../widgets/custom_bars.dart';
import '../widgets/monthly_stats_header.dart';
import '../widgets/project_selection_dialog.dart';
import '../widgets/regularisation_detail_dailog.dart';
import '../widgets/regularization_widgets/attendance_cards.dart';
import '../widgets/status_badge.dart';

class RegularisationScreen extends StatefulWidget {
  const RegularisationScreen({super.key});

  @override
  State<RegularisationScreen> createState() => _RegularisationScreenState();
}

class _RegularisationScreenState extends State<RegularisationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DateTime> _filteredMonths = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeScreen();
      _isInitialized = true;
    }
  }

  void _initializeScreen() {
    final provider = context.read<RegularisationProvider>();

    if (provider.availableMonths.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.initializeMonths();
        provider.loadAttendance();
      });

      final now = DateTime.now();
      _filteredMonths = [
        DateTime(now.year, now.month - 1),
        DateTime(now.year, now.month),
      ];
    } else {
      final now = DateTime.now();
      _filteredMonths = provider.availableMonths.where((month) {
        final isCurrentMonth = month.month == now.month && month.year == now.year;
        final prevMonthDate = DateTime(now.year, now.month - 1);
        final isPreviousMonth = month.month == prevMonthDate.month &&
            month.year == prevMonthDate.year;
        return isCurrentMonth || isPreviousMonth;
      }).toList();
    }

    _tabController = TabController(
      length: _filteredMonths.length,
      vsync: this,
      initialIndex: _filteredMonths.length - 1,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final selectedMonth = _filteredMonths[_tabController.index];
        final actualIndex = provider.availableMonths.indexOf(selectedMonth);
        if (actualIndex != -1) {
          provider.setCurrentMonthIndex(actualIndex);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Navigation Drawer
  Widget _buildNavigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.textLight,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'John Doe',
                  style: AppStyles.headingLarge.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                Text(
                  'john.doe@company.com',
                  style: AppStyles.text.copyWith(
                    color: AppColors.textLight.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.account_tree, 'Organization Structure', () {}),
          _buildDrawerItem(Icons.event_note, 'Holiday Schedules', () {}),
          _buildDrawerItem(Icons.folder, 'Projects (Circulars/Notes)', () {}),
          _buildDrawerItem(Icons.support_agent, 'Service Desk', () {}),
          _buildDrawerItem(Icons.help_outline, 'Help & FAQs', () {}),
          const Divider(),
          _buildDrawerItem(Icons.business, 'My Company', () {}),
          _buildDrawerItem(Icons.work, 'My Projects', () {}),
          _buildDrawerItem(Icons.people, 'My Clients', () {}),
          _buildDrawerItem(Icons.contacts, 'Contacts List', () {}),
          const Divider(),
          _buildDrawerItem(Icons.schedule, 'Request (Shift Plan)', () {}),
          _buildDrawerItem(Icons.settings, 'Settings', () {}),
          _buildDrawerItem(Icons.info_outline, 'About', () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title, style: AppStyles.text),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  // Show regularisation details with month check
  void _showRegularisationDetails(
      String dateStr,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,
      String status,
      ) {
    final provider = context.read<RegularisationProvider>();
    final projectGroups = provider.getProjectGroups(dayRecords);

    // Check if month is editable
    final isMonthEditable = provider.isMonthEditable(actualDate);

    // If previous month, show read-only view
    if (!isMonthEditable) {
      _showPreviousMonthMessage(dateStr, actualDate, projectGroups, status);
      return;
    }

    // Current month logic
    final isEditable = status == 'Apply' || status == 'Rejected';

    // For Approved or Rejected with multiple projects, show all in one dialog
    if ((status == 'Approved' || status == 'Rejected') && projectGroups.length > 1) {
      _showProjectSelectionDialog(
        dateStr,
        actualDate,
        projectGroups,
        status,
        false, // Read-only
      );
    } else if (projectGroups.length == 1) {
      final projectEntry = projectGroups.entries.first;
      _showProjectDetailDialog(
        dateStr,
        actualDate,
        projectEntry.key,
        projectEntry.value,
        status,
        isEditable,
      );
    } else if (projectGroups.length > 1) {
      _showProjectSelectionDialog(
        dateStr,
        actualDate,
        projectGroups,
        status,
        isEditable,
      );
    }
  }

  // Show message for previous month
  void _showPreviousMonthMessage(
      String dateStr,
      DateTime actualDate,
      Map<String, List<AttendanceModel>> projectGroups,
      String status,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning.shade700),
            const SizedBox(width: 12),
            Text('Previous Month', style: AppStyles.headingLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: $dateStr',
              style: AppStyles.heading.copyWith(color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.shade200),
              ),
              child: Text(
                'This record is from a previous month and cannot be edited or applied for regularisation. Only current month records can be regularised.',
                style: AppStyles.text.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Text('Status: ', style: AppStyles.text),
            const SizedBox(height: 8),
            StatusBadge(status: status, fontSize: 12),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Show detailed view in read-only mode
              if (projectGroups.length == 1) {
                final projectEntry = projectGroups.entries.first;
                _showProjectDetailDialog(
                  dateStr,
                  actualDate,
                  projectEntry.key,
                  projectEntry.value,
                  status,
                  false, // Read-only
                );
              }
            },
            icon: const Icon(Icons.visibility),
            label: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  // Project Selection Dialog (extracted for reusability)
  void _showProjectSelectionDialog(
      String dateStr,
      DateTime actualDate,
      Map<String, List<AttendanceModel>> projectGroups,
      String status,
      bool isEditable,
      ) {
    showDialog(
      context: context,
      builder: (context) => ProjectSelectionDialog(
        dateStr: dateStr,
        actualDate: actualDate,
        projectGroups: projectGroups,
        status: status,
        isEditable: isEditable,
        onProjectSelected: (projectName, projectRecords) {
          Navigator.pop(context);
          _showProjectDetailDialog(
            dateStr,
            actualDate,
            projectName,
            projectRecords,
            status,
            isEditable,
          );
        },
      ),
    );
  }

  // Project Detail Dialog (extracted for reusability)
  void _showProjectDetailDialog(
      String dateStr,
      DateTime actualDate,
      String projectName,
      List<AttendanceModel> projectRecords,
      String status,
      bool isEditable,
      ) {
    showDialog(
      context: context,
      builder: (context) => RegularisationDetailDialog(
        dateStr: dateStr,
        actualDate: actualDate,
        projectName: projectName,
        projectRecords: projectRecords,
        status: status,
        isEditable: isEditable,
        onSubmit: _handleSubmit,
      ),
    );
  }

  void _handleSubmit(
      String dateStr,
      String projectName,
      TimeOfDay selectedTime,
      String justification,
      DateTime actualDate,
      ) {
    context.read<RegularisationProvider>().submitRegularisation(
      date: dateStr,
      projectName: projectName,
      time: selectedTime,
      type: selectedTime.hour < 12 ? 'AM' : 'PM',
      notes: justification,
      description: '',
      actualDate: actualDate,
    );

    AppHelpers.showSuccessSnackbar(
      context,
      'Regularization request submitted successfully',
    );
  }

  Widget _buildRecordsList(DateTime month) {
    final provider = context.read<RegularisationProvider>();
    final categorized = provider.getCategorizedRecords(month);

    final allRecords = <Map<String, dynamic>>[];
    for (var records in categorized.values) {
      allRecords.addAll(records);
    }

    allRecords.sort((a, b) {
      final dateA = a['actualDate'] as DateTime;
      final dateB = b['actualDate'] as DateTime;
      return dateB.compareTo(dateA);
    });

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: AppColors.grey300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Records Found',
              style: AppStyles.headingLarge.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 8),
            Text('No attendance records for this month', style: AppStyles.text),
          ],
        ),
      );
    }

    return Column(
      children: [
        MonthlyStatsHeader(month: month),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allRecords.length,
            itemBuilder: (context, index) {
              final record = allRecords[index];
              return AttendanceCard(
                date: record['date'],
                hours: record['hours'],
                shortfall: record['shortfall'],
                status: _getStatusFromRecord(record),
                actualDate: record['actualDate'],
                dayRecords: record['records'],
                onTap: () => _showRegularisationDetails(
                  record['date'],
                  record['actualDate'],
                  record['records'],
                  _getStatusFromRecord(record),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getStatusFromRecord(Map<String, dynamic> record) {
    final provider = context.read<RegularisationProvider>();
    final actualDate = record['actualDate'] as DateTime;
    final shortfall = record['shortfall'] as String;
    return provider.getStatusForDay(actualDate, shortfall);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 1,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Regularisation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Consumer<RegularisationProvider>(
              builder: (context, provider, _) {
                if (provider.availableMonths.isNotEmpty) {
                  final now = DateTime.now();
                  _filteredMonths = provider.availableMonths.where((month) {
                    final isCurrentMonth = month.month == now.month && month.year == now.year;
                    final prevMonthDate = DateTime(now.year, now.month - 1);
                    final isPreviousMonth = month.month == prevMonthDate.month &&
                        month.year == prevMonthDate.year;
                    return isCurrentMonth || isPreviousMonth;
                  }).toList();
                }

                return Container(
                  color: AppColors.textLight,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    tabAlignment: TabAlignment.fill,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 3,
                      ),
                    ),
                    labelColor: AppColors.primaryBlue,
                    unselectedLabelColor: AppColors.grey600,
                    labelStyle: AppStyles.label,
                    unselectedLabelStyle: AppStyles.text,
                    tabs: _filteredMonths.map((month) {
                      final isCurrentMonth = month.month == DateTime.now().month &&
                          month.year == DateTime.now().year;

                      return Tab(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            Text(DateFormat('MMM yyyy').format(month)),
                            if (isCurrentMonth) ...[
                              const SizedBox(height: 2),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
        drawer: _buildNavigationDrawer(),
        body: Consumer<RegularisationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Loading attendance data...', style: AppStyles.text),
                  ],
                ),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error.shade300,
                    ),
                    const SizedBox(height: 20),
                    Text('Oops!', style: AppStyles.headingLarge),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppStyles.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: provider.loadAttendance,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: _filteredMonths
                  .map((month) => _buildRecordsList(month))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}