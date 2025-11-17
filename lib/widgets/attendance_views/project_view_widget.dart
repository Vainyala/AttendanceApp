// widgets/attendance_views/project_view_widget.dart
import 'package:AttendanceApp/widgets/attendance_views/project_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../screens/project_details_screen.dart';
import '../../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';

class ProjectViewWidget extends StatelessWidget {
  const ProjectViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        final projects = provider.employeeProjects;

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
                      color: AppColors.textHint.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '(${projects.length})',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
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
  final Map<String, dynamic> project;

  const ActiveProjectCard({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AppProvider>().setSelectedProject(ProjectModel.fromJson(project));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailsScreen(),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.textHint.shade800,
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
                    project['name'] ?? 'Project Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
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
                    project['status'] ?? 'ACTIVE',
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
              _getProjectDescription(project['name']),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint.shade400,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint.shade400,
              ),
            ),
            SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (project['progress'] ?? 0) / 100,
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
              '${project['progress'] ?? 0}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProjectDescription(String? projectName) {
    final descriptions = {
      'E-Commerce Platform': 'Development of new e-commerce platform with modern features',
      'Mobile App Redesign': 'Redesign of customer mobile application with new UI/UX',
      'Banking System Upgrade': 'Modernization of legacy banking system with enhanced security',
    };
    return descriptions[projectName] ?? 'Project description not available';
  }

}