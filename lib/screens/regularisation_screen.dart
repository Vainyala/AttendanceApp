import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/regularisation_provider.dart';
import '../models/attendance_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_helpers.dart';
import '../utils/app_text.dart';
import '../widgets/custom_bars.dart';
import '../widgets/status_badge.dart';
import '../widgets/info_card.dart';
import '../widgets/stat_item.dart';

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
    provider.initializeMonths();
    provider.loadAttendance();

    _tabController = TabController(
      length: provider.availableMonths.length,
      vsync: this,
      initialIndex: provider.currentMonthIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        provider.setCurrentMonthIndex(_tabController.index);
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
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.textLight,
                  child: Icon(
                      Icons.person, size: 35, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 12),
                Text(
                  'John Doe',
                  style: AppStyles.headingLarge.copyWith(
                      color: AppColors.textLight),
                ),
                Text(
                  'john.doe@company.com',
                  style: AppStyles.text.copyWith(
                      color: AppColors.textLight.withOpacity(0.9)),
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

  // Monthly Statistics Header
  Widget _buildMonthlyStatsHeader(DateTime month) {
    final provider = context.read<RegularisationProvider>();
    final stats = provider.getMonthlyStatistics(month);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.textLight, size: 24),
              const SizedBox(width: 12),
              Text(
                'Monthly Overview',
                style: AppStyles.headingLarge.copyWith(
                    color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg. Shortfall',
                  stats['avgShortfall'] ?? '00:00',
                  Icons.trending_down,
                  AppColors.error.shade100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Days',
                  '${stats['totalDays'] ?? 0}',
                  Icons.calendar_today,
                  AppColors.success.shade100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSmallStatCard(
                    'Apply', stats['Apply'] ?? 0, AppColors.warning),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallStatCard(
                    'Pending', stats['Pending'] ?? 0, AppColors.warning),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallStatCard(
                    'Approved', stats['Approved'] ?? 0, AppColors.success),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallStatCard(
                    'Rejected', stats['Rejected'] ?? 0, AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon,
      Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyles.headingLarge.copyWith(
              fontSize: 24,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.text.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String label, int count, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppStyles.heading.copyWith(
              color: color.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.text.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Regularization Details Dialog
  void _showRegularisationDetails(String dateStr,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,
      String status,) {
    final provider = context.read<RegularisationProvider>();
    final projectGroups = provider.getProjectGroups(dayRecords);
    final isEditable = status == 'Apply' || status == 'Rejected';

    if (projectGroups.length == 1) {
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

  // Project Selection Dialog
  void _showProjectSelectionDialog(String dateStr,
      DateTime actualDate,
      Map<String, List<AttendanceModel>> projectGroups,
      String status,
      bool isEditable,) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primaryBlue,
                          size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateStr, style: AppStyles.headingLarge),
                            Text(
                              DateFormat('EEEE').format(actualDate),
                              style: AppStyles.text,
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: status, fontSize: 11),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Project to Regularize',
                    style: AppStyles.headingLarge.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ...projectGroups.entries.map((entry) {
                    final projectRecords = entry.value;
                    final checkIn = projectRecords.firstWhere(
                          (r) => r.type == AttendanceType.checkIn,
                      orElse: () => projectRecords.first,
                    );
                    final checkOut = projectRecords.lastWhere(
                          (r) => r.type == AttendanceType.checkOut,
                      orElse: () => projectRecords.last,
                    );

                    final duration = checkOut.timestamp.difference(
                        checkIn.timestamp);
                    final hours = duration.inHours;
                    final minutes = duration.inMinutes % 60;
                    final checkInTime = DateFormat('hh:mm a').format(
                        checkIn.timestamp);
                    final checkOutTime = DateFormat('hh:mm a').format(
                        checkOut.timestamp);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _showProjectDetailDialog(
                              dateStr,
                              actualDate,
                              entry.key,
                              projectRecords,
                              status,
                              isEditable,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.grey200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withOpacity(
                                        0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.folder_outlined,
                                    color: AppColors.primaryBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(entry.key, style: AppStyles.heading),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$checkInTime - $checkOutTime',
                                        style: AppStyles.text.copyWith(
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Worked: ${hours}h ${minutes}m',
                                        style: AppStyles.text.copyWith(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.grey300,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Project Detail Dialog with Form
  void _showProjectDetailDialog(String dateStr,
      DateTime actualDate,
      String projectName,
      List<AttendanceModel> projectRecords,
      String status,
      bool isEditable,) {
    final checkIn = projectRecords.firstWhere(
          (r) => r.type == AttendanceType.checkIn,
      orElse: () => projectRecords.first,
    );
    final checkOut = projectRecords.lastWhere(
          (r) => r.type == AttendanceType.checkOut,
      orElse: () => projectRecords.last,
    );

    TimeOfDay selectedTime = TimeOfDay.fromDateTime(checkOut.timestamp);
    final justificationController = TextEditingController();
    String managerComment = _getManagerComment(status);

    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setDialogState) =>
                Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              const Icon(Icons.edit_calendar,
                                  color: AppColors.primaryBlue, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isEditable
                                      ? 'Regularization Request'
                                      : 'Request Details',
                                  style: AppStyles.headingLarge,
                                ),
                              ),
                              StatusBadge(status: status, fontSize: 11),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Info Cards
                          InfoCard(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: dateStr,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(height: 12),
                          InfoCard(
                            icon: Icons.folder_outlined,
                            label: 'Project',
                            value: projectName,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(height: 12),
                          InfoCard(
                            icon: Icons.login,
                            label: 'Check-in Time',
                            value: DateFormat('hh:mm a').format(
                                checkIn.timestamp),
                            color: AppColors.success,
                          ),
                          const SizedBox(height: 12),
                          InfoCard(
                            icon: Icons.logout,
                            label: 'Check-out Time',
                            value: DateFormat('hh:mm a').format(
                                checkOut.timestamp),
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          InfoCard(
                            icon: Icons.access_time,
                            label: 'Worked Hours',
                            value: AppHelpers.formatDuration(
                              checkOut.timestamp.difference(checkIn.timestamp),
                            ),
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(height: 24),

                          if (isEditable) ...[
                            // Regularize Time Selection
                            Text('Shortfall Hours',
                                style: AppStyles.heading),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (time != null) {
                                  setDialogState(() => selectedTime = time);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.grey300),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.schedule,
                                        color: AppColors.primaryBlue, size: 22),
                                    const SizedBox(width: 12),
                                    Text(selectedTime.format(context),
                                        style: AppStyles.heading),
                                    const Spacer(),
                                    Icon(Icons.edit, size: 18,
                                        color: AppColors.grey600),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Justification
                            Text('Justification / Reason *',
                                style: AppStyles.heading),
                            const SizedBox(height: 8),
                            TextField(
                              controller: justificationController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Explain the reason for regularization...\n(e.g., Forgot to punch out, System issue, etc.)',
                                filled: true,
                                fillColor: AppColors.grey50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.grey300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColors.grey300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryBlue, width: 2),
                                ),
                              ),
                            ),
                          ] else
                            ...[
                              InfoCard(
                                icon: Icons.schedule,
                                label: 'Submitted Time',
                                value: selectedTime.format(context),
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(height: 12),
                              Text('Justification', style: AppStyles.heading),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.grey200),
                                ),
                                child: Text(
                                  'Forgot to check out. Was working till late.',
                                  style: AppStyles.text.copyWith(height: 1.5),
                                ),
                              ),
                            ],

                          // Manager Comment Section
                          if (status != 'Apply') ...[
                            const SizedBox(height: 20),
                            _buildManagerCommentSection(status, managerComment),
                          ],

                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text('Close', style: AppStyles.text),
                                ),
                              ),
                              if (isEditable) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (justificationController.text
                                          .trim()
                                          .isEmpty) {
                                        AppHelpers.showErrorSnackbar(
                                          context,
                                          'Please provide justification',
                                        );
                                        return;
                                      }
                                      _handleSubmit(
                                        dateStr,
                                        projectName,
                                        selectedTime,
                                        justificationController.text.trim(),
                                      );
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: AppColors.textLight,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Submit Request',
                                        style: AppStyles.buttonText),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  String _getManagerComment(String status) {
    if (status == 'Pending') {
      return 'Your request is under review by the manager.';
    } else if (status == 'Rejected') {
      return 'Insufficient justification provided. Please provide more details about the reason for late check-out.';
    } else if (status == 'Approved') {
      return 'Request approved successfully. Your attendance hours have been regularized.';
    }
    return '';
  }

  Widget _buildManagerCommentSection(String status, String comment) {
    Color bgColor, borderColor, iconColor, textColor;

    if (status == 'Approved') {
      bgColor = AppColors.success.shade50;
      borderColor = AppColors.success.shade200;
      iconColor = AppColors.success.shade700;
      textColor = AppColors.success.shade900;
    } else if (status == 'Rejected') {
      bgColor = AppColors.error.shade50;
      borderColor = AppColors.error.shade200;
      iconColor = AppColors.error.shade700;
      textColor = AppColors.error.shade900;
    } else {
      bgColor = AppColors.warning.shade50;
      borderColor = AppColors.warning.shade200;
      iconColor = AppColors.warning.shade700;
      textColor = AppColors.warning.shade900;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status == 'Approved'
                    ? Icons.check_circle
                    : status == 'Rejected'
                    ? Icons.cancel
                    : Icons.info,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Manager Comment',
                style: AppStyles.heading.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: AppStyles.text.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  void _handleSubmit(String dateStr,
      String projectName,
      TimeOfDay selectedTime,
      String justification,) {
    context.read<RegularisationProvider>().submitRegularisation(
      date: dateStr,
      projectName: projectName,
      time: selectedTime,
      type: selectedTime.hour < 12 ? 'AM' : 'PM',
      notes: justification,
      description: '',
    );

    AppHelpers.showSuccessSnackbar(
        context, 'Regularization request submitted successfully');
  }

  Widget _buildAttendanceCard(String date,
      String hours,
      String shortfall,
      String status,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,) {
    final provider = context.read<RegularisationProvider>();
    final projectGroups = provider.getProjectGroups(dayRecords);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () =>
              _showRegularisationDetails(date, actualDate, dayRecords, status),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date, style: AppStyles.heading),
                          Text(
                            DateFormat('EEEE').format(actualDate),
                            style: AppStyles.text,
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: status, fontSize: 11),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatItem(
                        icon: Icons.access_time,
                        label: 'Check-in Hr',
                        value: hours,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.grey200),
                    Expanded(
                      child: StatItem(
                        icon: Icons.trending_down,
                        label: 'Shortfall Hr',
                        value: shortfall,
                        color: shortfall == '00:00'
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.grey200),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Icon(
                              status == 'Apply'
                                  ? Icons.add_circle_outline
                                  : status == 'Approved'
                                  ? Icons.check_circle
                                  : Icons.pending,
                              size: 20,
                              color: status == 'Apply'
                                  ? AppColors.warning
                                  : status == 'Approved'
                                  ? AppColors.success
                                  : AppColors.primaryBlue,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Regularize',
                              style: AppStyles.text.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (projectGroups.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(height: 1, color: AppColors.grey200),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: projectGroups.keys.take(3).map((projectName) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder, size: 14,
                                color: AppColors.primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              projectName,
                              style: AppStyles.text.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (projectGroups.length > 3) ...[
                    const SizedBox(height: 8),
                    Text(
                      '+${projectGroups.length - 3} more projects',
                      style: AppStyles.text.copyWith(
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
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
            Text(
              'No attendance records for this month',
              style: AppStyles.text,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildMonthlyStatsHeader(month),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allRecords.length,
            itemBuilder: (context, index) {
              final record = allRecords[index];
              return _buildAttendanceCard(
                record['date'],
                record['hours'],
                record['shortfall'],
                _getStatusFromRecord(record),
                record['actualDate'],
                record['records'],
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
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
                return Container(
                  color: AppColors.textLight,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 3,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    labelColor: AppColors.primaryBlue,
                    unselectedLabelColor: AppColors.grey600,
                    labelStyle: AppStyles.label,
                    unselectedLabelStyle: AppStyles.text,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    tabs: provider.availableMonths.map((month) {
                      final isCurrentMonth = month.month == DateTime
                          .now()
                          .month &&
                          month.year == DateTime
                              .now()
                              .year;
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
                          AppColors.primaryBlue),
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
                    Text(
                      'Oops!',
                      style: AppStyles.headingLarge,
                    ),
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
                            horizontal: 24, vertical: 12),
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
              children: provider.availableMonths
                  .map((month) => _buildRecordsList(month))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}