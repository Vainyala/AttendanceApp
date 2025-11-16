import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final String? name;
  final String? role;
  final String company;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.role,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textLight, width: 3),
              image: const DecorationImage(
                image: AssetImage('assets/images/profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          name ?? 'Loading...',
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          role ?? 'Developer',
          style: const TextStyle(color: AppColors.cardBackground, fontSize: 16),
        ),
        const SizedBox(height: 3),
        Text(
          company,
          style: const TextStyle(color: AppColors.cardBackground, fontSize: 14),
        ),
      ],
    );
  }
}
