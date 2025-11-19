
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/dashboard_provider.dart';
import '../utils/app_styles.dart';
import '../utils/app_text.dart';
import '../widgets/date_time_utils.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final project = provider.selectedProject;

    if (project == null) {
      return const Scaffold(
        body: Center(
          child: Text(AppText.NoProject),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.name ?? "Project Details",
          style: const TextStyle(color: AppColors.textLight, fontSize: 16),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER (reduced padding + centered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      size: 40,
                      color: AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Project ID
                  Text(
                    "ID: ${project.id}",
                    style: AppStyles.id.copyWith(fontSize: 14),
                  ),

                  const SizedBox(height: 6),

                  // Project Name
                  Text(
                    project.name,
                    style: AppStyles.name.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Assigned Date (ONE LINE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        "Assigned: ${_formatDate(project.assignedDate)}",
                        style: AppStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // CONTENT AREA (reduced padding)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _buildDetailCard(
                    'Project Information',
                    [
                      _buildDetailRow(Icons.location_on, 'Project Site', project.site),
                      _buildDetailRow(Icons.access_time, 'Shift', project.shift),
                      _buildDetailRow(Icons.code, 'Tech Stack', project.techStack),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildDetailCard(
                    'Client Details',
                    [
                      _buildDetailRow(Icons.business, 'Client Name', project.clientName),
                      _buildDetailRow(Icons.phone, 'Client Contact', project.clientContact),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildDetailCard(
                    'Management',
                    [
                      _buildDetailRow(Icons.person, 'Manager Name', project.managerName ?? 'N/A'),
                      _buildDetailRow(Icons.email, 'Manager Email', project.managerEmail ?? 'N/A'),
                      _buildDetailRow(Icons.phone, 'Manager Contact', project.managerContact ?? 'N/A'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildDetailCard(
                    'Project Summary',
                    [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          project.description,
                          style: AppStyles.description.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card UI (reduced padding)
  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textHint.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: AppStyles.title.copyWith(fontSize: 15),
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  // Row UI (reduced spacing)
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4A90E2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppStyles.caption.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(value, style: AppStyles.label.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${DateTimeUtils.months[date.month - 1]} ${date.day}, ${date.year}';
  }

}
