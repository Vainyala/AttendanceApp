// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:camera/camera.dart';
// import 'employee/providers/analytics_provider.dart';
// import 'employee/providers/attendance_details_provider.dart';
// import 'employee/providers/attendance_provider.dart';
// import 'employee/providers/auth_provider.dart';
// import 'employee/providers/dashboard_provider.dart';
// import 'employee/providers/regularisation_provider.dart';
// import 'employee/providers/splash_provider.dart';
// import 'employee/screens/splash_screen.dart';
// import 'employee/services/geofencing_service.dart';
// import 'employee/services/notification_service.dart';
//
// // Global cameras list
// late List<CameraDescription> cameras;
//
// class EmployeeApp extends StatefulWidget {
//   const EmployeeApp({super.key});
//
//   @override
//   State<EmployeeApp> createState() => _EmployeeAppState();
// }
//
// class _EmployeeAppState extends State<EmployeeApp> {
//   bool _isInitialized = false;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }
//
//   Future<void> _initializeServices() async {
//     try {
//       debugPrint("🟢 Initializing Employee Services...");
//
//       // Initialize cameras
//       cameras = await availableCameras();
//       debugPrint("✅ Cameras initialized: ${cameras.length} camera(s) found");
//
//       // Initialize notification service
//       await NotificationService.initialize();
//       debugPrint("✅ Notification service initialized");
//
//       // Initialize geofencing service
//       await GeofencingService.initialize();
//       debugPrint("✅ Geofencing service initialized");
//
//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (e) {
//       debugPrint("❌ Employee services initialization error: $e");
//       setState(() {
//         _isInitialized = true;
//         _errorMessage = e.toString();
//       });
//       cameras = [];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return MaterialApp(
//         home: Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const CircularProgressIndicator(),
//                 const SizedBox(height: 16),
//                 const Text('Initializing Employee Services...'),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => SplashProvider()),
//         ChangeNotifierProvider(create: (_) => AppProvider()),
//         ChangeNotifierProvider(create: (_) => RegularisationProvider()),
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => AttendanceProvider()),
//         ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
//         ChangeNotifierProvider(create: (_) => AttendanceDetailsProvider()),
//       ],
//       child: MaterialApp(
//         title: 'Employee Attendance',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           useMaterial3: true,
//         ),
//         home: _errorMessage != null
//             ? Scaffold(
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error, size: 48, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Initialization Error',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Text(
//                     _errorMessage!,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         )
//             : const SplashScreen(),
//         debugShowCheckedModeBanner: false,
//       ),
//     );
//   }
// }