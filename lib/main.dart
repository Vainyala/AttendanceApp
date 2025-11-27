import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

// Employee App Imports
import 'employee/providers/analytics_provider.dart';
import 'employee/providers/attendance_details_provider.dart';
import 'employee/providers/attendance_provider.dart';
import 'employee/providers/auth_provider.dart';
import 'employee/providers/dashboard_provider.dart';
import 'employee/providers/leave_provider.dart';
import 'employee/providers/regularisation_provider.dart';
import 'employee/providers/splash_provider.dart';
import 'employee/providers/timesheet_provider.dart';
import 'employee/screens/dashboard_screen.dart';
import 'employee/screens/splash_screen.dart';
import 'employee/services/geofencing_service.dart';
import 'employee/services/notification_service.dart';

// Manager App Imports
import 'manager/core/services/navigation_service.dart';
import 'manager/core/view_models/button_view_model.dart';
import 'manager/core/view_models/common_view_model.dart';
import 'manager/core/view_models/theme_view_model.dart';
import 'manager/provider/dashboard_state_manager.dart';
import 'manager/services/projectservices/project_service.dart';
import 'manager/services/regularisationservices/manager_regularisation_service.dart';
import 'manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'manager/view_models/auth_view_model.dart';
import 'manager/view_models/employeeviewmodels/employee_details_view_model.dart';
import 'manager/view_models/leaveviewmodels/leave_view_model.dart';
import 'manager/view_models/managerviewmodels/manager_dashboard_view_model.dart';
import 'manager/view_models/projectviewmodels/project_analytics_view_model.dart';
import 'manager/view_models/projectviewmodels/project_view_model.dart';
import 'manager/view_models/regularisationviewmodel/manager_regularisation_view_model.dart';
import 'manager/view_models/regularisationviewmodel/regularisation_view_model.dart';
import 'manager/views/managerviews/manager_dashboard_screen.dart';

import 'role_selection_screen.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
    debugPrint("✅ Cameras initialized: ${cameras.length} camera(s) found");
  } catch (e) {
    debugPrint("❌ Error initializing cameras: $e");
    cameras = [];
  }

  try {
    await NotificationService.initialize();
    await GeofencingService.initialize();
    debugPrint("✅ Services initialized");
  } catch (e) {
    debugPrint("❌ Error initializing services: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Employee Providers
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => RegularisationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceDetailsProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => TimesheetProvider()),

        // Manager Providers
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => ButtonState()),
        ChangeNotifierProvider(create: (_) => CommonState()),
        Provider(create: (_) => ProjectService()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ManagerDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardStateManager()),
        ChangeNotifierProvider(create: (_) => AttendanceAnalyticsViewModel()),
        ChangeNotifierProvider(create: (_) => EmployeeDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectAnalyticsViewModel()),
        ChangeNotifierProvider(create: (_) => LeaveViewModel()),
        ChangeNotifierProvider(create: (context) => RegularisationViewModel()),
        ChangeNotifierProvider(
          create: (context) => ManagerRegularisationViewModel(
            ManagerRegularisationService(),
            context.read<ProjectService>(),
          ),
        ),
      ],
      child: Consumer<AppTheme>(
        builder: (context, theme, child) {
          return MaterialApp(
            title: 'Attendance Management System',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService().navigatorKey,
            routes: {
              '/employee': (context) => const DashboardScreen(),
              '/manager': (context) {
                final auth = Provider.of<AuthViewModel>(context, listen: false);
                if (auth.currentUser == null) {
                  return Scaffold(
                    body: Center(child: Text("No manager user found")),
                  );
                }
                return ManagerDashboardScreen(user: auth.currentUser!);
              },
            },
          );
        },
      ),
    );
  }
}


