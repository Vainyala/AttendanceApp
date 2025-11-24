import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:attendanceapp/manager/widgets/projectwidgets/add_project_dialog.dart';
import 'package:flutter/material.dart';

class AddProjectFAB extends StatelessWidget {
  const AddProjectFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const AddProjectDialog(),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      child: const Icon(Icons.add_rounded),
    );
  }
}
