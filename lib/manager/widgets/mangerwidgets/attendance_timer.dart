
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/managerviewmodels/manager_dashboard_view_model.dart';

class AttendanceTimerSection extends StatefulWidget {
  const AttendanceTimerSection({super.key});

  @override
  State<AttendanceTimerSection> createState() => _AttendanceTimerSectionState();
}

class _AttendanceTimerSectionState extends State<AttendanceTimerSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ManagerDashboardViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.blue.shade700,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? Colors.grey.shade700
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildWorkingHoursProgress(viewModel, context, isDark),
                  const SizedBox(height: 16),
                  _buildAttendanceButtons(viewModel, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkingHoursProgress(
    ManagerDashboardViewModel viewModel,
    BuildContext context,
    bool isDark,
  ) {
    final progress = viewModel.workingHours.workedDuration.inMinutes / (9 * 60);
    final workedHours = viewModel.workingHours.workedDuration.inHours;
    final workedMinutes = viewModel.workingHours.workedDuration.inMinutes
        .remainder(60);
    final isComplete = progress >= 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Present Timer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isComplete
                    ? Colors.green.shade600
                    : (isDark ? Colors.blue.shade800 : Colors.blue.shade600),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$workedHours h $workedMinutes m',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Progress Bar
        Stack(
          children: [
            // Background Track
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade700
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Animated Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              height: 8,
              width:
                  (MediaQuery.of(context).size.width - 72) *
                  progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: isComplete ? Colors.green : Colors.orange.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Progress Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isComplete ? Colors.green : Colors.orange.shade400,
              ),
            ),
            Text(
              '9 Hrs',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceButtons(
    ManagerDashboardViewModel viewModel,
    bool isDark,
  ) {
    final isCheckedIn = viewModel.workingHours.isCheckedIn;
    final canCheckOut = viewModel.workingHours.canCheckOut;

    return Row(
      children: [
        // Check In Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: isCheckedIn
                    ? null
                    : () {
                        _triggerAnimation();
                        if (viewModel.dashboard != null) {
                          viewModel.checkIn(viewModel.dashboard!.profile.email);
                        }
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCheckedIn
                        ? (isDark ? Colors.grey.shade700 : Colors.grey.shade400)
                        : Colors.green.shade600,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCheckedIn
                          ? (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300)
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCheckedIn
                            ? Icons.verified_rounded
                            : Icons.login_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCheckedIn ? 'ACTIVE' : 'CHECK-IN',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Check Out Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: !isCheckedIn || !canCheckOut
                    ? null
                    : () {
                        _triggerAnimation();
                        if (viewModel.dashboard != null) {
                          viewModel.checkOut(
                            viewModel.dashboard!.profile.email,
                          );
                        }
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: (!isCheckedIn || !canCheckOut)
                        ? (isDark ? Colors.grey.shade700 : Colors.grey.shade400)
                        : Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (!isCheckedIn || !canCheckOut)
                          ? (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300)
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'CHECK-OUT',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AttendanceTimerSection extends StatefulWidget {
//   const AttendanceTimerSection({super.key});

//   @override
//   State<AttendanceTimerSection> createState() => _AttendanceTimerSectionState();
// }

// class _AttendanceTimerSectionState extends State<AttendanceTimerSection>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _triggerAnimation() {
//     _animationController.reset();
//     _animationController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);

//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Opacity(
//             opacity: _fadeAnimation.value,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.1),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildWorkingHoursProgress(viewModel, context),
//                   const SizedBox(height: 16),
//                   _buildAttendanceButtons(viewModel),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildWorkingHoursProgress(
//     ManagerDashboardViewModel viewModel,
//     BuildContext context,
//   ) {
//     final progress = viewModel.workingHours.workedDuration.inMinutes / (9 * 60);
//     final workedHours = viewModel.workingHours.workedDuration.inHours;
//     final workedMinutes = viewModel.workingHours.workedDuration.inMinutes
//         .remainder(60);
//     final isComplete = progress >= 1.0;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         Row(
//           children: [
//             Text(
//               'Present Timer',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//             ),
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: isComplete ? AppColors.success : AppColors.primaryLight,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 '$workedHours h $workedMinutes m',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         // Progress Bar
//         Stack(
//           children: [
//             // Background Track
//             Container(
//               height: 8,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             // Animated Progress
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeOut,
//               height: 8,
//               width:
//                   (MediaQuery.of(context).size.width - 72) *
//                   progress.clamp(0.0, 1.0),
//               decoration: BoxDecoration(
//                 color: isComplete ? AppColors.success : AppColors.accent,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         // Progress Labels
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Start',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//             ),
//             Text(
//               '${(progress * 100).toStringAsFixed(0)}%',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: isComplete ? AppColors.success : AppColors.accent,
//               ),
//             ),
//             Text(
//               '9 Hrs',
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildAttendanceButtons(ManagerDashboardViewModel viewModel) {
//     final isCheckedIn = viewModel.workingHours.isCheckedIn;
//     final canCheckOut = viewModel.workingHours.canCheckOut;

//     return Row(
//       children: [
//         // Check In Button
//         Expanded(
//           child: Container(
//             height: 48,
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
//             child: Material(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(8),
//               child: InkWell(
//                 onTap: isCheckedIn
//                     ? null
//                     : () {
//                         _triggerAnimation();
//                         if (viewModel.dashboard != null) {
//                           viewModel.checkIn(viewModel.dashboard!.profile.email);
//                         }
//                       },
//                 borderRadius: BorderRadius.circular(8),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isCheckedIn ? AppColors.grey500 : AppColors.success,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(isCheckedIn ? 0.1 : 0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         isCheckedIn
//                             ? Icons.verified_rounded
//                             : Icons.login_rounded,
//                         size: 18,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         isCheckedIn ? 'ACTIVE' : 'CHECK-IN',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(width: 12),

//         // Check Out Button
//         Expanded(
//           child: Container(
//             height: 48,
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
//             child: Material(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(8),
//               child: InkWell(
//                 onTap: !isCheckedIn || !canCheckOut
//                     ? null
//                     : () {
//                         _triggerAnimation();
//                         if (viewModel.dashboard != null) {
//                           viewModel.checkOut(
//                             viewModel.dashboard!.profile.email,
//                           );
//                         }
//                       },
//                 borderRadius: BorderRadius.circular(8),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: (!isCheckedIn || !canCheckOut)
//                         ? AppColors.grey500
//                         : AppColors.warning,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(
//                         (!isCheckedIn || !canCheckOut) ? 0.1 : 0.2,
//                       ),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.logout_rounded, size: 18, color: Colors.white),
//                       const SizedBox(width: 8),
//                       Text(
//                         'CHECK-OUT',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'dart:ui';

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AttendanceTimerSection extends StatefulWidget {
//   const AttendanceTimerSection({super.key});

//   @override
//   State<AttendanceTimerSection> createState() => _AttendanceTimerSectionState();
// }

// class _AttendanceTimerSectionState extends State<AttendanceTimerSection>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _glowAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInCubic),
//     );

//     _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
//       ),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _triggerAnimation() {
//     _animationController.reset();
//     _animationController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);

//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Opacity(
//             opacity: _fadeAnimation.value,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.blue.shade900.withOpacity(0.9),
//                     Colors.purple.shade800.withOpacity(0.8),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blue.shade700.withOpacity(
//                       _glowAnimation.value * 0.4,
//                     ),
//                     blurRadius: 20,
//                     spreadRadius: 2,
//                     offset: const Offset(0, 8),
//                   ),
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                   width: 1.5,
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildQuantumWorkingHoursProgress(viewModel, context),
//                   const SizedBox(height: 16),
//                   _buildQuantumAttendanceButtons(viewModel),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildQuantumWorkingHoursProgress(
//     ManagerDashboardViewModel viewModel,
//     BuildContext context,
//   ) {
//     final progress = viewModel.workingHours.workedDuration.inMinutes / (9 * 60);
//     final workedHours = viewModel.workingHours.workedDuration.inHours;
//     final workedMinutes = viewModel.workingHours.workedDuration.inMinutes
//         .remainder(60);
//     final isComplete = progress >= 1.0;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         Row(
//           children: [
//             // Container(
//             //   padding: const EdgeInsets.all(8),
//             //   decoration: BoxDecoration(
//             //     gradient: LinearGradient(
//             //       colors: [
//             //         Colors.cyan.shade400.withOpacity(0.8),
//             //         Colors.blue.shade400.withOpacity(0.8),
//             //       ],
//             //     ),
//             //     shape: BoxShape.circle,
//             //     boxShadow: [
//             //       BoxShadow(
//             //         color: Colors.cyan.shade400.withOpacity(0.4),
//             //         blurRadius: 10,
//             //         spreadRadius: 2,
//             //       ),
//             //     ],
//             //   ),
//             //   child: Icon(
//             //     Icons.access_time_rounded,
//             //     size: 20,
//             //     color: Colors.white,
//             //   ),
//             // ),
//             // const SizedBox(width: 12),
//             Text(
//               'Present Timer',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: isComplete
//                       ? [Colors.green.shade600, Colors.lightGreen.shade400]
//                       : [Colors.blue.shade600, Colors.cyan.shade400],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: (isComplete ? Colors.green : Colors.blue)
//                         .withOpacity(0.4),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 '$workedHours h $workedMinutes m',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         // Progress Bar
//         Stack(
//           children: [
//             // Background Track
//             Container(
//               height: 12,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//             ),
//             // Animated Progress
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 1000),
//               curve: Curves.easeOutCubic,
//               height: 12,
//               width:
//                   (MediaQuery.of(context).size.width - 72) *
//                   progress.clamp(0.0, 1.0),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: isComplete
//                       ? [Colors.green.shade500, Colors.lightGreen.shade400]
//                       : [Colors.cyan.shade400, Colors.blue.shade600],
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: (isComplete ? Colors.green : Colors.cyan)
//                         .withOpacity(0.6),
//                     blurRadius: 12,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//             ),
//             // Progress Glow Effect
//             if (_glowAnimation.value > 0.5)
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 500),
//                 height: 12,
//                 width:
//                     (MediaQuery.of(context).size.width - 72) *
//                     progress.clamp(0.0, 1.0),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.white.withOpacity(_glowAnimation.value * 0.3),
//                       Colors.transparent,
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         // Progress Labels
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Start',
//               style: TextStyle(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white.withOpacity(0.8),
//                 letterSpacing: 0.8,
//               ),
//             ),
//             Text(
//               '${(progress * 100).toStringAsFixed(0)}%',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w800,
//                 color: isComplete
//                     ? Colors.green.shade300
//                     : Colors.cyan.shade300,
//                 letterSpacing: 0.8,
//               ),
//             ),
//             Text(
//               '9 Hrs',
//               style: TextStyle(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white.withOpacity(0.8),
//                 letterSpacing: 0.8,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildQuantumAttendanceButtons(ManagerDashboardViewModel viewModel) {
//     final isCheckedIn = viewModel.workingHours.isCheckedIn;
//     final canCheckOut = viewModel.workingHours.canCheckOut;

//     return Row(
//       children: [
//         // Check In Button
//         Expanded(
//           child: Container(
//             height: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: isCheckedIn
//                   ? []
//                   : [
//                       BoxShadow(
//                         color: Colors.green.shade600.withOpacity(0.4),
//                         blurRadius: 15,
//                         offset: const Offset(0, 6),
//                       ),
//                     ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(12),
//               child: InkWell(
//                 onTap: isCheckedIn
//                     ? null
//                     : () {
//                         _triggerAnimation();
//                         if (viewModel.dashboard != null) {
//                           viewModel.checkIn(viewModel.dashboard!.profile.email);
//                         }
//                       },
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: isCheckedIn
//                           ? [Colors.grey.shade600, Colors.grey.shade700]
//                           : [Colors.green.shade600, Colors.lightGreen.shade400],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(isCheckedIn ? 0.1 : 0.3),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         isCheckedIn
//                             ? Icons.verified_rounded
//                             : Icons.login_rounded,
//                         size: 20,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         isCheckedIn ? 'ACTIVE' : 'CHECK-IN',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                           letterSpacing: 0.8,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(width: 12),

//         // Check Out Button
//         Expanded(
//           child: Container(
//             height: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: (!isCheckedIn || !canCheckOut)
//                   ? []
//                   : [
//                       BoxShadow(
//                         color: Colors.orange.shade600.withOpacity(0.4),
//                         blurRadius: 15,
//                         offset: const Offset(0, 6),
//                       ),
//                     ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(12),
//               child: InkWell(
//                 onTap: !isCheckedIn || !canCheckOut
//                     ? null
//                     : () {
//                         _triggerAnimation();
//                         if (viewModel.dashboard != null) {
//                           viewModel.checkOut(
//                             viewModel.dashboard!.profile.email,
//                           );
//                         }
//                       },
//                 borderRadius: BorderRadius.circular(12),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: (!isCheckedIn || !canCheckOut)
//                           ? [Colors.grey.shade600, Colors.grey.shade700]
//                           : [Colors.orange.shade600, Colors.amber.shade400],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(
//                         (!isCheckedIn || !canCheckOut) ? 0.1 : 0.3,
//                       ),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.logout_rounded, size: 20, color: Colors.white),
//                       const SizedBox(width: 8),
//                       Text(
//                         'CHECK-OUT',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                           letterSpacing: 0.8,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/view_models/managerviewmodels/manager_dashboard_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AttendanceTimerSection extends StatefulWidget {
//   const AttendanceTimerSection({super.key});

//   @override
//   State<AttendanceTimerSection> createState() => _AttendanceTimerSectionState();
// }

// class _AttendanceTimerSectionState extends State<AttendanceTimerSection>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _triggerAnimation() {
//     _animationController.reset();
//     _animationController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);

//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Container(
//           margin: const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 6,
//           ), // Reduced margin
//           padding: const EdgeInsets.all(14), // Reduced padding
//           decoration: BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.grey300.withOpacity(0.2),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//             border: Border.all(color: AppColors.grey200, width: 1),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // ← IMPORTANT: Prevent overflow
//             children: [
//               _buildCompactWorkingHoursProgress(viewModel, context),
//               const SizedBox(height: 10), // Reduced spacing
//               _buildCompactAttendanceButtons(viewModel),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCompactWorkingHoursProgress(
//     ManagerDashboardViewModel viewModel,
//     BuildContext context,
//   ) {
//     final progress = viewModel.workingHours.workedDuration.inMinutes / (9 * 60);
//     final workedHours = viewModel.workingHours.workedDuration.inHours;
//     final workedMinutes = viewModel.workingHours.workedDuration.inMinutes
//         .remainder(60);

//     return Column(
//       mainAxisSize: MainAxisSize.min, // ← IMPORTANT
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Compact Header
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(4), // Smaller padding
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.access_time_rounded,
//                 size: 16, // Smaller icon
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Text(
//               'Working Hours',
//               style: TextStyle(
//                 fontSize: 13, // Smaller font
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 6,
//                 vertical: 2,
//               ), // Smaller padding
//               decoration: BoxDecoration(
//                 color: progress >= 1.0
//                     ? AppColors.success.withOpacity(0.1)
//                     : AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 '$workedHours h $workedMinutes m',
//                 style: TextStyle(
//                   fontSize: 11, // Smaller font
//                   fontWeight: FontWeight.w600,
//                   color: progress >= 1.0
//                       ? AppColors.success
//                       : AppColors.primary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8), // Reduced spacing
//         // Compact Progress Bar
//         Stack(
//           children: [
//             // Background
//             Container(
//               height: 6, // Smaller height
//               decoration: BoxDecoration(
//                 color: AppColors.grey200,
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//             // Animated Progress
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 800),
//               curve: Curves.easeOut,
//               height: 6, // Smaller height
//               width:
//                   (MediaQuery.of(context).size.width - 60) *
//                   progress, // Adjusted width calculation
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: progress >= 1.0
//                       ? [AppColors.success, AppColors.success.withOpacity(0.7)]
//                       : [AppColors.primary, AppColors.primaryLight],
//                 ),
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6), // Reduced spacing
//         // Compact Progress Labels
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               '9:00',
//               style: TextStyle(
//                 fontSize: 10, // Smaller font
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             Text(
//               '${(progress * 100).toStringAsFixed(0)}%',
//               style: TextStyle(
//                 fontSize: 10, // Smaller font
//                 fontWeight: FontWeight.w600,
//                 color: progress >= 1.0
//                     ? AppColors.success
//                     : AppColors.textSecondary,
//               ),
//             ),
//             Text(
//               '9h',
//               style: TextStyle(
//                 fontSize: 10, // Smaller font
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildCompactAttendanceButtons(ManagerDashboardViewModel viewModel) {
//     final isCheckedIn = viewModel.workingHours.isCheckedIn;
//     final canCheckOut = viewModel.workingHours.canCheckOut;

//     return Row(
//       children: [
//         // Check In Button - More Compact
//         Expanded(
//           child: Container(
//             height: 38, // Fixed height to prevent overflow
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: isCheckedIn
//                   ? []
//                   : [
//                       BoxShadow(
//                         color: AppColors.success.withOpacity(0.2),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//             ),
//             child: ElevatedButton(
//               onPressed: isCheckedIn
//                   ? null
//                   : () {
//                       _triggerAnimation();
//                       if (viewModel.dashboard != null) {
//                         viewModel.checkIn(viewModel.dashboard!.profile.email);
//                       }
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isCheckedIn
//                     ? AppColors.grey300
//                     : AppColors.success,
//                 foregroundColor: isCheckedIn
//                     ? AppColors.grey500
//                     : AppColors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 0,
//                 ), // Compact padding
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 textStyle: const TextStyle(
//                   fontSize: 12, // Smaller font
//                   fontWeight: FontWeight.w600,
//                 ),
//                 elevation: isCheckedIn ? 0 : 1,
//                 minimumSize: Size.zero, // Remove minimum size constraints
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min, // Important for compact layout
//                 children: [
//                   Icon(
//                     isCheckedIn
//                         ? Icons.check_circle_rounded
//                         : Icons.login_rounded,
//                     size: 16, // Smaller icon
//                   ),
//                   const SizedBox(width: 4), // Reduced spacing
//                   Text(isCheckedIn ? 'CHECKED IN' : 'CHECK IN'),
//                 ],
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(width: 8), // Reduced spacing
//         // Check Out Button - More Compact
//         Expanded(
//           child: Container(
//             height: 38, // Fixed height to prevent overflow
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: (!isCheckedIn || !canCheckOut)
//                   ? []
//                   : [
//                       BoxShadow(
//                         color: AppColors.error.withOpacity(0.2),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//             ),
//             child: ElevatedButton(
//               onPressed: !isCheckedIn || !canCheckOut
//                   ? null
//                   : () {
//                       _triggerAnimation();
//                       if (viewModel.dashboard != null) {
//                         viewModel.checkOut(viewModel.dashboard!.profile.email);
//                       }
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: (!isCheckedIn || !canCheckOut)
//                     ? AppColors.grey300
//                     : AppColors.error,
//                 foregroundColor: (!isCheckedIn || !canCheckOut)
//                     ? AppColors.grey500
//                     : AppColors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 0,
//                 ), // Compact padding
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 textStyle: const TextStyle(
//                   fontSize: 12, // Smaller font
//                   fontWeight: FontWeight.w600,
//                 ),
//                 elevation: (!isCheckedIn || !canCheckOut) ? 0 : 1,
//                 minimumSize: Size.zero, // Remove minimum size constraints
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min, // Important for compact layout
//                 children: [
//                   Icon(
//                     Icons.logout_rounded,
//                     size: 16, // Smaller icon
//                   ),
//                   const SizedBox(width: 4), // Reduced spacing
//                   const Text('CHECK OUT'),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class AttendanceTimerSection extends StatelessWidget {
//   const AttendanceTimerSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<ManagerDashboardViewModel>(context);

//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.grey300.withOpacity(0.5),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Working Hours Progress
//           _buildWorkingHoursProgress(viewModel),
//           const SizedBox(height: 10),

//           // Check In/Out Buttons
//           _buildAttendanceButtons(viewModel),
//         ],
//       ),
//     );
//   }

//   Widget _buildWorkingHoursProgress(ManagerDashboardViewModel viewModel) {
//     final progress = viewModel.workingHours.workedDuration.inMinutes / (9 * 60);

//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Working Hours',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             Text(
//               '${viewModel.workingHours.workedDuration.inHours}h '
//               '${viewModel.workingHours.workedDuration.inMinutes.remainder(60)}m',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.primary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         LinearProgressIndicator(
//           value: progress,
//           backgroundColor: AppColors.grey200,
//           valueColor: AlwaysStoppedAnimation<Color>(
//             progress >= 1.0 ? AppColors.success : AppColors.primary,
//           ),
//           minHeight: 8,
//           borderRadius: BorderRadius.circular(4),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               '9:00',
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//             Text(
//               'Target: 9 hours',
//               style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildAttendanceButtons(ManagerDashboardViewModel viewModel) {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: viewModel.workingHours.isCheckedIn
//                 ? null
//                 : () => viewModel.checkIn(viewModel.dashboard!.profile.email),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.success,
//               foregroundColor: AppColors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.login_rounded, size: 20),
//                 SizedBox(width: 8),
//                 Text('CHECK IN', style: TextStyle(fontWeight: FontWeight.w600)),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed:
//                 !viewModel.workingHours.isCheckedIn ||
//                     !viewModel.workingHours.canCheckOut
//                 ? null
//                 : () => viewModel.checkOut(viewModel.dashboard!.profile.email),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.error,
//               foregroundColor: AppColors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.logout_rounded, size: 20),
//                 SizedBox(width: 8),
//                 Text(
//                   'CHECK OUT',
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
