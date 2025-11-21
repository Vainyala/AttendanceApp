// widgets/attendance_views/project_view_widget.dart
import 'package:AttendanceApp/employee/providers/analytics_provider.dart';
import 'package:flutter/material.dart';
import '../../providers/dashboard_provider.dart';
import '../../screens/project_details_screen.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';

class ProjectViewWidget extends StatelessWidget {
  const ProjectViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Get projects from AppProvider
        final projects = provider.user?.projects ?? [];

        print('🔍 ProjectViewWidget - Projects count: ${projects.length}');

        if (projects.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: AppColors.textHint.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No projects available',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textHint.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Projects',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHint.shade800,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '(${projects.length})',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ...projects.map((project) => ActiveProjectCard(project: project)).toList(),
            ],
          ),
        );
      },
    );
  }
}

class ActiveProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ActiveProjectCard({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Get the analytics provider
        final analyticsProvider = context.read<AnalyticsProvider>();

        // Set the selected project with name
        analyticsProvider.setProjectId(project.id, projectName: project.name);
        analyticsProvider.setViewMode(ViewMode.all);

        // Pop back to attendance analytics screen
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.textLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              project.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.65,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '65%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}