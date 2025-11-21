// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'manager/core/services/navigation_service.dart';
// import 'manager/core/view_models/button_view_model.dart';
// import 'manager/core/view_models/common_view_model.dart';
// import 'manager/core/view_models/theme_view_model.dart';
// import 'manager/provider/dashboard_state_manager.dart';
// import 'manager/services/projectservices/project_service.dart';
// import 'manager/services/regularisationservices/manager_regularisation_service.dart';
// import 'manager/view_models/attendanceviewmodels/attendance_analytics_view_model.dart';
// import 'manager/view_models/auth_view_model.dart';
// import 'manager/view_models/employeeviewmodels/employee_details_view_model.dart';
// import 'manager/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'manager/view_models/projectviewmodels/project_analytics_view_model.dart';
// import 'manager/view_models/projectviewmodels/project_view_model.dart';
// import 'manager/view_models/regularisationviewmodel/manager_regularisation_view_model.dart';
// import 'manager/view_models/regularisationviewmodel/regularisation_view_model.dart';
// import 'manager/views/employeeviews/employee_dashboard.dart';
// import 'manager/views/financeviews/finance_dashboard_screen.dart';
// import 'manager/views/hrviews/hrdashboard_screen.dart';
// import 'manager/views/login_screen.dart';
// import 'manager/views/managerviews/manager_dashboard_screen.dart';
//
// class ManagerApp extends StatelessWidget {
//   const ManagerApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Core ViewModels
//         ChangeNotifierProvider(create: (_) => AppTheme()),
//         ChangeNotifierProvider(create: (_) => ButtonState()),
//         ChangeNotifierProvider(create: (_) => CommonState()),
//
//         // Services
//         Provider(create: (_) => ProjectService()),
//
//         // Feature ViewModels
//         ChangeNotifierProvider(create: (_) => AuthViewModel()),
//         ChangeNotifierProvider(create: (_) => ManagerDashboardViewModel()),
//         ChangeNotifierProvider(create: (_) => DashboardStateManager()),
//         ChangeNotifierProvider(create: (_) => AttendanceAnalyticsViewModel()),
//         ChangeNotifierProvider(create: (_) => EmployeeDetailsViewModel()),
//         ChangeNotifierProvider(create: (_) => ProjectViewModel()),
//         ChangeNotifierProvider(create: (_) => ProjectAnalyticsViewModel()),
//         ChangeNotifierProvider(create: (context) => RegularisationViewModel()),
//         ChangeNotifierProvider(
//           create: (context) => ManagerRegularisationViewModel(
//             ManagerRegularisationService(),
//             context.read<ProjectService>(),
//           ),
//         ),
//       ],
//       child: Consumer<AppTheme>(
//         builder: (context, theme, child) {
//           return MaterialApp(
//             title: 'Manager Dashboard',
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: theme.themeMode,
//             home: const LoginScreen(),
//             debugShowCheckedModeBanner: false,
//             navigatorKey: NavigationService().navigatorKey,
//             routes: {
//               '/login': (context) => const LoginScreen(),
//               '/manager_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return ManagerDashboardScreen(user: authViewModel.currentUser!);
//               },
//               '/employee_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return EmployeeDashboardScreen(user: authViewModel.currentUser!);
//               },
//               '/hr_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return HRDashboardScreen(user: authViewModel.currentUser!);
//               },
//               '/finance_dashboard': (context) {
//                 final authViewModel = Provider.of<AuthViewModel>(
//                   context,
//                   listen: false,
//                 );
//                 if (authViewModel.currentUser == null) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     Navigator.pushReplacementNamed(context, '/login');
//                   });
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 return FinanceDashboardScreen(user: authViewModel.currentUser!);
//               },
//             },
//           );
//         },
//       ),
//     );
//   }
// }