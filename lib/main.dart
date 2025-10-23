import 'package:AttendanceApp/providers/attendance_provider.dart';
import 'package:AttendanceApp/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'providers/dashboard_provider.dart';
import 'providers/regularisation_provider.dart';
import 'providers/splash_provider.dart';
import 'services/notification_service.dart';
import 'services/geofencing_service.dart';
import 'screens/splash_screen.dart';

// Global cameras list to avoid repeated initialization
late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize cameras once at app startup
    cameras = await availableCameras();
    debugPrint("✅ Cameras initialized: ${cameras.length} camera(s) found");

    for (var i = 0; i < cameras.length; i++) {
      debugPrint("Camera $i: ${cameras[i].name} - ${cameras[i].lensDirection}");
    }
  } catch (e) {
    debugPrint("❌ Error initializing cameras: $e");
    cameras = []; // Empty list if camera initialization fails
  }

  // Initialize services
  try {
    await NotificationService.initialize();
    debugPrint("✅ Notification service initialized");
  } catch (e) {
    debugPrint("❌ Error initializing notifications: $e");
  }

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
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => RegularisationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),

      ],
      child: MaterialApp(
        title: 'Attendance App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}