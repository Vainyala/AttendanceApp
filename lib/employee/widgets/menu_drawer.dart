import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/attendance_history_screen.dart';
import '../screens/geofence_setup_screen.dart';
import '../screens/login_screen.dart';

void showProfileMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.textHint.shade50,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with user info
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.textLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textLight, width: 3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'John Doe',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'john.doe@company.com',
                          style: TextStyle(
                            color: AppColors.textLight.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Employee ID: EMP001',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Attendance Section
                  _sectionHeader('Attendance'),
                  _modernMenuCard(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Setup Geofences',
                    subtitle: 'Configure attendance locations',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GeofenceSetupScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _modernMenuCard(
                    context,
                    icon: Icons.history,
                    title: 'Attendance History',
                    subtitle: 'View past attendance records',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen(projects: [])),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Communication Section
                  _sectionHeader('Communication'),
                  _modernMenuCard(
                    context,
                    icon: Icons.campaign_outlined,
                    title: 'Notices',
                    subtitle: 'View company announcements',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      _showNoticesScreen(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _modernMenuCard(
                    context,
                    icon: Icons.report_problem_outlined,
                    title: 'Submit Grievance',
                    subtitle: 'Report issues or concerns',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      _showGrievanceDialog(context);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Support Section
                  _sectionHeader('Support & Settings'),
                  _modernMenuCard(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and FAQs',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(context);
                      _showHelpDialog(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _modernMenuCard(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    color: AppColors.textHint,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings coming soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _modernMenuCard(
                    context,
                    icon: Icons.info_outline,
                    title: 'About App',
                    subtitle: 'Version 1.0.0',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showLogoutConfirmation(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.shade50,
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.error.shade200),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _sectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textHint.shade600,
        letterSpacing: 1.2,
      ),
    ),
  );
}

Widget _modernMenuCard(
    BuildContext context, {
      required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap,
    }) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textHint.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textHint.shade400,
          ),
        ],
      ),
    ),
  );
}

// Notices Screen
void _showNoticesScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Notices'),
          backgroundColor: const Color(0xFF4A90E2),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.announcement, color: Color(0xFF4A90E2)),
                ),
                title: Text('Notice ${index + 1}: Important Update'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    const Text('Please check the new company policy regarding leaves...'),
                    const SizedBox(height: 4),
                    Text(
                      'Posted: ${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}/2025',
                      style: TextStyle(fontSize: 11, color: AppColors.textHint.shade600),
                    ),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Notice ${index + 1}'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'This is a detailed notice about the important update. '
                              'Please make sure to read and acknowledge this notice. '
                              'Contact HR for any questions or clarifications.',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    ),
  );
}

// Grievance Dialog
void _showGrievanceDialog(BuildContext context) {
  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedCategory = 'Work Environment';

  final categories = [
    'Work Environment',
    'Harassment',
    'Salary Issue',
    'Leave Issue',
    'Facility Issue',
    'Other',
  ];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.report_problem, color: AppColors.error.shade700),
          ),
          const SizedBox(width: 12),
          const Text('Submit Grievance'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your grievance will be handled confidentially',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: AppColors.textHint.shade50,
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) => selectedCategory = value!,
              ),
              const SizedBox(height: 16),
              const Text(
                'Subject',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: subjectController,
                decoration: InputDecoration(
                  hintText: 'Brief summary of your concern',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: AppColors.textHint.shade50,
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Subject is required' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe your concern in detail...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: AppColors.textHint.shade50,
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Description is required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grievance submitted. HR will contact you within 24 hours.'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Submit Grievance'),
        ),
      ],
    ),
  );
}

// Help Dialog
void _showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Help & Support'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _helpItem('📧 Email', 'support@company.com'),
            _helpItem('📞 Phone', '+91 1800-XXX-XXXX'),
            _helpItem('⏰ Support Hours', 'Mon-Fri, 9 AM - 6 PM'),
            const Divider(height: 24),
            const Text('FAQs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _faqItem('How to apply for leave?', 'Go to Leave section → Fill the form → Submit'),
            _faqItem('How to mark attendance?', 'Be within geofence area → Tap Check In/Out'),
            _faqItem('How to view salary slip?', 'Coming soon in next update'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _helpItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          flex: 3,
          child: Text(value, style: const TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}

Widget _faqItem(String question, String answer) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Q: $question', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        Text('A: $answer', style: TextStyle(fontSize: 13, color: AppColors.textHint.shade700)),
      ],
    ),
  );
}

// About Dialog
void _showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('About App'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.business, size: 40, color: Color(0xFF4A90E2)),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Attendance Manager',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Version 1.0.0 (Build 1)',
              style: TextStyle(color: AppColors.textHint.shade600, fontSize: 13),
            ),
          ),
          const Divider(height: 32),
          _infoRow('Developer', 'Your Company Name'),
          _infoRow('Released', 'October 2025'),
          _infoRow('Platform', 'Android & iOS'),
          const SizedBox(height: 16),
          Text(
            '© 2025 Company. All rights reserved.',
            style: TextStyle(fontSize: 11, color: AppColors.textHint.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    ),
  );
}

// Logout Confirmation
void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Clear any user session data here if needed

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // removes all previous routes
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged out successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          },

          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}