import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/regularisation_provider.dart';
import '../models/attendance_model.dart';
import '../utils/status_utils.dart';
import '../widgets/custom_bars.dart';
import '../widgets/status_badge.dart';

class RegularisationScreen extends StatefulWidget {
  const RegularisationScreen({super.key});

  @override
  State<RegularisationScreen> createState() => _RegularisationScreenState();
}

class _RegularisationScreenState extends State<RegularisationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
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

  void _showRegularisationDialog(
      String dateStr,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,
      ) {
    final provider = context.read<RegularisationProvider>();
    final clockHours = provider.calculateClockHours(dayRecords);
    final shortfall = provider.calculateShortfall(clockHours);
    final status = provider.getStatusForDay(actualDate, shortfall);

    if (!provider.canEditRecord(actualDate, status)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot apply for regularisation for today or future dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedType = 'PM';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Apply for Regularisation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: $dateStr',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _buildProjectSummary(dayRecords),
                const SizedBox(height: 16),
                const Text(
                  'Select Time:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                  ),
                  child: Text(selectedTime.format(context)),
                ),
                const SizedBox(height: 16),
                const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('AM'),
                        value: 'AM',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('PM'),
                        value: 'PM',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason for regularisation...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a reason for regularisation'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                provider.submitRegularisation(
                  date: dateStr,
                  time: selectedTime,
                  type: selectedType,
                  notes: noteController.text.trim(), projectName: '', description: '',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Regularisation request submitted for $dateStr at ${selectedTime.format(context)} $selectedType',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSummary(List<AttendanceModel> dayRecords) {
    final provider = context.read<RegularisationProvider>();
    final projectGroups = provider.getProjectGroups(dayRecords);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Hours:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
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
            final hours = duration.inHours;
            final minutes = duration.inMinutes % 60;
            final timeStr =
                '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 13)),
                  Text(
                    '$timeStr hrs',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Consumer<RegularisationProvider>(
                builder: (context, provider, _) {
                  final clockHours = provider.calculateClockHours(dayRecords);
                  return Text(
                    '$clockHours hrs',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSwiper(List<AttendanceModel> dayRecords) {
    final provider = context.read<RegularisationProvider>();
    final projectGroups = provider.getProjectGroups(dayRecords);

    if (projectGroups.isEmpty) return const SizedBox.shrink();

    final projectEntries = projectGroups.entries.toList();

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Projects (Swipe to view)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${projectEntries.length} projects',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: PageView.builder(
              itemCount: projectEntries.length,
              itemBuilder: (context, index) {
                final entry = projectEntries[index];
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
                final hours = duration.inHours;
                final minutes = duration.inMinutes % 60;
                final timeStr =
                    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}/${projectEntries.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$timeStr hrs',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
      String date,
      String hours,
      String shortfall,
      String status,
      DateTime actualDate,
      List<AttendanceModel> dayRecords,
      ) {
    final provider = context.read<RegularisationProvider>();
    final canEdit = provider.canEditRecord(actualDate, status);

    return InkWell(
      onTap: canEdit
          ? () => _showRegularisationDialog(date, actualDate, dayRecords)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: canEdit ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canEdit ? Colors.blue.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE').format(actualDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hours,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            ' hrs',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        shortfall,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: shortfall == '00:00' ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        'shortfall',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: StatusBadge(
                    status: status,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  )
                ),
              ],
            ),
            _buildProjectSwiper(dayRecords),
            if (canEdit)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tap to apply for regularisation',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCategory(String status, List<Map> items) {
    return StatusUtils.getStatusIconWidget(status);
  }

  Widget _buildCategorizedRecords(DateTime month) {
    final provider = context.read<RegularisationProvider>();
    final categorized = provider.getCategorizedRecords(month);

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: categorized.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => _buildStatusCategory(entry.key, entry.value))
          .toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Regularisation',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Consumer<RegularisationProvider>(
              builder: (context, provider, _) {
                return Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Color(0xFF4A90E2),
                        width: 3,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    labelColor: const Color(0xFF4A90E2),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    tabs: provider.availableMonths
                        .map((month) {
                      final isCurrentMonth =
                          month.month == DateTime.now().month &&
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
                                  color: Color(0xFF4A90E2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    })
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),
        body: Consumer<RegularisationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading attendance data...'),
                  ],
                ),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.loadAttendance,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: provider.availableMonths
                  .map((month) => _buildCategorizedRecords(month))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}