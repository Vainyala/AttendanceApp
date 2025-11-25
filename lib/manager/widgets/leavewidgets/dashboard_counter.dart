// widgets/dashboard_counter.dart
import 'package:AttendanceApp/manager/core/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';

class DashboardCounter extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;
  final bool isDarkMode;

  const DashboardCounter({
    super.key,
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppColors.white : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode
        ? AppColors.white.withOpacity(0.8)
        : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isDarkMode
                ? color.withOpacity(0.15)
                : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? color.withOpacity(0.4)
                  : color.withOpacity(0.3),
            ),
            boxShadow: isDarkMode
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDarkMode ? color.withOpacity(0.9) : color,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? color.withOpacity(0.9) : color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }
}

// // widgets/dashboard_counter.dart
// import 'package:flutter/material.dart';

// class DashboardCounter extends StatelessWidget {
//   final int count;
//   final String label;
//   final Color color;
//   final IconData icon;

//   const DashboardCounter({
//     super.key,
//     required this.count,
//     required this.label,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: color, size: 20),
//               const SizedBox(height: 4),
//               Text(
//                 count.toString(),
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//         ),
//       ],
//     );
//   }
// }
