import 'package:flutter/material.dart';

class MonthSelectionDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onMonthSelected;

  const MonthSelectionDrawer({
    super.key,
    required this.selectedIndex,
    required this.onMonthSelected,
  });

  @override
  State<MonthSelectionDrawer> createState() => _MonthSelectionDrawerState();
}

class _MonthSelectionDrawerState extends State<MonthSelectionDrawer> {
  late int _selectedMonthIndex;

  @override
  void initState() {
    super.initState();
    _selectedMonthIndex = widget.selectedIndex;
  }

  String _getMonthLabel(int index) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - index, 1);
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    int safeMonth = targetMonth.month - 1;
    if (safeMonth < 0) safeMonth += 12;
    return months[safeMonth];
  }

  String _getMonthButtonLabel(int index) {
    if (index == 0) return 'THIS MONTH';
    return '${index}M AGO';
  }

  String _getMonthFullName(int index) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - index, 1);
    const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    int safeMonth = targetMonth.month - 1;
    if (safeMonth < 0) safeMonth += 12;
    return '${months[safeMonth]} ${targetMonth.year}';
  }

  int _getMonthDays(int index) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - index, 1);
    final nextMonth = DateTime(targetMonth.year, targetMonth.month + 1, 1);
    return nextMonth.difference(targetMonth).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff2193e4),
            Color(0xff0976d1),
            Color(0xff024680),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SELECT MONTH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Last 3 months header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'LAST 3 MONTHS',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          SizedBox(height: 12),

          // Month buttons in row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(3, (index) {
                final isSelected = _selectedMonthIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedMonthIndex = index);
                      widget.onMonthSelected(index);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withOpacity(0.4)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getMonthButtonLabel(index),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _getMonthLabel(index),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 20),

          // Months list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3, // Show last 3 months
              itemBuilder: (context, index) {
                final isSelected = _selectedMonthIndex == index;
                final monthName = _getMonthFullName(index);
                final monthDays = _getMonthDays(index);

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedMonthIndex = index);
                    widget.onMonthSelected(index);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF2196f3).withOpacity(0.6),
                          Color(0xFF03a9f4).withOpacity(0.4),
                        ],
                      )
                          : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF2196f3).withOpacity(0.8)
                            : Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Month number badge
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Month info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                monthName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$monthDays days',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selected indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF00e5ff),
                            size: 24,
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white30,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}