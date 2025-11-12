import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';
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

    final weekStart = targetDate.subtract(
      Duration(days: targetDate.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
  }

  String _getWeekLabel(int index) {
    if (index == 0) return 'Current Week';
    return 'Week $index ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final isSelected = _selectedWeekIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedWeekIndex = index);
                    widget.onWeekSelected(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ), // Reduced from 16

                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : Colors.white,

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.grey.shade300,

                        width: 2,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),

                          blurRadius: 8,

                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          _getWeekLabel(index),

                          style: TextStyle(
                            fontSize: 11, // Reduced from 12

                            fontWeight: FontWeight.bold,

                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 2), // Reduced from 4

                        Text(
                          _getWeekRange(index),

                          style: TextStyle(
                            fontSize: 10, // Reduced from 11

                            fontWeight: FontWeight.w500,

                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : Colors.grey.shade600,
                          ),
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
