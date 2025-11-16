import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../providers/attendance_details_provider.dart';
import '../utils/app_colors.dart';

// Period Tabs Widget
class PeriodTabsWidget extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodTabsWidget({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab('Daily', 'daily'),
          _buildTab('Weekly', 'weekly'),
          _buildTab('Monthly', 'monthly'),
          _buildTab('Quarterly', 'quarterly'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPeriodChanged(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.textLight : AppColors.textHint.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}