
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class MonthSelectionDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMonthSelected;

  const MonthSelectionDrawer({
    super.key,
    required this.selectedIndex,
    required this.onMonthSelected,
  });

  String _getMonthLabel(int index) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - index, 1);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    int safeMonth = targetMonth.month - 1;
    if (safeMonth < 0) safeMonth += 12;

    return '${months[safeMonth]} ${targetMonth.year}';
  }

  String _getMonthSubLabel(int index) {
    if (index == 0) return 'Current Month';
    return '$index month${index > 1 ? 's' : ''} ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
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
          SizedBox(height: 20),
          Text(
            'Select Month',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => onMonthSelected(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),  // Reduced from 16
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getMonthLabel(index),
                          style: TextStyle(
                            fontSize: 13,  // Reduced from 14
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 2),  // Reduced from 4
                        Text(
                          _getMonthSubLabel(index),
                          style: TextStyle(
                            fontSize: 9,  // Reduced from 10
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade600,
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
