import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/regularisation_provider.dart';
import '../models/attendance_model.dart';
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
      // Single project - show direct edit form
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
      // Multiple projects - show project selection
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
              // ✅ Fixed: removed extra comma after Row
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF4A90E2), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: status, fontSize: 12),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Select Project',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Loop through projects
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.white,
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
                            color: const Color(0xFF4A90E2).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A90E2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.folder_outlined,
                                color: Color(0xFF4A90E2),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} hrs',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey.shade400,
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
                  child: const Text('Cancel'),
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
    String managerComment = '';
    if (status == 'Pending') {
      managerComment = 'Your request is under review by the manager.';
    } else if (status == 'Rejected') {
      managerComment = 'Insufficient justification provided. Please provide more details.';
    } else if (status == 'Approved') {
      managerComment = 'Request approved successfully. Hours have been regularized.';
    }

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
                  Row(
                    children: [
                      Icon(Icons.edit_calendar, color: Color(0xFF4A90E2), size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isEditable ? 'Regularisation Request' : 'Request Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      StatusBadge(status: status, fontSize: 11),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Date Card
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: dateStr,
                    color: Color(0xFF4A90E2),
                  ),
                  SizedBox(height: 12),

                  // Project Card
                  _buildInfoCard(
                    icon: Icons.folder_outlined,
                    label: 'Project',
                    value: projectName,
                    color: Color(0xFF4A90E2),
                  ),
                  SizedBox(height: 12),

                  // Hours Card
                  _buildInfoCard(
                    icon: Icons.access_time,
                    label: 'Worked Hours',
                    value: '${checkOut.timestamp.difference(checkIn.timestamp).inHours}:${(checkOut.timestamp.difference(checkIn.timestamp).inMinutes % 60).toString().padLeft(2, '0')} hrs',
                    color: Color(0xFF4A90E2),
                  ),
                  SizedBox(height: 20),

                  if (isEditable) ...[
                    // Time Picker
                    Text(
                      'Regularisation Time',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
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
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.schedule, color: Color(0xFF4A90E2), size: 20),
                            SizedBox(width: 12),
                            Text(
                              selectedTime.format(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Type Selection
                    Text(
                      'Period',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeOption(
                            'AM',
                            selectedType == 'AM',
                                () => setDialogState(() => selectedType = 'AM'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeOption(
                            'PM',
                            selectedType == 'PM',
                                () => setDialogState(() => selectedType = 'PM'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Justification
                    Text(
                      'Justification',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      enabled: isEditable,
                      decoration: InputDecoration(
                        hintText: 'Explain the reason for regularisation...',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF4A90E2), width: 2),
                        ),
                      ),
                    ),
                  ] else ...[
                    // View only mode - show submitted details
                    _buildInfoCard(
                      icon: Icons.schedule,
                      label: 'Submitted Time',
                      value: '${selectedTime.format(context)} $selectedType',
                      color: Color(0xFF4A90E2),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Justification',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        noteController.text.isEmpty ? 'No justification provided' : noteController.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  // Manager Comment Section
                  if (status != 'Apply') ...[
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: status == 'Approved'
                            ? Colors.green.shade50
                            : status == 'Rejected'
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: status == 'Approved'
                              ? Colors.green.shade200
                              : status == 'Rejected'
                              ? Colors.red.shade200
                              : Colors.orange.shade200,
                        ),
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
                                color: status == 'Approved'
                                    ? Colors.green.shade700
                                    : status == 'Rejected'
                                    ? Colors.red.shade700
                                    : Colors.orange.shade700,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Manager Comment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: status == 'Approved'
                                      ? Colors.green.shade900
                                      : status == 'Rejected'
                                      ? Colors.red.shade900
                                      : Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            managerComment,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (isEditable) ...[
                        SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (noteController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please provide justification'),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text('Request submitted successfully'),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A90E2),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Submit Request',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4A90E2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Color(0xFF4A90E2) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black54,
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
    final canInteract = true; // All statuses are now clickable

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: Colors.black,
        child: InkWell(
          onTap: canInteract
              ? () => _showRegularisationDetails(date, actualDate, dayRecords, status)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Color(0xFF4A90E2),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
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
                    StatusBadge(status: status, fontSize: 11),
                  ],
                ),
                SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.access_time,
                        label: 'Hours',
                        value: hours,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.trending_down,
                        label: 'Shortfall',
                        value: shortfall,
                        color: shortfall == '00:00' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                if (projectGroups.length > 0) ...[
                  SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey),
                  SizedBox(height: 16),

                  // Projects Section
                  Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${projectGroups.length} Project${projectGroups.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Spacer(),
                      if (canInteract)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF4A90E2),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: projectGroups.keys.take(3).map((projectName) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF4A90E2).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0xFF4A90E2).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          projectName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A90E2),
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList(DateTime month) {
    final provider = context.read<RegularisationProvider>();
    final categorized = provider.getCategorizedRecords(month);

    final allRecords = <Map<String, dynamic>>[];
    for (var records in categorized.values) {
      allRecords.addAll(records);
    }

    // Sort by date descending
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
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No Records Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No attendance records for this month',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'Regularisation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Consumer<RegularisationProvider>(
              builder: (context, provider, _) {
                return Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Color(0xFF4A90E2),
                        width: 3,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    labelColor: Color(0xFF4A90E2),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                    labelPadding: EdgeInsets.symmetric(horizontal: 20),
                    tabs: provider.availableMonths.map((month) {
                      final isCurrentMonth = month.month == DateTime.now().month &&
                          month.year == DateTime.now().year;
                      return Tab(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 8),
                            Text(DateFormat('MMM yyyy').format(month)),
                            if (isCurrentMonth) ...[
                              SizedBox(height: 2),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Color(0xFF4A90E2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            SizedBox(height: 8),
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
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading attendance data...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
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
                      color: Colors.red.shade300,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: provider.loadAttendance,
                      icon: Icon(Icons.refresh),
                      label: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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