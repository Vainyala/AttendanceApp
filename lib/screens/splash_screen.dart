import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/splash_provider.dart';
import 'email_verification_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SplashProvider>(context, listen: false);
    provider.checkLoginStatus().then((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => provider.isFirstLaunch
                ? const EmailVerificationScreen() // 👈 go to email verification if first time
                : provider.isLoggedIn
                ? const DashboardScreen()
                : const LoginScreen(),
          ),
        );

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SplashProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A5AE8), Color(0xFF6C7CE7)],
          ),
        ),
        child: Center(
          child: provider.isLoading
              ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Geofence Attendance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Smart Location-Based Attendance',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
