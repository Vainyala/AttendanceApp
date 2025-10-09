import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Image
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(Icons.camera_alt, size: 18, color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Name
                  const Text(
                    'Vainyala Samal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Role
                  const Text(
                    'Flutter Developer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Company
                  const Text(
                    'Nutantek Solutions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // RM Details Section
            _buildSection(
              title: 'RM Details',
              children: [
                _buildInfoTile(
                  icon: Icons.person_outline,
                  label: 'RM Name',
                  value: 'Suresh Gupta',
                  isEditable: false,
                ),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'RM Number',
                  value: '+91-9876543210',
                  isEditable: false,
                  onTap: () => _makePhoneCall(context, '+91-9876543210'),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // My Details Section
            _buildSection(
              title: 'My Details',
              children: [
                _buildInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Employee Code',
                  value: 'NS052',
                  isEditable: false,
                ),
                _buildInfoTile(
                  icon: Icons.wc_outlined,
                  label: 'Gender',
                  value: 'Male',
                  isEditable: false,
                ),
                _buildInfoTile(
                  icon: Icons.favorite_outline,
                  label: 'Marital Status',
                  value: 'Unmarried',
                  isEditable: false,
                ),
                _buildInfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Date Of Birth',
                  value: '25/10/1998',
                  isEditable: false,
                ),
                _buildInfoTile(
                  icon: Icons.event_outlined,
                  label: 'Date Of Joining',
                  value: '10/09/2019',
                  isEditable: false,
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Contact Details Section (Editable)
            _buildSection(
              title: 'Contact Details',
              children: [
                Consumer<ProfileProvider>(
                  builder: (context, provider, _) => _buildInfoTile(
                    icon: Icons.phone_android_outlined,
                    label: 'Mobile Number',
                    value: provider.phoneNumber,
                    isEditable: true,
                    onEdit: () => _editField(context, 'Mobile Number', provider.phoneNumber, (value) {
                      provider.setPhoneNumber(value);
                    }),
                  ),
                ),
                Consumer<ProfileProvider>(
                  builder: (context, provider, _) => _buildInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: provider.email,
                    isEditable: true,
                    onEdit: () => _editField(context, 'Email', provider.email, (value) {
                      provider.setEmail(value);
                    }),
                  ),
                ),
                Consumer<ProfileProvider>(
                  builder: (context, provider, _) => _buildInfoTile(
                    icon: Icons.emergency_outlined,
                    label: 'Emergency Contact',
                    value: provider.emergencyContact,
                    isEditable: true,
                    onEdit: () => _editField(context, 'Emergency Contact', provider.emergencyContact, (value) {
                      provider.setEmergencyContact(value);
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildActionButton(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () => _showSnackBar(context, 'Change Password'),
                  ),
                  const SizedBox(height: 10),
                  _buildActionButton(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => _showSnackBar(context, 'Help & Support'),
                  ),
                  const SizedBox(height: 10),
                  _buildActionButton(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () => _showLogoutDialog(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = false,
    VoidCallback? onEdit,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isEditable)
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700, size: 20),
                onPressed: onEdit,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? Colors.red.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.blue.shade700,
              size: 22,
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? Colors.red : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _editField(BuildContext context, String fieldName, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: fieldName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              _showSnackBar(context, '$fieldName updated successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Select a field to edit from the Contact Details section.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Logged out successfully');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(BuildContext context, String phoneNumber) {
    _showSnackBar(context, 'Calling $phoneNumber...');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}