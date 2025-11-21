
import 'package:AttendanceApp/manager/models/attendance_model.dart';
import 'package:flutter/material.dart';

import '../../view_models/employeeviewmodels/employee_details_view_model.dart';

class AttendanceHistoryList extends StatefulWidget {
  final EmployeeDetailsViewModel viewModel;

  const AttendanceHistoryList({super.key, required this.viewModel});

  @override
  State<AttendanceHistoryList> createState() => _AttendanceHistoryListState();
}

class _AttendanceHistoryListState extends State<AttendanceHistoryList> {
  final List<String> _filters = ['all', 'present', 'absent', 'late'];
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final filteredRecords = widget.viewModel.filteredAttendance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with improved responsive layout
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;

            return isCompact
                ? _buildCompactHeader(isDark)
                : _buildExpandedHeader(isDark);
          },
        ),
        const SizedBox(height: 16),

        if (filteredRecords.isEmpty)
          _buildEmptyState(isDark)
        else
          _buildAttendanceList(filteredRecords, isDark),
      ],
    );
  }

  Widget _buildCompactHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        _buildFilterChips(isDark),
      ],
    );
  }

  Widget _buildExpandedHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        Flexible(child: _buildFilterChips(isDark)),
      ],
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: _filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return FilterChip(
          selected: isSelected,
          label: Text(
            _getFilterDisplayName(filter),
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade600),
              fontSize: 12,
            ),
          ),
          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          selectedColor: isDark ? Colors.blue.shade600 : Colors.blue.shade500,
          onSelected: (selected) {
            setState(() {
              _selectedFilter = selected ? filter : 'all';
            });
            widget.viewModel.changeFilter(_selectedFilter);
          },
        );
      }).toList(),
    );
  }

  Widget _buildAttendanceList(List<AttendanceRecord> records, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header Row - Always show full header
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildFullTableHeader(isDark),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),

          // Attendance Records List - Always show full rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildFullAttendanceRow(record, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFullTableHeader(bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Date',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Check In',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Check Out',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Hours',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullAttendanceRow(AttendanceRecord record, bool isDark) {
    final workingHours = record.calculatedWorkingHours;
    final hasWorkingHours = workingHours.inMinutes > 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Date Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record.date),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                Text(
                  _getWeekday(record.date.weekday),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Expanded(child: _buildStatusBadge(record)),

          // Check In Time
          Expanded(
            child: Text(
              _formatTime(record.checkIn),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Check Out Time
          Expanded(
            child: Text(
              record.checkOut != null ? _formatTime(record.checkOut!) : '--:--',
              style: TextStyle(
                fontSize: 12,
                color: record.checkOut != null
                    ? (isDark ? Colors.white : Colors.grey.shade800)
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                fontWeight: record.checkOut != null ? FontWeight.w600 : null,
              ),
            ),
          ),

          // Working Hours
          Expanded(
            child: Text(
              hasWorkingHours ? _formatWorkingHours(workingHours) : '--:--',
              style: TextStyle(
                fontSize: 12,
                color: hasWorkingHours
                    ? (isDark ? Colors.white : Colors.grey.shade800)
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                fontWeight: hasWorkingHours ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AttendanceRecord record) {
    final color = record.statusColor;
    final text = record.statusDisplayText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 32,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No attendance records found',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            Text(
              'for selected filter',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formatting helper methods
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatWorkingHours(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String _getFilterDisplayName(String filter) {
    const filterNames = {
      'all': 'All',
      'present': 'Present',
      'absent': 'Absent',
      'late': 'Late',
    };
    return filterNames[filter] ?? 'All';
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/attendance_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class AttendanceHistoryList extends StatefulWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const AttendanceHistoryList({super.key, required this.viewModel});

//   @override
//   State<AttendanceHistoryList> createState() => _AttendanceHistoryListState();
// }

// class _AttendanceHistoryListState extends State<AttendanceHistoryList> {
//   final List<String> _filters = ['all', 'present', 'absent', 'late'];
//   String _selectedFilter = 'all';

//   @override
//   Widget build(BuildContext context) {
//     final filteredRecords = widget.viewModel.filteredAttendance;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header with improved responsive layout
//         LayoutBuilder(
//           builder: (context, constraints) {
//             final isCompact = constraints.maxWidth < 600;

//             return isCompact ? _buildCompactHeader() : _buildExpandedHeader();
//           },
//         ),
//         const SizedBox(height: 16),

//         if (filteredRecords.isEmpty)
//           _buildEmptyState()
//         else
//           _buildAttendanceList(filteredRecords),
//       ],
//     );
//   }

//   Widget _buildCompactHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Attendance History',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildFilterChips(),
//       ],
//     );
//   }

//   Widget _buildExpandedHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Attendance History',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         Flexible(child: _buildFilterChips()),
//       ],
//     );
//   }

//   Widget _buildFilterChips() {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       alignment: WrapAlignment.end,
//       children: _filters.map((filter) {
//         final isSelected = _selectedFilter == filter;
//         return FilterChip(
//           selected: isSelected,
//           label: Text(
//             _getFilterDisplayName(filter),
//             style: TextStyle(
//               color: isSelected ? AppColors.white : AppColors.textSecondary,
//               fontSize: 12,
//             ),
//           ),
//           backgroundColor: AppColors.grey100,
//           selectedColor: AppColors.primary,
//           onSelected: (selected) {
//             setState(() {
//               _selectedFilter = selected ? filter : 'all';
//             });
//             widget.viewModel.changeFilter(_selectedFilter);
//           },
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildAttendanceList(List<AttendanceRecord> records) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         children: [
//           // Header Row - Always show full header
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: _buildFullTableHeader(),
//           ),
//           const Divider(height: 1),

//           // Attendance Records List - Always show full rows
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: records.length,
//             separatorBuilder: (context, index) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               final record = records[index];
//               return _buildFullAttendanceRow(record);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFullTableHeader() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Text(
//             'Date',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Status',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Check In',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Check Out',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Hours',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFullAttendanceRow(AttendanceRecord record) {
//     final workingHours = record.calculatedWorkingHours;
//     final hasWorkingHours = workingHours.inMinutes > 0;

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           // Date Column
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _formatDate(record.date),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 Text(
//                   _getWeekday(record.date.weekday),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Status Badge
//           Expanded(child: _buildStatusBadge(record)),

//           // Check In Time
//           Expanded(
//             child: Text(
//               _formatTime(record.checkIn),
//               style: TextStyle(
//                 fontSize: 12,
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),

//           // Check Out Time
//           Expanded(
//             child: Text(
//               record.checkOut != null ? _formatTime(record.checkOut!) : '--:--',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: record.checkOut != null
//                     ? AppColors.textPrimary
//                     : AppColors.textSecondary,
//                 fontWeight: record.checkOut != null ? FontWeight.w600 : null,
//               ),
//             ),
//           ),

//           // Working Hours
//           Expanded(
//             child: Text(
//               hasWorkingHours ? _formatWorkingHours(workingHours) : '--:--',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: hasWorkingHours
//                     ? AppColors.textPrimary
//                     : AppColors.textSecondary,
//                 fontWeight: hasWorkingHours ? FontWeight.w600 : null,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(AttendanceRecord record) {
//     final color = record.statusColor;
//     final text = record.statusDisplayText;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         height: 120,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.calendar_today_rounded,
//               size: 32,
//               color: AppColors.grey400,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No attendance records found',
//               style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
//             ),
//             Text(
//               'for selected filter',
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Formatting helper methods
//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   String _formatTime(DateTime time) {
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }

//   String _formatWorkingHours(Duration duration) {
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return '${hours}h ${minutes}m';
//   }

//   String _getFilterDisplayName(String filter) {
//     const filterNames = {
//       'all': 'All',
//       'present': 'Present',
//       'absent': 'Absent',
//       'late': 'Late',
//     };
//     return filterNames[filter] ?? 'All';
//   }

//   String _getWeekday(int weekday) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[weekday - 1];
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/attendance_model.dart';
// import 'package:attendanceapp/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'package:flutter/material.dart';

// class AttendanceHistoryList extends StatefulWidget {
//   final EmployeeDetailsViewModel viewModel;

//   const AttendanceHistoryList({super.key, required this.viewModel});

//   @override
//   State<AttendanceHistoryList> createState() => _AttendanceHistoryListState();
// }

// class _AttendanceHistoryListState extends State<AttendanceHistoryList> {
//   final List<String> _filters = ['all', 'present', 'absent', 'late'];
//   String _selectedFilter = 'all';

//   @override
//   Widget build(BuildContext context) {
//     final filteredRecords = widget.viewModel.filteredAttendance;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header with improved responsive layout
//         LayoutBuilder(
//           builder: (context, constraints) {
//             final isCompact = constraints.maxWidth < 600;

//             return isCompact ? _buildCompactHeader() : _buildExpandedHeader();
//           },
//         ),
//         const SizedBox(height: 16),

//         if (filteredRecords.isEmpty)
//           _buildEmptyState()
//         else
//           _buildAttendanceList(filteredRecords),
//       ],
//     );
//   }

//   Widget _buildCompactHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Attendance History',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildFilterChips(),
//       ],
//     );
//   }

//   Widget _buildExpandedHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Attendance History',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         Flexible(child: _buildFilterChips()),
//       ],
//     );
//   }

//   Widget _buildFilterChips() {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       alignment: WrapAlignment.end,
//       children: _filters.map((filter) {
//         final isSelected = _selectedFilter == filter;
//         return FilterChip(
//           selected: isSelected,
//           label: Text(
//             _getFilterDisplayName(filter),
//             style: TextStyle(
//               color: isSelected ? AppColors.white : AppColors.textSecondary,
//               fontSize: 12,
//             ),
//           ),
//           backgroundColor: AppColors.grey100,
//           selectedColor: AppColors.primary,
//           onSelected: (selected) {
//             setState(() {
//               _selectedFilter = selected ? filter : 'all';
//             });
//             widget.viewModel.changeFilter(_selectedFilter);
//           },
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildAttendanceList(List<AttendanceRecord> records) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         children: [
//           // Header Row
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 final isCompact = constraints.maxWidth < 500;

//                 return isCompact
//                     ? _buildCompactTableHeader()
//                     : _buildFullTableHeader();
//               },
//             ),
//           ),
//           const Divider(height: 1),

//           // Attendance Records List
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: records.length,
//             separatorBuilder: (context, index) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               final record = records[index];
//               return _buildAttendanceRow(record);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFullTableHeader() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Text(
//             'Date',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Status',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Check In',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Check Out',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Hours',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCompactTableHeader() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Text(
//             'Date',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             'Status',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 2,
//           child: Text(
//             'Time/Hours',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAttendanceRow(AttendanceRecord record) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isCompact = constraints.maxWidth < 500;

//         return isCompact
//             ? _buildCompactAttendanceRow(record)
//             : _buildFullAttendanceRow(record);
//       },
//     );
//   }

//   Widget _buildFullAttendanceRow(AttendanceRecord record) {
//     final workingHours = record.calculatedWorkingHours;
//     final hasWorkingHours = workingHours.inMinutes > 0;

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           // Date Column
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _formatDate(record.date),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 Text(
//                   _getWeekday(record.date.weekday),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Status Badge
//           Expanded(child: _buildStatusBadge(record)),

//           // Check In Time
//           Expanded(
//             child: Text(
//               _formatTime(record.checkIn),
//               style: TextStyle(
//                 fontSize: 12,
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),

//           // Check Out Time
//           Expanded(
//             child: Text(
//               record.checkOut != null ? _formatTime(record.checkOut!) : '--:--',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: record.checkOut != null
//                     ? AppColors.textPrimary
//                     : AppColors.textSecondary,
//                 fontWeight: record.checkOut != null ? FontWeight.w600 : null,
//               ),
//             ),
//           ),

//           // Working Hours
//           Expanded(
//             child: Text(
//               hasWorkingHours ? _formatWorkingHours(workingHours) : '--:--',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: hasWorkingHours
//                     ? AppColors.textPrimary
//                     : AppColors.textSecondary,
//                 fontWeight: hasWorkingHours ? FontWeight.w600 : null,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactAttendanceRow(AttendanceRecord record) {
//     final workingHours = record.calculatedWorkingHours;
//     final hasWorkingHours = workingHours.inMinutes > 0;

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           // Date Column
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _formatDate(record.date),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 Text(
//                   _getWeekday(record.date.weekday),
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Status Badge
//           Expanded(child: _buildStatusBadge(record)),

//           // Combined Time and Hours Column
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       _formatTime(record.checkIn),
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textPrimary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       ' - ',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     Text(
//                       record.checkOut != null
//                           ? _formatTime(record.checkOut!)
//                           : '--:--',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: record.checkOut != null
//                             ? AppColors.textPrimary
//                             : AppColors.textSecondary,
//                         fontWeight: record.checkOut != null
//                             ? FontWeight.w600
//                             : null,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   hasWorkingHours ? _formatWorkingHours(workingHours) : '--:--',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: hasWorkingHours
//                         ? AppColors.textPrimary
//                         : AppColors.textSecondary,
//                     fontWeight: hasWorkingHours ? FontWeight.w600 : null,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(AttendanceRecord record) {
//     final color = record.statusColor;
//     final text = record.statusDisplayText;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           color: color,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         height: 120,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.calendar_today_rounded,
//               size: 32,
//               color: AppColors.grey400,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'No attendance records found',
//               style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
//             ),
//             Text(
//               'for selected filter',
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Formatting helper methods
//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }

//   String _formatTime(DateTime time) {
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }

//   String _formatWorkingHours(Duration duration) {
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return '${hours}h ${minutes}m';
//   }

//   String _getFilterDisplayName(String filter) {
//     const filterNames = {
//       'all': 'All',
//       'present': 'Present',
//       'absent': 'Absent',
//       'late': 'Late',
//     };
//     return filterNames[filter] ?? 'All';
//   }

//   String _getWeekday(int weekday) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[weekday - 1];
//   }
// }
