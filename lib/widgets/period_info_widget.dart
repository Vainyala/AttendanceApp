import 'dart:ui';
import 'package:flutter/material.dart';
class PeriodInfoWidget extends StatelessWidget {
  final String periodType;
  final String dateRange;

  const PeriodInfoWidget({
    super.key,
    required this.periodType,
    required this.dateRange,
  });

  String get _title {
    switch (periodType) {
      case 'daily':
        return 'Daily Employee Detail';
      case 'weekly':
        return 'Weekly Employee Detail';
      case 'monthly':
        return 'Monthly Employee Detail';
      case 'quarterly':
        return 'Quarterly Employee Detail';
      default:
        return 'Employee Detail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            dateRange,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}