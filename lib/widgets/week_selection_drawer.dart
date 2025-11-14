import 'package:flutter/material.dart';

class WeekSelectionDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onWeekSelected;

  const WeekSelectionDrawer({
    super.key,
    required this.selectedIndex,
    required this.onWeekSelected,
  });

  @override
  State<WeekSelectionDrawer> createState() => _WeekSelectionDrawerState();
}

class _WeekSelectionDrawerState extends State<WeekSelectionDrawer> {
  late int _selectedWeekIndex;

  @override
  void initState() {
    super.initState();
    _selectedWeekIndex = widget.selectedIndex;
  }

  String _getWeekRange(int index) {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: 7 * index));
    final weekStart = targetDate.subtract(Duration(days: targetDate.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${weekStart.day} ${_getMonthName(weekStart.month)} ${weekStart.year} - ${weekEnd.day} ${_getMonthName(weekEnd.month)} ${weekEnd.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getWeekLabel(int index) {
    if (index == 0) return 'THIS WEEK';
    return '${index}W AGO';
  }

  int _getWeekNumber(int index) {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: 7 * index));
    final weekNumber = ((targetDate.difference(DateTime(targetDate.year, 1, 1)).inDays) / 7).ceil();
    return weekNumber;
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
                  'SELECT WEEK',
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

          // Last 4 weeks header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'LAST 4 WEEKS',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          SizedBox(height: 12),

          // Week buttons in row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(4, (index) {
                final isSelected = _selectedWeekIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedWeekIndex = index);
                      widget.onWeekSelected(index);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
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
                            _getWeekLabel(index),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${_getWeekNumber(index)}',
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

          // Weeks list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4, // Show only last 4 weeks (current week + last 3 weeks)
              itemBuilder: (context, index) {
                final isSelected = _selectedWeekIndex == index;
                final weekNum = _getWeekNumber(index);
                final weekRange = _getWeekRange(index);

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedWeekIndex = index);
                    widget.onWeekSelected(index);
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
                        // Week number badge
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
                              '$weekNum',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Week info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WEEK $weekNum',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                weekRange,
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