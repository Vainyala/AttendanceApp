// screens/attendance_analytics_screen.dart
import 'package:AttendanceApp/employee/providers/analytics_provider.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../models/analytics_data.dart';
import '../widgets/month_selection_drawer.dart';
import '../widgets/quarter_selection_drawer.dart';
import '../widgets/week_selection_drawer.dart';
import '../widgets/attendance_views/group_view_widget.dart';
import '../widgets/attendance_views/project_view_widget.dart';

class AttendanceAnalyticsScreen extends StatefulWidget {
  final String? preSelectedProjectId;

  const AttendanceAnalyticsScreen({super.key, this.preSelectedProjectId});

  @override
  State<AttendanceAnalyticsScreen> createState() => _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState extends State<AttendanceAnalyticsScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('📱 Building AttendanceAnalyticsScreen');
    final provider = context.watch<AnalyticsProvider>();
    print('📊 Current mode: ${provider.mode}');
    print('👁️ Current view: ${provider.viewMode}');
    print('📅 Current data: ${provider.getCurrentModeData()}');

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: Text(
          'Attendance Analytics',
          style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
      body: Column(
        children: [
          _ModeSelector(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textHint.shade50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    _DateSelector(),
                    SizedBox(height: 10),
                    _TopSummaryBar(),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: _ContentView(),
                    ),
                    SizedBox(height: 40),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTopTab(context, "Daily", AnalyticsMode.daily),
          _buildTopTab(context, "Weekly", AnalyticsMode.weekly),
          _buildTopTab(context, "Monthly", AnalyticsMode.monthly),
          _buildTopTab(context, "Quarterly", AnalyticsMode.quarterly),
        ],
      ),
    );
  }

  Widget _buildTopTab(BuildContext context, String label, AnalyticsMode mode) {
    final provider = context.watch<AnalyticsProvider>();
    final selected = provider.mode == mode;

    return GestureDetector(
      onTap: () {
        provider.setMode(mode);

        if (mode == AnalyticsMode.daily) _selectDate(context, provider);
        if (mode == AnalyticsMode.weekly) _showWeekDrawer(context, provider);
        if (mode == AnalyticsMode.monthly) _showMonthDrawer(context, provider);
        if (mode == AnalyticsMode.quarterly) _showQuarterDrawer(context, provider);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.textLight : AppColors.textLight.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.textLight.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primaryBlue : AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, AnalyticsProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
    }
  }

  void _showWeekDrawer(BuildContext context, AnalyticsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => WeekSelectionDrawer(
        selectedIndex: provider.selectedWeekIndex,
        onWeekSelected: (index) {
          provider.setWeekIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMonthDrawer(BuildContext context, AnalyticsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => MonthSelectionDrawer(
        selectedIndex: provider.selectedMonthIndex,
        onMonthSelected: (index) {
          provider.setMonthIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showQuarterDrawer(BuildContext context, AnalyticsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => QuarterSelectionDrawer(
        selectedIndex: provider.selectedQuarterIndex,
        onQuarterSelected: (index) {
          provider.setQuarterIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _TopSummaryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    return Container(
      child: Column(
        children: [
          // Icon buttons row
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.textLight.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(
                    context,
                    Icons.all_inbox,
                    provider.viewMode == ViewMode.all,
                        () {
                      provider.clearProjectSelection();
                      provider.setViewMode(ViewMode.all);
                    },
                  ),
                  // Only show project icon if no project is selected
                  SizedBox(width: 15),
                  _buildIconButton(
                    context,
                    Icons.drive_file_move_sharp,
                    provider.viewMode == ViewMode.project,
                    provider.hasProjectSelected
                        ? null   // disable tap
                        : () => provider.setViewMode(ViewMode.project),
                  ),
                ],
              ),
            ),
          ),
          // Show selected project name
          if (provider.hasProjectSelected) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    provider.selectedProjectName ?? 'Project',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton(
      BuildContext context,
      IconData icon,
      bool isSelected,
      VoidCallback? onTap,
      ) {
    final bool isDisabled = onTap == null;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,   // look disabled
        child: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.blue : Colors.black.withOpacity(0.25),
          ),
          child: Icon(
            icon,
            size: 21,
            color: AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, size: 28),
            onPressed: () {
              if (provider.mode == AnalyticsMode.daily) {
                provider.changeDate(-1);
              } else if (provider.mode == AnalyticsMode.weekly) {
                provider.incrementWeekIndex();
              } else if (provider.mode == AnalyticsMode.monthly) {
                provider.incrementMonthIndex();
              } else if (provider.mode == AnalyticsMode.quarterly) {
                provider.incrementQuarterIndex();
              }
            },
            color: AppColors.primaryBlue,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.textLight,
              shape: CircleBorder(),
            ),
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                if (provider.mode == AnalyticsMode.daily) {
                  _selectDate(context, provider);
                } else if (provider.mode == AnalyticsMode.weekly) {
                  _showWeekDrawer(context, provider);
                } else if (provider.mode == AnalyticsMode.monthly) {
                  _showMonthDrawer(context, provider);
                } else if (provider.mode == AnalyticsMode.quarterly) {
                  _showQuarterDrawer(context, provider);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        provider.getDateLabel(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint.shade800,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, size: 28),
            onPressed: () {
              if (provider.mode == AnalyticsMode.daily) {
                provider.changeDate(1);
              } else if (provider.mode == AnalyticsMode.weekly) {
                provider.decrementWeekIndex();
              } else if (provider.mode == AnalyticsMode.monthly) {
                provider.decrementMonthIndex();
              } else if (provider.mode == AnalyticsMode.quarterly) {
                provider.decrementQuarterIndex();
              }
            },
            color: AppColors.primaryBlue,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.textLight,
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, AnalyticsProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.textLight,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
    }
  }

  void _showWeekDrawer(BuildContext context, AnalyticsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => WeekSelectionDrawer(
        selectedIndex: provider.selectedWeekIndex,
        onWeekSelected: (index) {
          provider.setWeekIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMonthDrawer(BuildContext context, AnalyticsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => MonthSelectionDrawer(
        selectedIndex: provider.selectedMonthIndex,
        onMonthSelected: (index) {
          provider.setMonthIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showQuarterDrawer(BuildContext context, AnalyticsProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => QuarterSelectionDrawer(
        selectedIndex: provider.selectedQuarterIndex,
        onQuarterSelected: (index) {
          provider.setQuarterIndex(index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ContentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    // FIXED: Remove SizedBox wrapper, just return the widget directly
    switch (provider.viewMode) {
      case ViewMode.all:
        return GroupViewWidget();
      case ViewMode.project:
        return ProjectViewWidget();
      default:
        return GroupViewWidget();
    }
  }
}