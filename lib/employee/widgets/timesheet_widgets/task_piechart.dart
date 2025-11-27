import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';

class TaskPieChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final String title;

  const TaskPieChartWidget({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppStyles.headingSmall1,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.info,
      AppColors.success,
      AppColors.grey600,
    ];

    int colorIndex = 0;
    return data.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

// Project Selection Widget
class ProjectSelectionWidget extends StatelessWidget {
  final String projectId;
  final String projectName;
  final bool isSelected;
  final VoidCallback onTap;

  const ProjectSelectionWidget({
    Key? key,
    required this.projectId,
    required this.projectName,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppDimensions.marginMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
          ),
        ),
        child: Text(
          projectName,
          style: AppStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.textLight : AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}