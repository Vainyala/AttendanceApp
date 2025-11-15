// screens/attendance_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/analytics_data.dart';
import '../providers/analytics_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/month_selection_drawer.dart';
import '../widgets/quarter_selection_drawer.dart';
import '../widgets/week_selection_drawer.dart';
import '../widgets/attendance_views/group_view_widget.dart';
import '../widgets/attendance_views/person_view_widget.dart';
import '../widgets/attendance_views/project_view_widget.dart';

class AttendanceAnalyticsScreen extends StatefulWidget {
  final String? preSelectedProjectId;

  const AttendanceAnalyticsScreen({super.key, this.preSelectedProjectId});

  @override
  State<AttendanceAnalyticsScreen> createState() => _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState extends State<AttendanceAnalyticsScreen> {
  late AnalyticsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AnalyticsProvider();
    if (widget.preSelectedProjectId != null) {
      _provider.setProjectId(widget.preSelectedProjectId);
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.primaryBlue,
            appBar: AppBar(
              title: Text(
                'Attendance Analytics',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: Column(
              children: [
                _ModeSelector(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
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
                          _ContentView(),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
          color: selected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primaryBlue : Colors.white,
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
              onPrimary: Colors.white,
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
    final summary = provider.teamSummary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopMiniBox("Team", "${summary['team']}", Colors.blue, "100%"),
              _buildTopMiniBox("Present", "${summary['present']}", Colors.green, "70%"),
              _buildTopMiniBox("Leave", "${summary['leave']}", Colors.orange, "10%"),
              _buildTopMiniBox("Absent", "${summary['absent']}", Colors.red, "20%"),
              _buildTopMiniBox("OnTime", "${summary['onTime']}", Colors.teal, "60%"),
              _buildTopMiniBox("Late", "${summary['late']}", Colors.purple, "10%"),
            ],
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
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
                    Icons.group,
                    provider.viewMode == ViewMode.group,
                        () => provider.setViewMode(ViewMode.group),
                  ),
                  SizedBox(width: 10),
                  _buildIconButton(
                    context,
                    Icons.person,
                    provider.viewMode == ViewMode.person,
                        () => provider.setViewMode(ViewMode.person),
                  ),
                  SizedBox(width: 10),
                  _buildIconButton(
                    context,
                    Icons.add_circle_outline,
                    provider.viewMode == ViewMode.project,
                        () => provider.setViewMode(ViewMode.project),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMiniBox(String label, String value, Color color, String percent) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 2),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2),
        Text(
          percent,
          style: TextStyle(
            fontSize: 10,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
      BuildContext context,
      IconData icon,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.blue : Colors.black.withOpacity(0.25),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
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
              backgroundColor: Colors.white,
              shape: CircleBorder(),
            ),
          ),
          Expanded(
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
                  color: Colors.white,
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
                          color: Colors.grey.shade800,
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
              backgroundColor: Colors.white,
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
              onPrimary: Colors.white,
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

    switch (provider.viewMode) {
      case ViewMode.group:
        return GroupViewWidget();
      case ViewMode.person:
        return PersonViewWidget();
      case ViewMode.project:
        return ProjectViewWidget();
      default:
        return GroupViewWidget();
    }
  }
}