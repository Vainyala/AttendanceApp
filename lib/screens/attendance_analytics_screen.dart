import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics_data.dart';
import '../models/attendance_model.dart';
import '../providers/analytics_provider.dart' hide AnalyticsMode;
import '../providers/dashboard_provider.dart';
import '../services/analytics_service.dart';
import '../utils/app_colors.dart';
import '../widgets/month_selection_drawer.dart';
import '../widgets/quarter_selection_drawer.dart';
import '../widgets/week_selection_drawer.dart';
import 'attendance_detailed_screen.dart';
import 'attendance_detailed_screen.dart'; // Your existing detailed screen
class AttendanceAnalyticsScreen extends StatefulWidget {
  final String? preSelectedProjectId;

  const AttendanceAnalyticsScreen({super.key, this.preSelectedProjectId});

  @override
  State<AttendanceAnalyticsScreen> createState() => _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState extends State<AttendanceAnalyticsScreen> {
  AnalyticsMode _mode = AnalyticsMode.daily;
  DateTime _selectedDate = DateTime.now();
  String? _selectedProjectId;
  bool _loading = false;
  bool _isExpanded = false;

  // For weekly mode
  int _selectedWeekIndex = 0; // 0 = current week, 1-3 = previous weeks

  // For monthly mode
  int _selectedMonthIndex = 0; // 0 = current month, 1-2 = previous months

  // For quarterly mode
  int _selectedQuarterIndex = 0; // 0 = current quarter, 1-2 = previous quarters

  // Dummy data
  Map<String, dynamic> _dummyDailyData = {};


  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.preSelectedProjectId;
    _generateDummyData();
    if (widget.preSelectedProjectId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AnalyticsProvider>().setProjectId(widget.preSelectedProjectId);
      });
    }
  }

  void _generateDummyData() {
    // Daily dummy data
    _dummyDailyData = {
      'date': _selectedDate,
      'checkIn': '09:15 AM',
      'checkOut': '06:30 PM',
      'totalHours': 8.25,
      'requiredHours': 9.0,
      'shortfall': 0.75,
      'hasShortfall': true,
    };
  }

  // UPDATE: _selectDate to disable future dates
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Only allow until today
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _changeDate(int delta) {
    setState(() {
      final newDate = _selectedDate.add(Duration(days: delta));
      if (newDate.isBefore(DateTime.now().add(Duration(days: 1)))) {
        _selectedDate = newDate;
      }
    });
  }

  String _getDateLabel() {
    switch (_mode) {
      case AnalyticsMode.daily:
        return '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
      case AnalyticsMode.weekly:
        return _getWeekLabel(_selectedWeekIndex);
      case AnalyticsMode.monthly:
        return _getMonthLabel(_selectedMonthIndex);
      case AnalyticsMode.quarterly:
        return _getQuarterLabel(_selectedQuarterIndex);
      default:
        return ''; // ✅ fallback to avoid null return
    }
  }

  String _getWeekLabel(int index) {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: 7 * index));
    final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));

    if (index == 0) {
      return 'Current Week\n(${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month})';
    } else {
      return 'Week $index ago\n(${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month})';
    }
  }

  String _getMonthLabel(int index) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - index, 1);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    int safeMonth = targetMonth.month - 1;
    if (safeMonth < 0) safeMonth += 12;

    if (index == 0) {
      return 'Current Month\n(${months[safeMonth]} ${targetMonth.year})';  // Changed /n to \n
    } else {
      return '${months[safeMonth]} ${targetMonth.year}';
    }
  }
  String _getQuarterLabel(int index) {
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    final targetQuarter = currentQuarter - index;
    final year = targetQuarter > 0 ? now.year : now.year - 1;
    final quarter = targetQuarter > 0 ? targetQuarter : 4 + targetQuarter;

    if (index == 0) {
      return 'Current Quarter\n(Q$quarter $year)';  // Removed extra space before (
    } else {
      return 'Q$quarter $year';
    }
  }
  @override
  Widget build(BuildContext context) {
    final analyticsProvider = context.watch<AnalyticsProvider>();
    final dashboardProvider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: Text('Attendance Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildModeSelector(),
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
                    SizedBox(height: 20),
                    _buildDateSelector(),
                    SizedBox(height: 20),

                    // Show week/month/quarter selector
                    if (_mode == AnalyticsMode.weekly) _buildWeekSelector(),
                    if (_mode == AnalyticsMode.monthly) _buildMonthSelector(),
                    if (_mode == AnalyticsMode.quarterly) _buildQuarterSelector(),

                    SizedBox(height: 20),
                    _buildProjectSelector(dashboardProvider),
                    SizedBox(height: 20),

                    // Different views for different modes
                    if (_mode == AnalyticsMode.daily)
                      _buildDailyView()
                    else
                      _buildExpandableView(),
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

  Widget _buildModeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(child: _buildModeButton('Daily', AnalyticsMode.daily)),
          SizedBox(width: 8),
          Expanded(child: _buildModeButton('Weekly', AnalyticsMode.weekly)),
          SizedBox(width: 8),
          Expanded(child: _buildModeButton('Monthly', AnalyticsMode.monthly)),
          SizedBox(width: 8),
          Expanded(child: _buildModeButton('Quarterly', AnalyticsMode.quarterly)),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, AnalyticsMode mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = mode;
          _isExpanded = false;
        });

        // Open date picker only for daily mode
        if (mode == AnalyticsMode.daily) {
          _selectDate();
        }else  if (mode == AnalyticsMode.weekly) {
          _showWeekDrawer();
        } else if (mode == AnalyticsMode.monthly) {
          _showMonthDrawer();
        } else if (mode == AnalyticsMode.quarterly) {
          _showQuarterDrawer();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),  // Reduced padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,  // Reduced from 13
          ),
        ),
      ),
    );
  }

  void _showWeekDrawer() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => WeekSelectionDrawer(
        selectedIndex: _selectedWeekIndex,
        onWeekSelected: (index) {
          setState(() => _selectedWeekIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMonthDrawer() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => MonthSelectionDrawer(
        selectedIndex: _selectedMonthIndex,
        onMonthSelected: (index) {
          setState(() => _selectedMonthIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showQuarterDrawer() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => QuarterSelectionDrawer(
        selectedIndex: _selectedQuarterIndex,
        onQuarterSelected: (index) {
          setState(() => _selectedQuarterIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, size: 28),
            onPressed: () {
              if (_mode == AnalyticsMode.daily) {
                _changeDate(-1);
              } else if (_mode == AnalyticsMode.weekly && _selectedWeekIndex < 3) {
                setState(() => _selectedWeekIndex++);
              } else if (_mode == AnalyticsMode.monthly && _selectedMonthIndex < 3) {
                setState(() => _selectedMonthIndex++);
              } else if (_mode == AnalyticsMode.quarterly && _selectedQuarterIndex < 3) {
                setState(() => _selectedQuarterIndex++);
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
                if (_mode == AnalyticsMode.daily) {
                  _selectDate();
                } else if (_mode == AnalyticsMode.weekly) {
                  _showWeekDrawer();
                } else if (_mode == AnalyticsMode.monthly) {
                  _showMonthDrawer();
                } else if (_mode == AnalyticsMode.quarterly) {
                  _showQuarterDrawer();
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
                    Flexible(  // Added Flexible
                      child: Text(
                        _getDateLabel(),
                        style: TextStyle(
                          fontSize: 14,  // Reduced from 16
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
              if (_mode == AnalyticsMode.daily) {
                _changeDate(1);
              } else if (_mode == AnalyticsMode.weekly && _selectedWeekIndex > 0) {
                setState(() => _selectedWeekIndex--);
              } else if (_mode == AnalyticsMode.monthly && _selectedMonthIndex > 0) {
                setState(() => _selectedMonthIndex--);
              } else if (_mode == AnalyticsMode.quarterly && _selectedQuarterIndex > 0) {
                setState(() => _selectedQuarterIndex--);
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

  Widget _buildWeekSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Week',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(4, (index) {
                final isSelected = _selectedWeekIndex == index;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWeekIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        index == 0 ? 'Current Week' : 'Week $index ago',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = _selectedMonthIndex == index;
          final now = DateTime.now();
          final targetMonth = DateTime(now.year, now.month - index, 1);
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          int safeMonth = targetMonth.month - 1;
          if (safeMonth < 0) safeMonth += 12;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMonthIndex = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${months[safeMonth]} ${targetMonth.year}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuarterSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = _selectedQuarterIndex == index;
          final now = DateTime.now();
          final currentQuarter = ((now.month - 1) ~/ 3) + 1;
          final targetQuarter = currentQuarter - index;
          final year = targetQuarter > 0 ? now.year : now.year - 1;
          final quarter = targetQuarter > 0 ? targetQuarter : 4 + targetQuarter;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedQuarterIndex = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Q$quarter $year',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDailySummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDailyView(), // shows the daily cards (check-in, checkout, etc.)
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProjectSelector(AppProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedProjectId,
              hint: Row(
                children: [
                  Icon(Icons.apps, size: 20, color: AppColors.primaryBlue),
                  SizedBox(width: 12),
                  Text('All Projects', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              isExpanded: true,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.apps, size: 20, color: AppColors.primaryBlue),
                      SizedBox(width: 12),
                      Text('All Projects', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                ...provider.user!.projects.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Row(
                    children: [
                      Icon(Icons.work_outline, size: 20, color: Colors.blue),
                      SizedBox(width: 12),
                      Text(p.name, style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() => _selectedProjectId = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyView() {
    final data = _dummyDailyData;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Table
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 15),

                // Table UI
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Header Row
                      Row(
                        children: [
                          _buildHeaderText('Check In', Colors.green),
                          _buildHeaderText('Check Out', Colors.red),
                          _buildHeaderText('Total Hrs', Colors.blue),
                          _buildHeaderText('Shortfall', data['hasShortfall'] ? Colors.red : Colors.green),
                        ],
                      ),
                      Divider(height: 20, color: Colors.grey.shade400, thickness: 1.5),

                      // Data Row
                      Row(
                        children: [
                          _buildDataText(data['checkIn'], Colors.green),
                          _buildDataText(data['checkOut'], Colors.red),
                          _buildDataText('${data['totalHours']}h', Colors.blue),
                          _buildDataText(
                            data['hasShortfall'] ? '${data['shortfall']}h' : 'None',
                            data['hasShortfall'] ? Colors.red : Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pie Chart for Daily
          _buildDailyPieChart(data),
        ],
      ),
    );
  }

  Widget _buildExpandableView() {
    // Only for weekly, monthly, quarterly
    if (_mode == AnalyticsMode.daily) {
      return _buildDailyView();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSummaryCardsWithIcon(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryCardsWithIcon() {

    final Map<String, dynamic> _dummyWeeklyData = {
      'totalDays': 7,
      'present': 5,
      'leave': 1,
      'absent': 1,
      'onTime': 4,
      'late': 2,
    };

    final Map<String, dynamic> _dummyMonthlyData = {
      'totalDays': 30,
      'present': 22,
      'leave': 3,
      'absent': 5,
      'onTime': 18,
      'late': 7,
    };

    final Map<String, dynamic> _dummyQuarterlyData = {
      'totalDays': 90,
      'present': 70,
      'leave': 10,
      'absent': 10,
      'onTime': 60,
      'late': 20,
    };

    Map<String, dynamic> data;

    switch (_mode) {
      case AnalyticsMode.daily:
        return _buildDailySummarySection();

      case AnalyticsMode.weekly:
        data = _dummyWeeklyData;
        break;
      case AnalyticsMode.monthly:
        data = _dummyMonthlyData;
        break;
      case AnalyticsMode.quarterly:
        data = _dummyQuarterlyData;
        break;
      default:
        data = {};
    }

    final totalDays = data['totalDays'];
    final totalPresent = data['present'];
    final totalLeave = data['leave'];
    final totalAbsent = data['absent'];
    final totalOnTime = data['onTime'];
    final totalLate = data['late'];


    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title + icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              IconButton(
                icon: Icon(Icons.bar_chart_rounded, color: Colors.blueAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceDetailedScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Summary Table
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    _buildHeaderText('Days', Colors.grey.shade700),
                    _buildHeaderText('P', Colors.green),
                    _buildHeaderText('L', Colors.orange),
                    _buildHeaderText('A', Colors.red),
                    _buildHeaderText('OnTime', Colors.blue),
                    _buildHeaderText('Late', Colors.purple),
                  ],
                ),
                Divider(height: 20, color: Colors.grey.shade400, thickness: 1.5),

                // Data Row
                Row(
                  children: [
                    _buildDataText('$totalDays', Colors.grey.shade800),
                    _buildDataText('$totalPresent', Colors.green),
                    _buildDataText('$totalLeave', Colors.orange),
                    _buildDataText('$totalAbsent', Colors.red),
                    _buildDataText('$totalOnTime', Colors.blue),
                    _buildDataText('$totalLate', Colors.purple),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pie Chart UI
          Container(
            height: 220,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: totalPresent.toDouble(),
                          title: '$totalPresent',
                          color: Colors.green,
                          radius: 50,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: totalLeave.toDouble(),
                          title: '$totalLeave',
                          color: Colors.orange,
                          radius: 50,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: totalAbsent.toDouble(),
                          title: '$totalAbsent',
                          color: Colors.red,
                          radius: 50,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: totalOnTime.toDouble(),
                          title: '$totalOnTime',
                          color: Colors.blue,
                          radius: 50,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: totalLate.toDouble(),
                          title: '$totalLate',
                          color: Colors.purple,
                          radius: 50,
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 20),

                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Present', Colors.green, totalPresent),
                      SizedBox(height: 8),
                      _buildLegendItem('Leave', Colors.orange, totalLeave),
                      SizedBox(height: 8),
                      _buildLegendItem('Absent', Colors.red, totalAbsent),
                      SizedBox(height: 8),
                      _buildLegendItem('OnTime', Colors.blue, totalOnTime),
                      SizedBox(height: 8),
                      _buildLegendItem('Late', Colors.purple, totalLate),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper Text Builders
  Widget _buildHeaderText(String text, Color color) => Expanded(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );

  Widget _buildDataText(String text, Color color) => Expanded(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );

  Widget _buildLegendItem(String label, Color color, int value) => Row(
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      SizedBox(width: 8),
      Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    ],
  );
  }
Widget _buildDailyPieChart(Map<String, dynamic> data) {
  final totalHours = data['totalHours'];
  final requiredHours = data['requiredHours'];
  final worked = totalHours.toDouble();
  final remaining = (requiredHours - totalHours).toDouble();

  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hours Distribution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: worked,
                        title: '${worked.toStringAsFixed(1)}h',
                        color: Colors.green,
                        radius: 50,
                        titleStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: remaining > 0 ? remaining : 0,
                        title: remaining > 0 ? '${remaining.toStringAsFixed(1)}h' : '',
                        color: Colors.red,
                        radius: 50,
                        titleStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPieChartLegend('Worked', Colors.green, worked.toInt()),
                  SizedBox(height: 12),
                  if (remaining > 0)
                    _buildPieChartLegend('Shortfall', Colors.red, remaining.toInt()),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Add this helper
Widget _buildPieChartLegend(String label, Color color, int value) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$value hrs',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

