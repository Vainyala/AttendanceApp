import '../services/custom_bars.dart';
import 'package:flutter/material.dart';

class TimesheetScreen extends StatelessWidget {
  const TimesheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWithBottomNav(
      currentIndex: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 80,
                color: Color(0xFF4A90E2),
              ),
              SizedBox(height: 20),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Access via bottom menu',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}