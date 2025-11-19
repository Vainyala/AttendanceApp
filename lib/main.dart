import 'package:AttendanceApp/role_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

// Employee App Imports (YOUR APP)

import 'employee/providers/analytics_provider.dart';
import 'employee/providers/attendance_details_provider.dart';
import 'employee/providers/attendance_provider.dart';
import 'employee/providers/auth_provider.dart';
import 'employee/providers/dashboard_provider.dart';
import 'employee/providers/regularisation_provider.dart';
import 'employee/providers/splash_provider.dart';
import 'employee/screens/dashboard_screen.dart';
import 'employee/screens/splash_screen.dart';
import 'employee/services/geofencing_service.dart';
import 'employee/services/notification_service.dart';
import 'manager/core/services/navigation_service.dart';
import 'manager/core/view_models/button_view_model.dart';
import 'manager/core/view_models/common_view_model.dart';
import 'manager/core/view_models/theme_view_model.dart';
import 'manager/provider/dashboard_state_manager.dart';
import 'manager/services/managerservices/project_service.dart';
import 'manager/services/regularisationservices/manager_regularisation_service.dart';
import 'manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
import 'manager/view_models/auth_view_model.dart';
import 'manager/view_models/employeeviewmodels/employee_details_view_model.dart';
import 'manager/view_models/managerviewmodels/manager_dashboard_view_model.dart';
import 'manager/view_models/projectviewmodels/project_analytics_view_model.dart';
import 'manager/view_models/projectviewmodels/project_view_model.dart';
import 'manager/view_models/regularisationviewmodel/manager_regularisation_view_model.dart';
import 'manager/view_models/regularisationviewmodel/regularisation_view_model.dart';
import 'manager/views/financeviews/finance_dashboard_screen.dart';
import 'manager/views/hrviews/hrdashboard_screen.dart';
import 'manager/views/managerviews/manager_dashboard_screen.dart';

// Global cameras list for employee module
late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cameras for employee module
  try {
    cameras = await availableCameras();
    debugPrint("✅ Cameras initialized: ${cameras.length} camera(s) found");
    for (var i = 0; i < cameras.length; i++) {
      debugPrint("Camera $i: ${cameras[i].name} - ${cameras[i].lensDirection}");
    }
  } catch (e) {
    debugPrint("❌ Error initializing cameras: $e");
    cameras = [];
  }

  // Initialize notification service
  try {
    await NotificationService.initialize();
    debugPrint("✅ Notification service initialized");
  } catch (e) {
    debugPrint("❌ Error initializing notifications: $e");
  }

  // Initialize geofencing service
  try {
    await GeofencingService.initialize();
    debugPrint("✅ Geofencing service initialized");
  } catch (e) {
    debugPrint("❌ Error initializing geofencing: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Employee Module Providers (YOUR APP)
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => RegularisationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceDetailsProvider()),

        // Manager Module - Core ViewModels (COLLEAGUE'S APP)
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => ButtonState()),
        ChangeNotifierProvider(create: (_) => CommonState()),

        // Manager Module - Services
        Provider(create: (_) => ProjectService()),

        // Manager Module - Feature ViewModels
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ManagerDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardStateManager()),
        ChangeNotifierProvider(create: (_) => AttendanceAnalyticsViewModel()),
        ChangeNotifierProvider(create: (_) => EmployeeDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectAnalyticsViewModel()),
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
            // Start with YOUR splash screen
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService().navigatorKey,
            routes: {
              // Your Employee Flow Routes
              '/role_selection': (context) => const RoleSelectionScreen(),
              '/employee_dashboard': (context) => const DashboardScreen(), // Your employee dashboard

              // Manager Module Routes (Colleague's Dashboards)
              '/manager_dashboard': (context) {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                // Create a dummy user if needed, or handle authentication properly
                return ManagerDashboardScreen(
                  user: authViewModel.currentUser ?? _createDummyUser('Manager'),
                );
              },
              '/hr_dashboard': (context) {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                return HRDashboardScreen(
                  user: authViewModel.currentUser ?? _createDummyUser('HR'),
                );
              },
              '/finance_dashboard': (context) {
                final authViewModel = Provider.of<AuthViewModel>(
                  context,
                  listen: false,
                );
                return FinanceDashboardScreen(
                  user: authViewModel.currentUser ?? _createDummyUser('Finance'),
                );
              },
            },
          );
        },
      ),
    );
  }

  // Helper function to create dummy user if AuthViewModel doesn't have currentUser
  // Replace this with proper user object from your colleague's code
  static dynamic _createDummyUser(String role) {
    // You'll need to import the User model from colleague's code
    // This is a placeholder - adjust according to colleague's User model
    return null; // Replace with: User(id: '1', name: 'User', role: role, ...)
  }
}