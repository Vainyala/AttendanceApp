import 'package:AttendanceApp/manager/models/user_model.dart';
import 'package:flutter/material.dart';

class ManagerProfileHeader extends StatelessWidget {
  final User user;

  const ManagerProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900.withOpacity(0.9),
            Colors.purple.shade800.withOpacity(0.8),
            Colors.deepPurple.shade900.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade700.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          // Profile Avatar
          Stack(
            children: [
              // Outer Glow
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan.shade400.withOpacity(0.8),
                      Colors.blue.shade400.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.shade400.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
              // Profile Image
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profile_placeholder.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: Colors.white.withOpacity(0.8),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Online Status Indicator
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade400.withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCESS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan.shade400.withOpacity(0.3),
                        Colors.blue.shade400.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getQuantumPositionTitle(user.userType),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.cyan.shade300,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NUTANTEK SYSTEMS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
              // Notification Badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade400.withOpacity(0.8),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getQuantumPositionTitle(String userType) {
    switch (userType.toLowerCase()) {
      case 'manager':
        return 'MANAGER';
      case 'hr':
        return 'HR LEAD';
      case 'finance_manager':
        return 'FINANCE';
      case 'admin':
        return 'SYSTEM ADMIN';
      case 'supervisor':
        return 'TEAM LEAD';
      default:
        return 'OPERATOR';
    }
  }
}

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:AttendanceApp/models/user_model.dart';
// import 'package:flutter/material.dart';

// class ManagerProfileHeader extends StatelessWidget {
//   final User user;

//   const ManagerProfileHeader({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.primary, AppColors.secondary],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Profile Image
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: AppColors.white,
//               border: Border.all(color: AppColors.white, width: 2),
//             ),
//             child: ClipOval(
//               child: Image.asset(
//                 'assets/images/profile_placeholder.png',
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Icon(Icons.person, size: 30, color: AppColors.primary);
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(width: 16),

//           // User Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user.name,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _getPositionTitle(user.userType),
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.white.withOpacity(0.9),
//                   ),
//                 ),
//                 Text(
//                   'Nutantek Solutions',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: AppColors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Notification Icon
//           IconButton(
//             icon: const Icon(
//               Icons.notifications_none_rounded,
//               color: AppColors.white,
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   String _getPositionTitle(String userType) {
//     switch (userType) {
//       case 'manager':
//         return 'Project Manager';
//       case 'hr':
//         return 'HR Manager';
//       case 'finance_manager':
//         return 'Finance Manager';
//       default:
//         return 'Manager';
//     }
//   }
// }
