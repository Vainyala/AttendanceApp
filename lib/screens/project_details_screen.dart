import 'package:AttendenceApp/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/dashboard_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text.dart';

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
          style: const TextStyle(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      size: 50,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    project.name,
                    style: AppStyles.name,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${project.id}',
                    style: AppStyles.id,
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDetailCard(
                    'Project Information',
                    [
                      _buildDetailRow(Icons.location_on, 'Site', project.site),
                      _buildDetailRow(Icons.access_time, 'Shift', project.shift),
                      _buildDetailRow(Icons.code, 'Tech Stack', project.techStack),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildDetailCard(
                    'Client Details',
                    [
                      _buildDetailRow(Icons.business, 'Client Name', project.clientName),
                      _buildDetailRow(Icons.phone, 'Contact', project.clientContact),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildDetailCard(
                    'Management',
                    [
                      _buildDetailRow(Icons.person, 'Manager', project.manager ?? 'N/A'),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Assigned Date',
                        _formatDate(project.assignedDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildDetailCard(
                    'Description',
                    [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          project.description,
                          style: AppStyles.description
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(AppText.BackDash,
                        style: AppStyles.heading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey700.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              title,
              style: AppStyles.title,
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4A90E2)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppStyles.caption,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: AppStyles.label,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
