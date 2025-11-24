import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/view_models/projectviewmodels/project_view_model.dart';
import 'package:flutter/material.dart';

class ViewSelectorCards extends StatelessWidget {
  final ProjectViewModel viewModel;

  const ViewSelectorCards({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildViewCard(
            'Projects',
            Icons.work_rounded,
            AppColors.primary,
            'projects',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildViewCard(
            'Attendance',
            Icons.assignment_turned_in_rounded,
            AppColors.success,
            'attendance',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildViewCard(
            'Employees',
            Icons.people_alt_rounded,
            AppColors.info,
            'employees',
          ),
        ),
      ],
    );
  }

  Widget _buildViewCard(String title, IconData icon, Color color, String view) {
    final isSelected = viewModel.selectedView == view;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => viewModel.changeView(view),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
