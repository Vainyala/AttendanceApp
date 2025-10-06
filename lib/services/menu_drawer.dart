import 'package:flutter/material.dart';
import '../screens/attendance_history_screen.dart';
import '../screens/geofence_setup_screen.dart';

void showProfileMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _menuTile(
                    context,
                    icon: Icons.add_location,
                    title: 'Setup Geofences',
                    subtitle: 'Configure attendance locations',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GeofenceSetupScreen()),
                      );
                    },
                  ),
                  _menuTile(
                    context,
                    icon: Icons.history,
                    title: 'Attendance History',
                    subtitle: 'View past attendance records',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen(projects: [])),
                      );
                    },
                  ),
                  _menuTile(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences and configuration',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings coming soon')),
                      );
                    },
                  ),
                  _menuTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & Support coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 30),
                  _menuTile(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logout action here')),
                      );
                    },
                    isDestructive: true,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _menuTile(
    BuildContext context, {
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      bool isDestructive = false,
    }) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDestructive ? Colors.red.shade50 : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: isDestructive ? Colors.red : Colors.blue, size: 20),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isDestructive ? Colors.red : Colors.black87,
      ),
    ),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
  );
}
