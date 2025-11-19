import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class QuarterSelectionDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onQuarterSelected;

  const QuarterSelectionDrawer({
    super.key,
    required this.selectedIndex,
    required this.onQuarterSelected,
  });

  @override
  State<QuarterSelectionDrawer> createState() => _QuarterSelectionDrawerState();
}

class _QuarterSelectionDrawerState extends State<QuarterSelectionDrawer> {
  late int _selectedQuarterIndex;

  @override
  void initState() {
    super.initState();
    _selectedQuarterIndex = widget.selectedIndex;
  }

  String _getQuarterLabel(int quarterNum) {
    return 'Q$quarterNum';
  }
  String _getQuarterButtonLabel(int index) {
    if (index == 0) return 'THIS Quarter';
    return '${index}Q AGO';
  }

  String _getQuarterMonths(int quarterNum) {
    const quarterMonths = {
      1: 'JAN - MAR',
      2: 'APR - JUN',
      3: 'JUL - SEP',
      4: 'OCT - DEC',
    };
    return quarterMonths[quarterNum] ?? '';
  }

  int _getCurrentQuarter() {
    final now = DateTime.now();
    return ((now.month - 1) ~/ 3) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuarter = _getCurrentQuarter();

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily',
                      style: TextStyle(
                        color: AppColors.cardBackground,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'SELECT QUARTER',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textLight,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'LAST 2 QUARTER',
              style: TextStyle(
                color: AppColors.cardBackground,
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
              children: List.generate(2, (index) {
                final isSelected = _selectedQuarterIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedQuarterIndex = index);
                      widget.onQuarterSelected(index);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.textLight.withOpacity(0.2)
                            : AppColors.textLight.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textLight.withOpacity(0.4)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getQuarterButtonLabel(index),
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _getQuarterLabel(index),
                            style: TextStyle(
                              color: AppColors.cardBackground,
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

          SizedBox(height: 5),

          // Quarter list - Only 2 quarters
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: List.generate(2, (index) {
                  final quarterNum = index + 1;
                  final isCurrentQuarter = quarterNum == currentQuarter;
                  final isSelected = _selectedQuarterIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedQuarterIndex = index);
                      widget.onQuarterSelected(index);
                    },
                    child: Container(
                      height: 90, // Smaller height
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        color: isSelected ? null : AppColors.textLight.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF2196f3).withOpacity(0.8)
                              : AppColors.textLight.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Quarter badge
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.textLight.withOpacity(0.25)
                                  : AppColors.textLight.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _getQuarterLabel(quarterNum),
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 20),

                          // Quarter info
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QUARTER ${quarterNum}',
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _getQuarterMonths(quarterNum),
                                  style: TextStyle(
                                    color: AppColors.cardBackground,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
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
                              color:AppColors.textDark,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

        ],
      ),
    );
  }
}