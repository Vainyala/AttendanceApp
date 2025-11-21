// providers/manager_regularisation_provider.dart
import 'package:AttendanceApp/manager/services/projectservices/project_service.dart';
import 'package:flutter/material.dart';

import '../services/regularisationservices/manager_regularisation_service.dart';
import '../view_models/regularisationviewmodel/manager_regularisation_view_model.dart';

class ManagerRegularisationProvider extends InheritedWidget {
  final ManagerRegularisationViewModel viewModel;

  const ManagerRegularisationProvider({
    Key? key,
    required this.viewModel,
    required Widget child,
  }) : super(key: key, child: child);

  static ManagerRegularisationViewModel of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ManagerRegularisationProvider>()!
        .viewModel;
  }

  @override
  bool updateShouldNotify(ManagerRegularisationProvider oldWidget) {
    return true;
  }

  // ✅ UPDATED: Add ProjectService to create method
  static Widget create({required Widget child}) {
    return ManagerRegularisationProvider(
      viewModel: ManagerRegularisationViewModel(
        ManagerRegularisationService(),
        ProjectService(), // ✅ Add ProjectService here
      ),
      child: child,
    );
  }
}
