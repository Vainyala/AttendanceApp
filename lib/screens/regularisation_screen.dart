import 'package:AttendenceApp/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/regularisation_provider.dart';
import '../models/attendance_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_helpers.dart';
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Show detailed regularisation view
  void _showRegularisationDetails(
      String dateStr,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,
      String status,
      ) {
    final provider = context.read<RegularisationProvider>();
    final projectGroups = provider.getProjectGroups(dayRecords);
    final isEditable = status == 'Apply' || status == 'Rejected' || status == 'Pending';

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
    } else {
      _showProjectSelectionDialog(
        dateStr,
        actualDate,
        projectGroups,
        status,
        isEditable,
      );
    }
  }

  // Show project selection dialog for multiple projects
  void _showProjectSelectionDialog(
      String dateStr,
      DateTime actualDate,
      Map<String, List<AttendanceModel>> projectGroups,
      String status,
      bool isEditable,
      ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(dateStr, style: AppStyles.label),
                  const Spacer(),
                  StatusBadge(status: status, fontSize: 12),
                ],
              ),
              const SizedBox(height: 20),
              Text(AppText.selectpro, style: AppStyles.heading),
              const SizedBox(height: 12),

              // Project list
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

                final duration = checkOut.timestamp.difference(checkIn.timestamp);
                final durationText = AppHelpers.formatDuration(duration);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
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
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.key, style: AppStyles.heading),
                                  const SizedBox(height: 4),
                                  Text('$durationText hrs', style: AppStyles.text),
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

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppText.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show project detail dialog with form
  void _showProjectDetailDialog(
      String dateStr,
      DateTime actualDate,
      String projectName,
      List<AttendanceModel> projectRecords,
      String status,
      bool isEditable,
      ) {
    final checkIn = projectRecords.firstWhere(
          (r) => r.type == AttendanceType.checkIn,
      orElse: () => projectRecords.first,
    );
    final checkOut = projectRecords.lastWhere(
          (r) => r.type == AttendanceType.checkOut,
      orElse: () => projectRecords.last,
    );

    TimeOfDay selectedTime = TimeOfDay.fromDateTime(checkOut.timestamp);
    String selectedType = checkOut.timestamp.hour < 12 ? 'AM' : 'PM';
    final noteController = TextEditingController(
      text: isEditable ? '' : 'Previous justification text here...',
    );

    // Mock manager comment based on status
    String managerComment = _getManagerComment(status);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildDialogHeader(status, isEditable),
                  const SizedBox(height: 20),

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
                    icon: Icons.access_time,
                    label: 'Worked Hours',
                    value: AppHelpers.formatDuration(
                      checkOut.timestamp.difference(checkIn.timestamp),
                    ) + ' hrs',
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 20),

                  if (isEditable) ...[
                    _buildEditableForm(
                      context,
                      setDialogState,
                      selectedTime,
                      selectedType,
                      noteController,
                          (time) => selectedTime = time,
                          (type) => selectedType = type,
                    ),
                  ] else ...[
                    _buildViewOnlyMode(selectedTime, selectedType, noteController),
                  ],

                  // Manager Comment Section
                  if (status != 'Apply') ...[
                    const SizedBox(height: 20),
                    _buildManagerCommentSection(status, managerComment),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(
                    context,
                    isEditable,
                    dateStr,
                    projectName,
                    selectedTime,
                    selectedType,
                    noteController,
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
      return 'Insufficient justification provided. Please provide more details.';
    } else if (status == 'Approved') {
      return 'Request approved successfully. Hours have been regularized.';
    }
    return '';
  }

  Widget _buildDialogHeader(String status, bool isEditable) {
    return Row(
      children: [
        const Icon(Icons.edit_calendar, color: AppColors.primaryBlue, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isEditable ? AppText.regu_request : AppText.requ_details,
            style: AppStyles.headingLarge,
          ),
        ),
        StatusBadge(status: status, fontSize: 11),
      ],
    );
  }

  Widget _buildEditableForm(
      BuildContext context,
      StateSetter setDialogState,
      TimeOfDay selectedTime,
      String selectedType,
      TextEditingController noteController,
      Function(TimeOfDay) onTimeChanged,
      Function(String) onTypeChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Picker
        Text(AppText.regu_time, style: AppStyles.heading),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (time != null) {
              setDialogState(() => onTimeChanged(time));
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
                const Icon(Icons.schedule, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Text(selectedTime.format(context), style: AppStyles.heading),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Period Selection
        Text(AppText.period, style: AppStyles.heading),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                'AM',
                selectedType == 'AM',
                    () => setDialogState(() => onTypeChanged('AM')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                'PM',
                selectedType == 'PM',
                    () => setDialogState(() => onTypeChanged('PM')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Justification
        Text(AppText.justification, style: AppStyles.heading),
        const SizedBox(height: 8),
        TextField(
          controller: noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Explain the reason for regularisation...',
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewOnlyMode(
      TimeOfDay selectedTime,
      String selectedType,
      TextEditingController noteController,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoCard(
          icon: Icons.schedule,
          label: 'Submitted Time',
          value: '${selectedTime.format(context)} $selectedType',
          color: AppColors.primaryBlue,
        ),
        const SizedBox(height: 12),
        Text(AppText.justification, style: AppStyles.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Text(
            noteController.text.isEmpty
                ? AppText.no_justification
                : noteController.text,
            style: AppStyles.text.copyWith(height: 1.5),
          ),
        ),
      ],
    );
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
                AppText.managercommert,
                style: AppStyles.label.copyWith(color: textColor),
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

  Widget _buildActionButtons(
      BuildContext context,
      bool isEditable,
      String dateStr,
      String projectName,
      TimeOfDay selectedTime,
      String selectedType,
      TextEditingController noteController,
      ) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppText.close, style: AppStyles.text),
          ),
        ),
        if (isEditable) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _handleSubmit(
                context,
                dateStr,
                projectName,
                selectedTime,
                selectedType,
                noteController,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppText.submit_rqu, style: AppStyles.buttonText),
            ),
          ),
        ],
      ],
    );
  }

  void _handleSubmit(
      BuildContext context,
      String dateStr,
      String projectName,
      TimeOfDay selectedTime,
      String selectedType,
      TextEditingController noteController,
      ) {
    if (noteController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar(context, 'Please provide justification');
      return;
    }

    context.read<RegularisationProvider>().submitRegularisation(
      date: dateStr,
      projectName: projectName,
      time: selectedTime,
      type: selectedType,
      notes: noteController.text.trim(),
      description: '',
    );

    Navigator.pop(context);
    AppHelpers.showSuccessSnackbar(context, 'Request submitted successfully');
  }

  Widget _buildTypeOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppStyles.buttonText.copyWith(
              color: isSelected ? AppColors.textLight : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(
      String date,
      String hours,
      String shortfall,
      String status,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,
      ) {
    final provider = context.read<RegularisationProvider>();
    final projectGroups = provider.getProjectGroups(dayRecords);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: Colors.black,
        child: InkWell(
          onTap: () => _showRegularisationDetails(date, actualDate, dayRecords, status),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
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

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: StatItem(
                        icon: Icons.access_time,
                        label: 'Hours',
                        value: hours,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.grey200,
                    ),
                    Expanded(
                      child: StatItem(
                        icon: Icons.trending_down,
                        label: 'Shortfall',
                        value: shortfall,
                        color: shortfall == '00:00' ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),

                if (projectGroups.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Divider(height: 1, color: AppColors.grey200),
                  const SizedBox(height: 16),

                  // Projects Section
                  Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${projectGroups.length} Project${projectGroups.length > 1 ? 's' : ''}',
                        style: AppStyles.text.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: projectGroups.keys.take(3).map((projectName) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          projectName,
                          style: AppStyles.text.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
              AppText.no_reco_foun,
              style: AppStyles.headingLarge.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 8),
            Text(
              AppText.no_reco,
              style: AppStyles.text,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppText.regula,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textLight,
          elevation: 0,
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
        body: Consumer<RegularisationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(AppText.loading_data, style: AppStyles.text),
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
                      AppText.oops,
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
                      label: const Text(AppText.retry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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