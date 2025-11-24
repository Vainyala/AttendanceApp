import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodSelector extends StatefulWidget {
  final AttendanceAnalyticsViewModel viewModel;
  final List<String> periods = ['daily', 'weekly', 'monthly', 'quarterly'];

  PeriodSelector({super.key, required this.viewModel});

  @override
  State<PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border.all(
          color: isDark ? AppColors.grey700 : AppColors.grey300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : AppColors.grey400.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Period Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.periods.map((period) {
              final isSelected = widget.viewModel.selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showCalendarPicker(context, period),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                            ? AppColors.grey600
                            : AppColors.grey300,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.viewModel.getPeriodDisplayName(period),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : isDark
                                ? AppColors.grey300
                                : AppColors.grey700,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.white.withOpacity(0.8),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showCalendarPicker(BuildContext context, String period) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (period) {
      case 'daily':
        _showDatePicker(context, isDark);
        break;
      case 'weekly':
        _showWeekPicker(context, isDark);
        break;
      case 'monthly':
        _showMonthPicker(context, isDark);
        break;
      case 'quarterly':
        _showQuarterPicker(context, isDark);
        break;
      default:
        widget.viewModel.changePeriod(period);
    }
  }

  void _showDatePicker(BuildContext context, bool isDark) {
    showDatePicker(
      context: context,
      initialDate: widget.viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: AppColors.primaryLight,
                    onPrimary: AppColors.white,
                    surface: AppColors.surfaceDark,
                    onSurface: AppColors.textInverse,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryLight,
                    ),
                  ),
                  dialogTheme: DialogThemeData(
                    backgroundColor: AppColors.surfaceDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              : Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: AppColors.white,
                    surface: AppColors.surfaceLight,
                    onSurface: AppColors.textPrimary,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  dialogTheme: DialogThemeData(
                    backgroundColor: AppColors.surfaceLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        widget.viewModel.changePeriod('daily', selectedDate: selectedDate);
      }
    });
  }

  void _showWeekPicker(BuildContext context, bool isDark) {
    final now = widget.viewModel.selectedDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SELECT WEEK',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.grey200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.grey600 : AppColors.grey300,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Access - Last 4 Weeks Only
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAST 4 WEEKS',
                    style: TextStyle(
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildLast4WeeksOptions(isDark),
                  ),
                ],
              ),
            ),

            // Only Last 4 Weeks List
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  final weekStart = widget.viewModel.getFirstDayOfWeek(
                    DateTime.now().subtract(Duration(days: index * 7)),
                  );
                  final weekEnd = weekStart.add(const Duration(days: 6));
                  final isCurrentWeek = _isSameWeek(weekStart, DateTime.now());

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isCurrentWeek
                          ? AppColors.primary.withOpacity(0.1)
                          : isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      border: Border.all(
                        color: isCurrentWeek
                            ? AppColors.primary
                            : isDark
                            ? AppColors.grey600
                            : AppColors.grey300,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCurrentWeek
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrentWeek
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${_getWeekNumber(weekStart)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isCurrentWeek
                                  ? AppColors.primary
                                  : isDark
                                  ? AppColors.grey300
                                  : AppColors.grey700,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        'WEEK ${_getWeekNumber(weekStart)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textInverse
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
                        style: TextStyle(
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                      trailing: isCurrentWeek
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            )
                          : Icon(
                              Icons.chevron_right_rounded,
                              color: isDark
                                  ? AppColors.grey500
                                  : AppColors.grey400,
                            ),
                      onTap: () {
                        widget.viewModel.changePeriod(
                          'weekly',
                          selectedDate: weekStart,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLast4WeeksOptions(bool isDark) {
    final now = DateTime.now();
    final options = <Widget>[];

    for (int i = 0; i < 4; i++) {
      final weekStart = widget.viewModel.getFirstDayOfWeek(
        now.subtract(Duration(days: i * 7)),
      );
      final isCurrent = i == 0;

      options.add(
        GestureDetector(
          onTap: () {
            widget.viewModel.changePeriod('weekly', selectedDate: weekStart);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary.withOpacity(0.1)
                  : isDark
                  ? AppColors.grey800
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent
                    ? AppColors.primary
                    : isDark
                    ? AppColors.grey600
                    : AppColors.grey300,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  i == 0 ? 'THIS WEEK' : '${i}W AGO',
                  style: TextStyle(
                    color: isCurrent
                        ? AppColors.primary
                        : isDark
                        ? AppColors.textInverse
                        : AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(weekStart),
                  style: TextStyle(
                    color: isCurrent
                        ? AppColors.primary
                        : isDark
                        ? AppColors.grey400
                        : AppColors.grey600,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return options;
  }

  void _showMonthPicker(BuildContext context, bool isDark) {
    final now = widget.viewModel.selectedDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SELECT MONTH',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.grey200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.grey600 : AppColors.grey300,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Access - Last 3 Months Only
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAST 3 MONTHS',
                    style: TextStyle(
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildLast3MonthsOptions(isDark),
                  ),
                ],
              ),
            ),

            // Only Last 3 Months List
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  final monthDate = DateTime(
                    DateTime.now().year,
                    DateTime.now().month - index,
                  );
                  final isCurrentMonth = index == 0;
                  final monthName = DateFormat('MMMM yyyy').format(monthDate);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isCurrentMonth
                          ? AppColors.primary.withOpacity(0.1)
                          : isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      border: Border.all(
                        color: isCurrentMonth
                            ? AppColors.primary
                            : isDark
                            ? AppColors.grey600
                            : AppColors.grey300,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCurrentMonth
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrentMonth
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${monthDate.month}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isCurrentMonth
                                  ? AppColors.primary
                                  : isDark
                                  ? AppColors.grey300
                                  : AppColors.grey700,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        monthName.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textInverse
                              : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${_getDaysInMonth(monthDate)} days',
                        style: TextStyle(
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                        ),
                      ),
                      trailing: isCurrentMonth
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: AppColors.primary,
                                size: 16,
                              ),
                            )
                          : Icon(
                              Icons.chevron_right_rounded,
                              color: isDark
                                  ? AppColors.grey500
                                  : AppColors.grey400,
                            ),
                      onTap: () {
                        widget.viewModel.changePeriod(
                          'monthly',
                          selectedDate: monthDate,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLast3MonthsOptions(bool isDark) {
    final now = DateTime.now();
    final options = <Widget>[];
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    for (int i = 0; i < 3; i++) {
      final monthDate = DateTime(now.year, now.month - i);
      final isCurrent = i == 0;

      options.add(
        GestureDetector(
          onTap: () {
            widget.viewModel.changePeriod('monthly', selectedDate: monthDate);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary.withOpacity(0.1)
                  : isDark
                  ? AppColors.grey800
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent
                    ? AppColors.primary
                    : isDark
                    ? AppColors.grey600
                    : AppColors.grey300,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  i == 0 ? 'THIS MONTH' : '${i}M AGO',
                  style: TextStyle(
                    color: isCurrent
                        ? AppColors.primary
                        : isDark
                        ? AppColors.textInverse
                        : AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  months[monthDate.month - 1],
                  style: TextStyle(
                    color: isCurrent
                        ? AppColors.primary
                        : isDark
                        ? AppColors.grey400
                        : AppColors.grey600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return options;
  }

  void _showQuarterPicker(BuildContext context, bool isDark) {
    final now = widget.viewModel.selectedDate;
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    final currentYear = now.year;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SELECT QUARTER',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.grey200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.grey600 : AppColors.grey300,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(20),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuarterCard(
                    context,
                    1,
                    'Q1',
                    'JAN - MAR',
                    currentQuarter,
                    currentYear,
                    isDark,
                  ),
                  _buildQuarterCard(
                    context,
                    2,
                    'Q2',
                    'APR - JUN',
                    currentQuarter,
                    currentYear,
                    isDark,
                  ),
                  _buildQuarterCard(
                    context,
                    3,
                    'Q3',
                    'JUL - SEP',
                    currentQuarter,
                    currentYear,
                    isDark,
                  ),
                  _buildQuarterCard(
                    context,
                    4,
                    'Q4',
                    'OCT - DEC',
                    currentQuarter,
                    currentYear,
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuarterCard(
    BuildContext context,
    int quarter,
    String title,
    String subtitle,
    int currentQuarter,
    int year,
    bool isDark,
  ) {
    final isSelected = currentQuarter == quarter;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : isDark
              ? AppColors.grey600
              : AppColors.grey300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : AppColors.grey400.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final quarterMonth = (quarter - 1) * 3 + 1;
            final selectedDate = DateTime(year, quarterMonth);
            widget.viewModel.changePeriod(
              'quarterly',
              selectedDate: selectedDate,
            );
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(minHeight: isLandscape ? 80 : 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isLandscape ? 20 : 22,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : isDark
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isLandscape ? 10 : 11,
                      color: isSelected
                          ? AppColors.primary
                          : isDark
                          ? AppColors.grey400
                          : AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: isLandscape ? 14 : 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDay).inDays;
    return ((daysDiff + firstDay.weekday + 5) / 7).floor();
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final aStart = widget.viewModel.getFirstDayOfWeek(a);
    final bStart = widget.viewModel.getFirstDayOfWeek(b);
    return aStart.difference(bStart).inDays == 0;
  }
}

// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class PeriodSelector extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final List<String> periods = ['daily', 'weekly', 'monthly', 'quarterly'];

//   PeriodSelector({super.key, required this.viewModel});

//   @override
//   State<PeriodSelector> createState() => _PeriodSelectorState();
// }

// class _PeriodSelectorState extends State<PeriodSelector> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Period Tabs
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: widget.periods.map((period) {
//               final isSelected = widget.viewModel.selectedPeriod == period;
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => _showCalendarPicker(context, period),
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 2),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       gradient: isSelected
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.cyan.shade400,
//                                 Colors.blue.shade400,
//                               ],
//                             )
//                           : LinearGradient(
//                               colors: [
//                                 Colors.white.withOpacity(0.1),
//                                 Colors.white.withOpacity(0.05),
//                               ],
//                             ),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: isSelected
//                             ? Colors.cyan.shade400.withOpacity(0.4)
//                             : Colors.white.withOpacity(0.1),
//                         width: 1.5,
//                       ),
//                       boxShadow: isSelected
//                           ? [
//                               BoxShadow(
//                                 color: Colors.cyan.shade400.withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ]
//                           : null,
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           widget.viewModel.getPeriodDisplayName(period),
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: isSelected
//                                 ? Colors.white
//                                 : Colors.white.withOpacity(0.7),
//                             fontWeight: FontWeight.w800,
//                             fontSize: 10,
//                             letterSpacing: 0.8,
//                           ),
//                         ),
//                         if (isSelected) ...[
//                           const SizedBox(height: 4),
//                           Container(
//                             width: 6,
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.white.withOpacity(0.8),
//                                   blurRadius: 4,
//                                   spreadRadius: 1,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCalendarPicker(BuildContext context, String period) {
//     switch (period) {
//       case 'daily':
//         _showDatePicker(context);
//         break;
//       case 'weekly':
//         _showWeekPicker(context);
//         break;
//       case 'monthly':
//         _showMonthPicker(context);
//         break;
//       case 'quarterly':
//         _showQuarterPicker(context);
//         break;
//       default:
//         widget.viewModel.changePeriod(period);
//     }
//   }

//   void _showDatePicker(BuildContext context) {
//     showDatePicker(
//       context: context,
//       initialDate: widget.viewModel.selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.dark(
//               primary: Colors.cyan.shade400,
//               onPrimary: Colors.black,
//               surface: Colors.grey.shade900,
//               onSurface: Colors.white,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.cyan.shade400,
//               ),
//             ),
//             dialogTheme: DialogThemeData(backgroundColor: Colors.grey.shade900),
//           ),
//           child: child!,
//         );
//       },
//     ).then((selectedDate) {
//       if (selectedDate != null) {
//         widget.viewModel.changePeriod('daily', selectedDate: selectedDate);
//       }
//     });
//   }

//   void _showWeekPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400, // Reduced height for only last 4 weeks
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'SELECT WEEK',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Quick Access - Last 4 Weeks Only
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'LAST 4 WEEKS',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: _buildLast4WeeksOptions(),
//                   ),
//                 ],
//               ),
//             ),

//             // Only Last 4 Weeks List (No historical data)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 4, // Only last 4 weeks
//                 itemBuilder: (context, index) {
//                   final weekStart = widget.viewModel.getFirstDayOfWeek(
//                     DateTime.now().subtract(Duration(days: index * 7)),
//                   );
//                   final weekEnd = weekStart.add(const Duration(days: 6));
//                   final isCurrentWeek = _isSameWeek(weekStart, DateTime.now());

//                   return Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: isCurrentWeek
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.cyan.shade400.withOpacity(0.3),
//                                 Colors.blue.shade400.withOpacity(0.2),
//                               ],
//                             )
//                           : LinearGradient(
//                               colors: [
//                                 Colors.white.withOpacity(0.1),
//                                 Colors.white.withOpacity(0.05),
//                               ],
//                             ),
//                       border: Border.all(
//                         color: isCurrentWeek
//                             ? Colors.cyan.shade400.withOpacity(0.4)
//                             : Colors.white.withOpacity(0.2),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: isCurrentWeek
//                               ? Colors.cyan.shade400.withOpacity(0.2)
//                               : Colors.transparent,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isCurrentWeek
//                                 ? Colors.cyan.shade400
//                                 : Colors.transparent,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${_getWeekNumber(weekStart)}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w800,
//                               color: isCurrentWeek
//                                   ? Colors.cyan.shade400
//                                   : Colors.white.withOpacity(0.7),
//                             ),
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         'WEEK ${_getWeekNumber(weekStart)}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       subtitle: Text(
//                         '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
//                         style: TextStyle(color: Colors.white.withOpacity(0.7)),
//                       ),
//                       trailing: isCurrentWeek
//                           ? Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(
//                                 color: Colors.cyan.shade400.withOpacity(0.2),
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.cyan.shade400),
//                               ),
//                               child: Icon(
//                                 Icons.check_rounded,
//                                 color: Colors.cyan.shade400,
//                                 size: 16,
//                               ),
//                             )
//                           : Icon(
//                               Icons.chevron_right_rounded,
//                               color: Colors.white.withOpacity(0.5),
//                             ),
//                       onTap: () {
//                         widget.viewModel.changePeriod(
//                           'weekly',
//                           selectedDate: weekStart,
//                         );
//                         Navigator.pop(context);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildLast4WeeksOptions() {
//     final now = DateTime.now();
//     final options = <Widget>[];

//     for (int i = 0; i < 4; i++) {
//       final weekStart = widget.viewModel.getFirstDayOfWeek(
//         now.subtract(Duration(days: i * 7)),
//       );
//       final weekEnd = weekStart.add(const Duration(days: 6));
//       final isCurrent = i == 0;

//       options.add(
//         GestureDetector(
//           onTap: () {
//             widget.viewModel.changePeriod('weekly', selectedDate: weekStart);
//             Navigator.pop(context);
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.cyan.shade400.withOpacity(isCurrent ? 0.3 : 0.2),
//                   Colors.blue.shade400.withOpacity(isCurrent ? 0.2 : 0.1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   i == 0 ? 'THIS WEEK' : '${i}W AGO',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _formatDate(weekStart),
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 8,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     return options;
//   }

//   void _showMonthPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400, // Reduced height for only last 3 months
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'SELECT MONTH',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Quick Access - Last 3 Months Only
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'LAST 3 MONTHS',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: _buildLast3MonthsOptions(),
//                   ),
//                 ],
//               ),
//             ),

//             // Only Last 3 Months List (No historical data)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 3, // Only last 3 months
//                 itemBuilder: (context, index) {
//                   final monthDate = DateTime(
//                     DateTime.now().year,
//                     DateTime.now().month - index,
//                   );
//                   final isCurrentMonth = index == 0;
//                   final monthName = DateFormat('MMMM yyyy').format(monthDate);

//                   return Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: isCurrentMonth
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.cyan.shade400.withOpacity(0.3),
//                                 Colors.blue.shade400.withOpacity(0.2),
//                               ],
//                             )
//                           : LinearGradient(
//                               colors: [
//                                 Colors.white.withOpacity(0.1),
//                                 Colors.white.withOpacity(0.05),
//                               ],
//                             ),
//                       border: Border.all(
//                         color: isCurrentMonth
//                             ? Colors.cyan.shade400.withOpacity(0.4)
//                             : Colors.white.withOpacity(0.2),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: isCurrentMonth
//                               ? Colors.cyan.shade400.withOpacity(0.2)
//                               : Colors.transparent,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isCurrentMonth
//                                 ? Colors.cyan.shade400
//                                 : Colors.transparent,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${monthDate.month}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w800,
//                               color: isCurrentMonth
//                                   ? Colors.cyan.shade400
//                                   : Colors.white.withOpacity(0.7),
//                             ),
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         monthName.toUpperCase(),
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       subtitle: Text(
//                         '${_getDaysInMonth(monthDate)} days',
//                         style: TextStyle(color: Colors.white.withOpacity(0.7)),
//                       ),
//                       trailing: isCurrentMonth
//                           ? Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(
//                                 color: Colors.cyan.shade400.withOpacity(0.2),
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.cyan.shade400),
//                               ),
//                               child: Icon(
//                                 Icons.check_rounded,
//                                 color: Colors.cyan.shade400,
//                                 size: 16,
//                               ),
//                             )
//                           : Icon(
//                               Icons.chevron_right_rounded,
//                               color: Colors.white.withOpacity(0.5),
//                             ),
//                       onTap: () {
//                         widget.viewModel.changePeriod(
//                           'monthly',
//                           selectedDate: monthDate,
//                         );
//                         Navigator.pop(context);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildLast3MonthsOptions() {
//     final now = DateTime.now();
//     final options = <Widget>[];
//     final months = [
//       'JAN',
//       'FEB',
//       'MAR',
//       'APR',
//       'MAY',
//       'JUN',
//       'JUL',
//       'AUG',
//       'SEP',
//       'OCT',
//       'NOV',
//       'DEC',
//     ];

//     for (int i = 0; i < 3; i++) {
//       final monthDate = DateTime(now.year, now.month - i);
//       final isCurrent = i == 0;

//       options.add(
//         GestureDetector(
//           onTap: () {
//             widget.viewModel.changePeriod('monthly', selectedDate: monthDate);
//             Navigator.pop(context);
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.cyan.shade400.withOpacity(isCurrent ? 0.3 : 0.2),
//                   Colors.blue.shade400.withOpacity(isCurrent ? 0.2 : 0.1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   i == 0 ? 'THIS MONTH' : '${i}M AGO',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   months[monthDate.month - 1],
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     return options;
//   }

//   void _showQuarterPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;
//     final currentQuarter = ((now.month - 1) ~/ 3) + 1;
//     final currentYear = now.year;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'SELECT QUARTER',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: GridView.count(
//                 padding: const EdgeInsets.all(20),
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.5,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: [
//                   _buildQuarterCard(
//                     context,
//                     1,
//                     'Q1',
//                     'JAN - MAR',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     2,
//                     'Q2',
//                     'APR - JUN',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     3,
//                     'Q3',
//                     'JUL - SEP',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     4,
//                     'Q4',
//                     'OCT - DEC',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuarterCard(
//     BuildContext context,
//     int quarter,
//     String title,
//     String subtitle,
//     int currentQuarter,
//     int year,
//   ) {
//     final isSelected = currentQuarter == quarter;
//     final isLandscape =
//         MediaQuery.of(context).orientation == Orientation.landscape;

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: isSelected
//             ? LinearGradient(
//                 colors: [
//                   Colors.cyan.shade400.withOpacity(0.3),
//                   Colors.blue.shade400.withOpacity(0.2),
//                 ],
//               )
//             : LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.1),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//         border: Border.all(
//           color: isSelected
//               ? Colors.cyan.shade400.withOpacity(0.4)
//               : Colors.white.withOpacity(0.2),
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: () {
//             final quarterMonth = (quarter - 1) * 3 + 1;
//             final selectedDate = DateTime(year, quarterMonth);
//             widget.viewModel.changePeriod(
//               'quarterly',
//               selectedDate: selectedDate,
//             );
//             Navigator.pop(context);
//           },
//           child: Container(
//             padding: const EdgeInsets.all(12), // Reduced padding
//             constraints: BoxConstraints(
//               minHeight: isLandscape ? 80 : 100, // Adaptive height
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Quarter Title
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: isLandscape ? 20 : 22, // Responsive font size
//                       fontWeight: FontWeight.w800,
//                       color: isSelected ? Colors.cyan.shade400 : Colors.white,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 // Quarter Subtitle
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: isLandscape ? 10 : 11, // Responsive font size
//                       color: isSelected
//                           ? Colors.cyan.shade400
//                           : Colors.white.withOpacity(0.8),
//                       fontWeight: FontWeight.w600,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                   ),
//                 ),

//                 if (isSelected) ...[
//                   const SizedBox(height: 6),
//                   Container(
//                     padding: const EdgeInsets.all(3),
//                     decoration: BoxDecoration(
//                       color: Colors.cyan.shade400.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.cyan.shade400),
//                     ),
//                     child: Icon(
//                       Icons.check_rounded,
//                       color: Colors.cyan.shade400,
//                       size: isLandscape ? 14 : 16, // Responsive icon size
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods
//   String _formatDate(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday + 5) / 7).floor();
//   }

//   int _getDaysInMonth(DateTime date) {
//     return DateTime(date.year, date.month + 1, 0).day;
//   }

//   bool _isSameWeek(DateTime a, DateTime b) {
//     final aStart = widget.viewModel.getFirstDayOfWeek(a);
//     final bStart = widget.viewModel.getFirstDayOfWeek(b);
//     return aStart.difference(bStart).inDays == 0;
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class PeriodSelector extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final List<String> periods = ['daily', 'weekly', 'monthly', 'quarterly'];

//   PeriodSelector({super.key, required this.viewModel});

//   @override
//   State<PeriodSelector> createState() => _PeriodSelectorState();
// }

// class _PeriodSelectorState extends State<PeriodSelector> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//       ),
//       child: Column(
//         children: [
//           // Header
//           // Row(
//           //   children: [
//           //     // Container(
//           //     //   padding: const EdgeInsets.all(6),
//           //     //   decoration: BoxDecoration(
//           //     //     gradient: LinearGradient(
//           //     //       colors: [Colors.cyan.shade400, Colors.blue.shade400],
//           //     //     ),
//           //     //     shape: BoxShape.circle,
//           //     //   ),
//           //     //   child: const Icon(
//           //     //     Icons.calendar_month_rounded,
//           //     //     color: Colors.white,
//           //     //     size: 16,
//           //     //   ),
//           //     // ),
//           //     // const SizedBox(width: 8),
//           //     // const Text(
//           //     //   'TIME PERIOD SELECTOR',
//           //     //   style: TextStyle(
//           //     //     color: Colors.white,
//           //     //     fontSize: 14,
//           //     //     fontWeight: FontWeight.w800,
//           //     //     letterSpacing: 1.2,
//           //     //   ),
//           //     // ),
//           //   ],
//           // ),
//           // const SizedBox(height: 12),

//           // Period Tabs
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: widget.periods.map((period) {
//               final isSelected = widget.viewModel.selectedPeriod == period;
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => _showCalendarPicker(context, period),
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 2),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       gradient: isSelected
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.cyan.shade400,
//                                 Colors.blue.shade400,
//                               ],
//                             )
//                           : null,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color: isSelected
//                             ? Colors.cyan.shade400.withOpacity(0.4)
//                             : Colors.white.withOpacity(0.1),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           _getPeriodDisplayName(period),
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: isSelected
//                                 ? Colors.white
//                                 : Colors.white.withOpacity(0.7),
//                             fontWeight: FontWeight.w800,
//                             fontSize: 10,
//                             letterSpacing: 0.8,
//                           ),
//                         ),
//                         if (isSelected) ...[
//                           const SizedBox(height: 4),
//                           Container(
//                             width: 6,
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.white.withOpacity(0.8),
//                                   blurRadius: 4,
//                                   spreadRadius: 1,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getPeriodDisplayName(String period) {
//     switch (period) {
//       case 'daily':
//         return 'DAY';
//       case 'weekly':
//         return 'WEEK';
//       case 'monthly':
//         return 'MONTH';
//       case 'quarterly':
//         return 'QUARTER';
//       default:
//         return 'DAY';
//     }
//   }

//   void _showCalendarPicker(BuildContext context, String period) {
//     switch (period) {
//       case 'daily':
//         _showDatePicker(context);
//         break;
//       case 'weekly':
//         _showWeekPicker(context);
//         break;
//       case 'monthly':
//         _showMonthPicker(context);
//         break;
//       case 'quarterly':
//         _showQuarterPicker(context);
//         break;
//       default:
//         widget.viewModel.changePeriod(period);
//     }
//   }

//   void _showDatePicker(BuildContext context) {
//     showDatePicker(
//       context: context,
//       initialDate: widget.viewModel.selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.dark(
//               primary: Colors.cyan.shade400,
//               onPrimary: Colors.black,
//               surface: Colors.grey.shade900,
//               onSurface: Colors.white,
//             ),
//             dialogBackgroundColor: Colors.grey.shade900,
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.cyan.shade400,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     ).then((selectedDate) {
//       if (selectedDate != null) {
//         widget.viewModel.changePeriod('daily', selectedDate: selectedDate);
//       }
//     });
//   }

//   void _showWeekPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;
//     final firstDayOfWeek = _getFirstDayOfWeek(now);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'SELECT TIME PERIOD',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Quick Access - Last 4 Weeks
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'QUICK ACCESS - LAST 4 WEEKS',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: _buildLast4WeeksOptions(),
//                   ),
//                 ],
//               ),
//             ),

//             // All Weeks List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 104, // 2 years of weeks
//                 itemBuilder: (context, index) {
//                   final weekStart = firstDayOfWeek.add(
//                     Duration(days: (index - 52) * 7),
//                   );
//                   final weekEnd = weekStart.add(const Duration(days: 6));
//                   final isCurrentWeek = _isSameWeek(weekStart, now);

//                   return Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: isCurrentWeek
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.cyan.shade400.withOpacity(0.3),
//                                 Colors.blue.shade400.withOpacity(0.2),
//                               ],
//                             )
//                           : LinearGradient(
//                               colors: [
//                                 Colors.white.withOpacity(0.1),
//                                 Colors.white.withOpacity(0.05),
//                               ],
//                             ),
//                       border: Border.all(
//                         color: isCurrentWeek
//                             ? Colors.cyan.shade400.withOpacity(0.4)
//                             : Colors.white.withOpacity(0.2),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: isCurrentWeek
//                               ? Colors.cyan.shade400.withOpacity(0.2)
//                               : Colors.transparent,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isCurrentWeek
//                                 ? Colors.cyan.shade400
//                                 : Colors.transparent,
//                           ),
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${_getWeekNumber(weekStart)}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w800,
//                               color: isCurrentWeek
//                                   ? Colors.cyan.shade400
//                                   : Colors.white.withOpacity(0.7),
//                             ),
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         'WEEK ${_getWeekNumber(weekStart)}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       subtitle: Text(
//                         '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
//                         style: TextStyle(color: Colors.white.withOpacity(0.7)),
//                       ),
//                       trailing: isCurrentWeek
//                           ? Icon(
//                               Icons.check_circle_rounded,
//                               color: Colors.cyan.shade400,
//                             )
//                           : Icon(
//                               Icons.chevron_right_rounded,
//                               color: Colors.white.withOpacity(0.5),
//                             ),
//                       onTap: () {
//                         widget.viewModel.changePeriod(
//                           'weekly',
//                           selectedDate: weekStart,
//                         );
//                         Navigator.pop(context);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildLast4WeeksOptions() {
//     final now = DateTime.now();
//     final options = <Widget>[];

//     for (int i = 0; i < 4; i++) {
//       final weekStart = _getFirstDayOfWeek(now.subtract(Duration(days: i * 7)));
//       final weekEnd = weekStart.add(const Duration(days: 6));
//       final isCurrent = i == 0;

//       options.add(
//         GestureDetector(
//           onTap: () {
//             widget.viewModel.changePeriod('weekly', selectedDate: weekStart);
//             Navigator.pop(context);
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.cyan.shade400.withOpacity(isCurrent ? 0.3 : 0.2),
//                   Colors.blue.shade400.withOpacity(isCurrent ? 0.2 : 0.1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   i == 0 ? 'THIS WEEK' : '${i}W AGO',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${_formatDate(weekStart)}',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 8,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     return options;
//   }

//   void _showMonthPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 500,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'SELECT TIME PERIOD',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Quick Access - Last 3 Months
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'QUICK ACCESS - LAST 3 MONTHS',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 12,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.0,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: _buildLast3MonthsOptions(),
//                   ),
//                 ],
//               ),
//             ),

//             // Year Picker
//             Expanded(
//               child: Theme(
//                 data: Theme.of(context).copyWith(
//                   colorScheme: ColorScheme.dark(
//                     primary: Colors.cyan.shade400,
//                     onPrimary: Colors.black,
//                     surface: Colors.transparent,
//                     onSurface: Colors.white,
//                   ),
//                 ),
//                 child: YearPicker(
//                   firstDate: DateTime(2020),
//                   lastDate: DateTime(2030),
//                   selectedDate: DateTime(now.year, now.month),
//                   onChanged: (DateTime dateTime) {
//                     widget.viewModel.changePeriod(
//                       'monthly',
//                       selectedDate: dateTime,
//                     );
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildLast3MonthsOptions() {
//     final now = DateTime.now();
//     final options = <Widget>[];
//     final months = [
//       'JAN',
//       'FEB',
//       'MAR',
//       'APR',
//       'MAY',
//       'JUN',
//       'JUL',
//       'AUG',
//       'SEP',
//       'OCT',
//       'NOV',
//       'DEC',
//     ];

//     for (int i = 0; i < 3; i++) {
//       final monthDate = DateTime(now.year, now.month - i);
//       final isCurrent = i == 0;

//       options.add(
//         GestureDetector(
//           onTap: () {
//             widget.viewModel.changePeriod('monthly', selectedDate: monthDate);
//             Navigator.pop(context);
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.cyan.shade400.withOpacity(isCurrent ? 0.3 : 0.2),
//                   Colors.blue.shade400.withOpacity(isCurrent ? 0.2 : 0.1),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   i == 0 ? 'THIS MONTH' : '${i}M AGO',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   '${months[monthDate.month - 1]}',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//     return options;
//   }

//   void _showQuarterPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;
//     final currentQuarter = ((now.month - 1) ~/ 3) + 1;
//     final currentYear = now.year;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.9),
//             ],
//           ),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'SELECT QUARTER',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: GridView.count(
//                 padding: const EdgeInsets.all(20),
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.5,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: [
//                   _buildQuarterCard(
//                     context,
//                     1,
//                     'Q1',
//                     'JAN - MAR',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     2,
//                     'Q2',
//                     'APR - JUN',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     3,
//                     'Q3',
//                     'JUL - SEP',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     4,
//                     'Q4',
//                     'OCT - DEC',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuarterCard(
//     BuildContext context,
//     int quarter,
//     String title,
//     String subtitle,
//     int currentQuarter,
//     int year,
//   ) {
//     final isSelected = currentQuarter == quarter;

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: isSelected
//             ? LinearGradient(
//                 colors: [
//                   Colors.cyan.shade400.withOpacity(0.3),
//                   Colors.blue.shade400.withOpacity(0.2),
//                 ],
//               )
//             : LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.1),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//         border: Border.all(
//           color: isSelected
//               ? Colors.cyan.shade400.withOpacity(0.4)
//               : Colors.white.withOpacity(0.2),
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: () {
//             final quarterMonth = (quarter - 1) * 3 + 1;
//             final selectedDate = DateTime(year, quarterMonth);
//             widget.viewModel.changePeriod(
//               'quarterly',
//               selectedDate: selectedDate,
//             );
//             Navigator.pop(context);
//           },
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: isSelected ? Colors.cyan.shade400 : Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isSelected
//                         ? Colors.cyan.shade400
//                         : Colors.white.withOpacity(0.8),
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 if (isSelected) ...[
//                   const SizedBox(height: 8),
//                   Icon(
//                     Icons.check_circle_rounded,
//                     color: Colors.cyan.shade400,
//                     size: 20,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods
//   String _formatDate(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   DateTime _getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday + 5) / 7).floor();
//   }

//   bool _isSameWeek(DateTime a, DateTime b) {
//     final aStart = _getFirstDayOfWeek(a);
//     final bStart = _getFirstDayOfWeek(b);
//     return aStart.difference(bStart).inDays == 0;
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class PeriodSelector extends StatefulWidget {
//   final AttendanceAnalyticsViewModel viewModel;
//   final List<String> periods = ['daily', 'weekly', 'monthly', 'quarterly'];

//   PeriodSelector({super.key, required this.viewModel});

//   @override
//   State<PeriodSelector> createState() => _PeriodSelectorState();
// }

// class _PeriodSelectorState extends State<PeriodSelector> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: AppColors.grey100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: widget.periods.map((period) {
//           final isSelected = widget.viewModel.selectedPeriod == period;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => _showCalendarPicker(context, period),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 decoration: BoxDecoration(
//                   color: isSelected ? AppColors.primary : Colors.transparent,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       _getPeriodDisplayName(period),
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: isSelected
//                             ? AppColors.white
//                             : AppColors.textSecondary,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                     if (isSelected) ...[
//                       const SizedBox(height: 2),
//                       Container(
//                         width: 4,
//                         height: 4,
//                         decoration: const BoxDecoration(
//                           color: AppColors.white,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   String _getPeriodDisplayName(String period) {
//     switch (period) {
//       case 'daily':
//         return 'Daily';
//       case 'weekly':
//         return 'Weekly';
//       case 'monthly':
//         return 'Monthly';
//       case 'quarterly':
//         return 'Quarterly';
//       default:
//         return 'Daily';
//     }
//   }

//   void _showCalendarPicker(BuildContext context, String period) {
//     switch (period) {
//       case 'daily':
//         _showDatePicker(context);
//         break;
//       case 'weekly':
//         _showWeekPicker(context);
//         break;
//       case 'monthly':
//         _showMonthPicker(context);
//         break;
//       case 'quarterly':
//         _showQuarterPicker(context);
//         break;
//       default:
//         widget.viewModel.changePeriod(period);
//     }
//   }

//   void _showDatePicker(BuildContext context) {
//     showDatePicker(
//       context: context,
//       initialDate: widget.viewModel.selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               onSurface: AppColors.textPrimary,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: AppColors.primary),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     ).then((selectedDate) {
//       if (selectedDate != null) {
//         widget.viewModel.changePeriod('daily', selectedDate: selectedDate);
//       }
//     });
//   }

//   void _showWeekPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;
//     // Find Monday of the current week
//     final firstDayOfWeek = _getFirstDayOfWeek(now);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: BoxDecoration(
//           color: Theme.of(context).canvasColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.05),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Select Week',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close_rounded),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),

//             // Current Week Info
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today_rounded,
//                     size: 16,
//                     color: AppColors.primary,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Current: ${_getCurrentWeekInfo()}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Weeks List
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 104, // Show 2 years of weeks
//                 itemBuilder: (context, index) {
//                   final weekStart = firstDayOfWeek.add(
//                     Duration(days: (index - 52) * 7),
//                   );
//                   final weekEnd = weekStart.add(const Duration(days: 6));
//                   final isCurrentWeek = _isSameWeek(weekStart, now);

//                   return Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isCurrentWeek
//                           ? AppColors.primary.withOpacity(0.1)
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: isCurrentWeek
//                             ? AppColors.primary
//                             : Colors.transparent,
//                       ),
//                     ),
//                     child: ListTile(
//                       leading: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: isCurrentWeek
//                               ? AppColors.primary
//                               : AppColors.grey200,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${_getWeekNumber(weekStart)}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: isCurrentWeek
//                                   ? AppColors.white
//                                   : AppColors.textPrimary,
//                             ),
//                           ),
//                         ),
//                       ),
//                       title: Text(
//                         'Week ${_getWeekNumber(weekStart)}',
//                         style: TextStyle(
//                           fontWeight: isCurrentWeek
//                               ? FontWeight.w600
//                               : FontWeight.normal,
//                           color: isCurrentWeek
//                               ? AppColors.primary
//                               : AppColors.textPrimary,
//                         ),
//                       ),
//                       subtitle: Text(
//                         '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}',
//                         style: TextStyle(color: AppColors.textSecondary),
//                       ),
//                       trailing: isCurrentWeek
//                           ? Icon(
//                               Icons.check_circle_rounded,
//                               color: AppColors.primary,
//                             )
//                           : const Icon(
//                               Icons.chevron_right_rounded,
//                               color: AppColors.grey400,
//                             ),
//                       onTap: () {
//                         widget.viewModel.changePeriod(
//                           'weekly',
//                           selectedDate: weekStart,
//                         );
//                         Navigator.pop(context);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showMonthPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400,
//         decoration: BoxDecoration(
//           color: Theme.of(context).canvasColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.05),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Select Month',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close_rounded),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),

//             // Year Picker
//             Expanded(
//               child: YearPicker(
//                 firstDate: DateTime(2020),
//                 lastDate: DateTime(2030),
//                 selectedDate: DateTime(now.year, now.month),
//                 onChanged: (DateTime dateTime) {
//                   widget.viewModel.changePeriod(
//                     'monthly',
//                     selectedDate: dateTime,
//                   );
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showQuarterPicker(BuildContext context) {
//     final now = widget.viewModel.selectedDate;
//     final currentQuarter = ((now.month - 1) ~/ 3) + 1;
//     final currentYear = now.year;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400,
//         decoration: BoxDecoration(
//           color: Theme.of(context).canvasColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.05),
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Select Quarter',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close_rounded),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),

//             // Year Selection
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.chevron_left_rounded),
//                     onPressed: () {
//                       // Navigate to previous year
//                     },
//                   ),
//                   Text(
//                     currentYear.toString(),
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.chevron_right_rounded),
//                     onPressed: () {
//                       // Navigate to next year
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // Quarters Grid
//             Expanded(
//               child: GridView.count(
//                 padding: const EdgeInsets.all(16),
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.5,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//                 children: [
//                   _buildQuarterCard(
//                     context,
//                     1,
//                     'Q1',
//                     'Jan - Mar',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     2,
//                     'Q2',
//                     'Apr - Jun',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     3,
//                     'Q3',
//                     'Jul - Sep',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                   _buildQuarterCard(
//                     context,
//                     4,
//                     'Q4',
//                     'Oct - Dec',
//                     currentQuarter,
//                     currentYear,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuarterCard(
//     BuildContext context,
//     int quarter,
//     String title,
//     String subtitle,
//     int currentQuarter,
//     int year,
//   ) {
//     final isSelected = currentQuarter == quarter;

//     return Card(
//       elevation: isSelected ? 4 : 1,
//       color: isSelected
//           ? AppColors.primary.withOpacity(0.1)
//           : Theme.of(context).cardColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color: isSelected ? AppColors.primary : Colors.transparent,
//           width: 2,
//         ),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () {
//           final quarterMonth = (quarter - 1) * 3 + 1;
//           final selectedDate = DateTime(year, quarterMonth);
//           widget.viewModel.changePeriod(
//             'quarterly',
//             selectedDate: selectedDate,
//           );
//           Navigator.pop(context);
//         },
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: isSelected ? AppColors.primary : AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: isSelected
//                       ? AppColors.primary
//                       : AppColors.textSecondary,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               if (isSelected) ...[
//                 const SizedBox(height: 8),
//                 Icon(
//                   Icons.check_circle_rounded,
//                   color: AppColors.primary,
//                   size: 20,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods
//   String _formatDate(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   DateTime _getFirstDayOfWeek(DateTime date) {
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     final daysDiff = date.difference(firstDay).inDays;
//     return ((daysDiff + firstDay.weekday + 5) / 7).floor();
//   }

//   bool _isSameWeek(DateTime a, DateTime b) {
//     final aStart = _getFirstDayOfWeek(a);
//     final bStart = _getFirstDayOfWeek(b);
//     return aStart.difference(bStart).inDays == 0;
//   }

//   String _getCurrentWeekInfo() {
//     final now = widget.viewModel.selectedDate;
//     final weekStart = _getFirstDayOfWeek(now);
//     final weekEnd = weekStart.add(const Duration(days: 6));
//     return 'Week ${_getWeekNumber(now)} (${_formatDate(weekStart)} - ${_formatDate(weekEnd)})';
//   }
// }

// // import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// // import 'package:attendanceapp/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// // import 'package:flutter/material.dart';

// // class PeriodSelector extends StatelessWidget {
// //   final AttendanceAnalyticsViewModel viewModel;
// //   final List<String> periods = ['daily', 'weekly', 'monthly', 'yearly'];

// //   PeriodSelector({super.key, required this.viewModel});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(8),
// //       decoration: BoxDecoration(
// //         color: AppColors.grey100,
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //         children: periods.map((period) {
// //           final isSelected = viewModel.selectedPeriod == period;
// //           return Expanded(
// //             child: GestureDetector(
// //               onTap: () => viewModel.changePeriod(period),
// //               child: Container(
// //                 padding: const EdgeInsets.symmetric(vertical: 8),
// //                 decoration: BoxDecoration(
// //                   color: isSelected ? AppColors.primary : Colors.transparent,
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Text(
// //                   viewModel.getPeriodDisplayName(period),
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: isSelected
// //                         ? AppColors.white
// //                         : AppColors.textSecondary,
// //                     fontWeight: FontWeight.w600,
// //                     fontSize: 12,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// // }
