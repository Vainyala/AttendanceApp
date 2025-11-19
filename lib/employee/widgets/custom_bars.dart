import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/dashboard_screen.dart';
import '../screens/regularisation_screen.dart';
import '../screens/leave_screen.dart';
import '../screens/timesheet_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  void _onItemTapped(int index) {
    if (index == currentIndex) return; // Don't navigate if already on the same page

    switch (index) {
      case 0:
        _navigateToScreen(const DashboardScreen());
        break;
      case 1:
        _navigateToScreen(const RegularisationScreen());
        break;
      case 2:
        _navigateToScreen(const LeaveScreen());
        break;
      case 3:
        _navigateToScreen(const TimesheetScreen());
        break;
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.textHint.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: AppColors.textHint.shade600,
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        elevation: 0,
        backgroundColor: AppColors.textLight,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          _buildNavItem(Icons.dashboard, 'Dashboard', 0),
          _buildNavItem(Icons.description, 'Regularisation', 1),
          _buildNavItem(Icons.calendar_today, 'Leave', 2),
          _buildNavItem(Icons.timer_outlined, 'Timesheet', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(
          icon,
          size: isSelected ? 26 : 24,
        ),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90E2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 26,
          color: const Color(0xFF4A90E2),
        ),
      ),
      label: label,
    );
  }
}

// Helper widget to wrap screens with bottom navigation
class ScreenWithBottomNav extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ScreenWithBottomNav({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        context: context,
      ),
    );
  }
}