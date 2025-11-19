
import 'package:flutter/material.dart';

import '../../core/view_models/theme_view_model.dart';
import 'add_project_dialog.dart';

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
