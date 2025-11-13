
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class QuarterSelectionDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onQuarterSelected;

  const QuarterSelectionDrawer({
    super.key,
    required this.selectedIndex,
    required this.onQuarterSelected,
  });

  String _getQuarterLabel(int index) {
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    final targetQuarter = currentQuarter - index;
    final year = targetQuarter > 0 ? now.year : now.year - 1;
    final quarter = targetQuarter > 0 ? targetQuarter : 4 + targetQuarter;

    return 'Q$quarter $year';
  }

  String _getQuarterMonths(int index) {
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    final targetQuarter = currentQuarter - index;
    final quarter = targetQuarter > 0 ? targetQuarter : 4 + targetQuarter;

    const quarterMonths = {
      1: 'Jan-Mar',
      2: 'Apr-Jun',
      3: 'Jul-Sep',
      4: 'Oct-Dec',
    };

    return quarterMonths[quarter] ?? '';
  }

  String _getQuarterSubLabel(int index) {
    if (index == 0) return 'Current Quarter';
    return '$index quarter${index > 1 ? 's' : ''} ago';
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
            'Select Quarter',
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
                childAspectRatio: 2.0,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => onQuarterSelected(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),  // Reduced from 12
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
                          _getQuarterLabel(index),
                          style: TextStyle(
                            fontSize: 13,  // Reduced from 14
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 1),  // Reduced from 2
                        Text(
                          _getQuarterMonths(index),
                          style: TextStyle(
                            fontSize: 10,  // Reduced from 11
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 1),  // Reduced from 2
                        Text(
                          _getQuarterSubLabel(index),
                          style: TextStyle(
                            fontSize: 8,  // Reduced from 9
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
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