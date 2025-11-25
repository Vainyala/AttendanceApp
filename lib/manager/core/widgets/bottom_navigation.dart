import 'package:AttendanceApp/manager/core/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';

class ManagerBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const ManagerBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 7,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(),
        height: 65,
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavButton(
              icon: Icons.dashboard_rounded,
              label: 'DASHBOARD',
              index: 0,
              isSelected: currentIndex == 0,
            ),
            _buildNavButton(
              icon: Icons.calendar_today_rounded,
              label: 'REGULARIZATION',
              index: 1,
              isSelected: currentIndex == 1,
            ),
            _buildNavButton(
              icon: Icons.beach_access_rounded,
              label: 'LEAVE',
              index: 2,
              isSelected: currentIndex == 2,
            ),
            _buildNavButton(
              icon: Icons.timeline_rounded,
              label: 'TIMESHEET',
              index: 3,
              isSelected: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabChanged(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.8),
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:flutter/material.dart';

// class ManagerBottomNavigation extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTabChanged;

//   const ManagerBottomNavigation({
//     super.key,
//     required this.currentIndex,
//     required this.onTabChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom:
//             MediaQuery.of(context).padding.bottom +
//             7, // ✅ Mobile navigation bar के ऊपर
//       ),
//       child: Container(
//         margin: const EdgeInsets.symmetric(),
//         height: 65,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(0),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade900.withOpacity(0.95),
//               Colors.purple.shade800.withOpacity(0.85),
//               Colors.deepPurple.shade900.withOpacity(0.95),
//             ],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.shade700.withOpacity(0.5),
//               blurRadius: 25,
//               spreadRadius: 3,
//               offset: const Offset(0, 10),
//             ),
//           ],
//           border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildQuantumNavButton(
//               icon: Icons.dashboard_rounded,
//               label: 'DASHBOARD',
//               index: 0,
//               isSelected: currentIndex == 0,
//             ),
//             _buildQuantumNavButton(
//               icon: Icons.calendar_today_rounded,
//               label: 'REGULARISATION',
//               index: 1,
//               isSelected: currentIndex == 1,
//             ),
//             _buildQuantumNavButton(
//               icon: Icons.beach_access_rounded,
//               label: 'LEAVE',
//               index: 2,
//               isSelected: currentIndex == 2,
//             ),
//             _buildQuantumNavButton(
//               icon: Icons.timeline_rounded,
//               label: 'TIMELINE',
//               index: 3,
//               isSelected: currentIndex == 3,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuantumNavButton({
//     required IconData icon,
//     required String label,
//     required int index,
//     required bool isSelected,
//   }) {
//     return Expanded(
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => onTabChanged(index),
//           borderRadius: BorderRadius.circular(20),
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
//             decoration: BoxDecoration(
//               gradient: isSelected
//                   ? LinearGradient(
//                       colors: [
//                         Colors.cyan.shade400.withOpacity(0.3),
//                         Colors.blue.shade400.withOpacity(0.2),
//                       ],
//                     )
//                   : null,
//               borderRadius: BorderRadius.circular(20),
//               border: isSelected
//                   ? Border.all(
//                       color: Colors.cyan.shade400.withOpacity(0.5),
//                       width: 1.5,
//                     )
//                   : null,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Icon(
//                       icon,
//                       size: 18,
//                       color: isSelected
//                           ? Colors.cyan.shade400
//                           : Colors.white.withOpacity(0.6),
//                     ),
//                     if (isSelected)
//                       Positioned(
//                         top: -3,
//                         right: -3,
//                         child: Container(
//                           width: 6,
//                           height: 6,
//                           decoration: BoxDecoration(
//                             color: Colors.cyan.shade400,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.cyan.shade400.withOpacity(0.8),
//                                 blurRadius: 8,
//                                 spreadRadius: 1,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 9,
//                     fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
//                     color: isSelected
//                         ? Colors.cyan.shade400
//                         : Colors.white.withOpacity(0.7),
//                     letterSpacing: isSelected ? 0.6 : 0.4,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:flutter/material.dart';

// class ManagerBottomNavigation extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTabChanged;

//   const ManagerBottomNavigation({
//     super.key,
//     required this.currentIndex,
//     required this.onTabChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       height: 70,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.blue.shade900.withOpacity(0.95),
//             Colors.purple.shade800.withOpacity(0.85),
//             Colors.deepPurple.shade900.withOpacity(0.95),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.shade700.withOpacity(0.5),
//             blurRadius: 25,
//             spreadRadius: 3,
//             offset: const Offset(0, 10),
//           ),
//         ],
//         border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildQuantumNavButton(
//             icon: Icons.dashboard_rounded,
//             label: 'DASHBOARD',
//             index: 0,
//             isSelected: currentIndex == 0,
//           ),
//           _buildQuantumNavButton(
//             icon: Icons.calendar_today_rounded,
//             label: 'REGULARISATION',
//             index: 1,
//             isSelected: currentIndex == 1,
//           ),
//           _buildQuantumNavButton(
//             icon: Icons.beach_access_rounded,
//             label: 'LEAVE',
//             index: 2,
//             isSelected: currentIndex == 2,
//           ),
//           _buildQuantumNavButton(
//             icon: Icons.schedule_rounded,
//             label: 'TIME',
//             index: 3,
//             isSelected: currentIndex == 3,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuantumNavButton({
//     required IconData icon,
//     required String label,
//     required int index,
//     required bool isSelected,
//   }) {
//     return Expanded(
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => onTabChanged(index),
//           borderRadius: BorderRadius.circular(20),
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//             decoration: BoxDecoration(
//               gradient: isSelected
//                   ? LinearGradient(
//                       colors: [
//                         Colors.cyan.shade400.withOpacity(0.3),
//                         Colors.blue.shade400.withOpacity(0.2),
//                       ],
//                     )
//                   : null,
//               borderRadius: BorderRadius.circular(20),
//               border: isSelected
//                   ? Border.all(
//                       color: Colors.cyan.shade400.withOpacity(0.5),
//                       width: 1.5,
//                     )
//                   : null,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Stack(
//                   children: [
//                     Icon(
//                       icon,
//                       size: 20,
//                       color: isSelected
//                           ? Colors.cyan.shade400
//                           : Colors.white.withOpacity(0.6),
//                     ),
//                     if (isSelected)
//                       Positioned(
//                         top: -2,
//                         right: -2,
//                         child: Container(
//                           width: 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: Colors.cyan.shade400,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.cyan.shade400.withOpacity(0.8),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
//                     color: isSelected
//                         ? Colors.cyan.shade400
//                         : Colors.white.withOpacity(0.7),
//                     letterSpacing: isSelected ? 0.8 : 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:AttendanceApp/core/view_models/theme_view_model.dart';
// import 'package:flutter/material.dart';

// class ManagerBottomNavigation extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTabChanged;

//   const ManagerBottomNavigation({
//     super.key,
//     required this.currentIndex,
//     required this.onTabChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.grey300.withOpacity(0.5),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(25),
//         child: BottomNavigationBar(
//           currentIndex: currentIndex,
//           onTap: onTabChanged,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: AppColors.white,
//           selectedItemColor: AppColors.primary,
//           unselectedItemColor: AppColors.grey500,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//           unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.dashboard_rounded),
//               label: 'Dashboard',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_rounded),
//               label: 'Regularisation',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.beach_access_rounded),
//               label: 'Leave',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.schedule_rounded),
//               label: 'Timesheet',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
