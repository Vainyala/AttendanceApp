import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class ProjectDropdown extends StatelessWidget {
  final String? selectedProjectId;
  final List<Map<String, String>> projects;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const ProjectDropdown({
    Key? key,
    required this.selectedProjectId,
    required this.projects,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedProjectId,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.work_outline,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: projects.map((project) {
            return DropdownMenuItem(
              value: project['id'],
              child: Text(
                '${project['name']} (${project['id']})',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a project';
            }
            return null;
          },
        ),
      ],
    );
  }
}