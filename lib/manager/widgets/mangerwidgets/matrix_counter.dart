import 'package:flutter/material.dart';

class MetricsCounter extends StatefulWidget {
  final int totalAttendance;
  final int teamMembers;
  final int projects;
  final String timeline;

  const MetricsCounter({
    super.key,
    required this.totalAttendance,
    required this.teamMembers,
    required this.projects,
    required this.timeline,
  });

  @override
  State<MetricsCounter> createState() => _MetricsCounterState();
}

class _MetricsCounterState extends State<MetricsCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.of(context).orientation == Orientation.landscape;
              final crossAxisCount = isLandscape ? 4 : 2;
              final childAspectRatio = isLandscape ? 1.3 : 1.4;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: EdgeInsets.zero,
                children: [
                  _buildCounterCard(
                    context,
                    'PROJECTS',
                    widget.projects,
                    Icons.assignment_rounded,
                    Colors.orange,
                    isDark,
                  ),
                  _buildCounterCard(
                    context,
                    'TEAM',
                    widget.teamMembers,
                    Icons.people_alt_rounded,
                    Colors.cyan,
                    isDark,
                  ),
                  _buildCounterCard(
                    context,
                    'ATTENDANCE',
                    widget.totalAttendance,
                    Icons.groups_rounded,
                    Colors.green,
                    isDark,
                  ),
                  _buildCounterCard(
                    context,
                    'TIMESHEET',
                    widget.timeline,
                    Icons.timeline_rounded,
                    Colors.purple,
                    isDark,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCounterCard(
    BuildContext context,
    String title,
    dynamic value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * _animation.value),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _controller.reset();
                  _controller.forward();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? color.withOpacity(0.2)
                              : color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 18, color: color),
                      ),

                      const SizedBox(height: 8),
                      // Counter Value
                      if (value is int)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final animatedValue = (value * _animation.value)
                                .toInt();
                            return Text(
                              animatedValue.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            );
                          },
                        )
                      else
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 4),
                      // Title
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black.withOpacity(0.7),
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';

// class MetricsCounter extends StatefulWidget {
//   final int totalAttendance;
//   final int teamMembers;
//   final int projects;
//   final String timeline;

//   const MetricsCounter({
//     super.key,
//     required this.totalAttendance,
//     required this.teamMembers,
//     required this.projects,
//     required this.timeline,
//   });

//   @override
//   State<MetricsCounter> createState() => _MetricsCounterState();
// }

// class _MetricsCounterState extends State<MetricsCounter>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       //padding: const EdgeInsets.all(16),
//       // decoration: BoxDecoration(
//       //   color: Colors.white.withOpacity(0.1),
//       //   borderRadius: BorderRadius.circular(16),
//       //   border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
//       // ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           LayoutBuilder(
//             builder: (context, constraints) {
//               final isLandscape =
//                   MediaQuery.of(context).orientation == Orientation.landscape;
//               final crossAxisCount = isLandscape ? 4 : 2;
//               final childAspectRatio = isLandscape ? 1.3 : 1.4;

//               return GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: crossAxisCount,
//                 childAspectRatio: childAspectRatio,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 padding: EdgeInsets.zero,
//                 children: [
//                   _buildCounterCard(
//                     context,
//                     'PROJECTS',
//                     widget.projects,
//                     Icons.assignment_rounded,
//                     Colors.orange,
//                   ),
//                   _buildCounterCard(
//                     context,
//                     'TEAM',
//                     widget.teamMembers,
//                     Icons.people_alt_rounded,
//                     Colors.cyan,
//                   ),
//                   _buildCounterCard(
//                     context,
//                     'ATTENDANCE',
//                     widget.totalAttendance,
//                     Icons.groups_rounded,
//                     Colors.green,
//                   ),
//                   _buildCounterCard(
//                     context,
//                     'TIMESHEET',
//                     widget.timeline,
//                     Icons.timeline_rounded,
//                     Colors.purple,
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCounterCard(
//     BuildContext context,
//     String title,
//     dynamic value,
//     IconData icon,
//     Color color,
//   ) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: 0.95 + (0.05 * _animation.value),
//           child: Container(
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: color.withOpacity(0.2), width: 1),
//             ),
//             child: Material(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(12),
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(12),
//                 onTap: () {
//                   _controller.reset();
//                   _controller.forward();
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Icon
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(icon, size: 18, color: color),
//                       ),

//                       const SizedBox(height: 8),
//                       // Counter Value
//                       if (value is int)
//                         AnimatedBuilder(
//                           animation: _animation,
//                           builder: (context, child) {
//                             final animatedValue = (value * _animation.value)
//                                 .toInt();
//                             return Text(
//                               animatedValue.toString(),
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700,
//                                 color: color,
//                               ),
//                             );
//                           },
//                         )
//                       else
//                         FittedBox(
//                           fit: BoxFit.scaleDown,
//                           child: Text(
//                             value.toString(),
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: color,
//                             ),
//                             maxLines: 1,
//                             textAlign: TextAlign.center,
//                           ),
//                         ),

//                       const SizedBox(height: 4),
//                       // Title
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                           maxLines: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // _metrics_counter.dart
// import 'package:flutter/material.dart';

// class MetricsCounter extends StatefulWidget {
//   final int totalAttendance;
//   final int teamMembers;
//   final int projects;
//   final String timeline;

//   const MetricsCounter({
//     super.key,
//     required this.totalAttendance,
//     required this.teamMembers,
//     required this.projects,
//     required this.timeline,
//   });

//   @override
//   State<MetricsCounter> createState() => _MetricsCounterState();
// }

// class _MetricsCounterState extends State<MetricsCounter>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack,
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.transparent,
//             Colors.blueGrey.shade900.withOpacity(0.9),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min, // ✅ IMPORTANT FIX
//         children: [
//           // Header with subtle styling
//           // Container(
//           //   padding: const EdgeInsets.symmetric(vertical: 8),
//           //   child: Text(
//           //     'PERFORMANCE METRICS',
//           //     style: TextStyle(
//           //       fontSize: 12,
//           //       fontWeight: FontWeight.w700,
//           //       color: Colors.white.withOpacity(0.7),
//           //       letterSpacing: 1.5,
//           //     ),
//           //   ),
//           // ),
//           const SizedBox(height: 8), // ✅ Reduced spacing
//           // Responsive Metrics Grid
//           LayoutBuilder(
//             builder: (context, constraints) {
//               final isLandscape =
//                   MediaQuery.of(context).orientation == Orientation.landscape;
//               final crossAxisCount = isLandscape ? 4 : 2;
//               final childAspectRatio = isLandscape
//                   ? 1.3
//                   : 1.4; // ✅ Increased aspect ratio

//               return GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: crossAxisCount,
//                 childAspectRatio: childAspectRatio,
//                 crossAxisSpacing: 10, // ✅ Reduced spacing
//                 mainAxisSpacing: 10, // ✅ Reduced spacing
//                 padding: EdgeInsets.zero, // ✅ Remove extra padding
//                 children: [
//                   _buildModernCounterCard(
//                     context,
//                     'PROJECTS',
//                     widget.projects,
//                     Icons.assignment_rounded,
//                     Colors.orangeAccent,
//                   ),
//                   _buildModernCounterCard(
//                     context,
//                     'TEAM',
//                     widget.teamMembers,
//                     Icons.people_alt_rounded,
//                     Colors.cyanAccent,
//                   ),
//                   _buildModernCounterCard(
//                     context,
//                     'ATTENDANCE',
//                     widget.totalAttendance,
//                     Icons.groups_rounded,
//                     Colors.greenAccent,
//                   ),
//                   _buildModernCounterCard(
//                     context,
//                     'TIMESHEET',
//                     widget.timeline,
//                     Icons.timeline_rounded,
//                     Colors.purpleAccent,
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernCounterCard(
//     BuildContext context,
//     String title,
//     dynamic value,
//     IconData icon,
//     Color color,
//   ) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: 0.9 + (0.1 * _animation.value),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
//               ),
//               border: Border.all(color: color.withOpacity(0.2), width: 1.5),
//               boxShadow: [
//                 BoxShadow(
//                   color: color.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(16),
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(16),
//                 onTap: () {
//                   _controller.reset();
//                   _controller.forward();
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(12), // ✅ Reduced padding
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.min, // ✅ IMPORTANT FIX
//                     children: [
//                       // Icon with background
//                       Container(
//                         padding: const EdgeInsets.all(6), // ✅ Reduced padding
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           icon,
//                           size: 18, // ✅ Reduced icon size
//                           color: color,
//                         ),
//                       ),

//                       const SizedBox(height: 8), // ✅ Reduced spacing
//                       // Counter Value
//                       if (value is int)
//                         AnimatedBuilder(
//                           animation: _animation,
//                           builder: (context, child) {
//                             final animatedValue = (value * _animation.value)
//                                 .toInt();
//                             return Text(
//                               animatedValue.toString(),
//                               style: TextStyle(
//                                 fontSize: 20, // ✅ Slightly reduced font size
//                                 fontWeight: FontWeight.w900,
//                                 color: color,
//                                 shadows: [
//                                   Shadow(
//                                     blurRadius: 10,
//                                     color: color.withOpacity(0.3),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         )
//                       else
//                         FittedBox(
//                           fit: BoxFit.scaleDown,
//                           child: Text(
//                             value.toString(),
//                             style: TextStyle(
//                               fontSize: 14, // ✅ Reduced font size
//                               fontWeight: FontWeight.w800,
//                               color: color,
//                             ),
//                             maxLines: 1,
//                             textAlign: TextAlign.center,
//                           ),
//                         ),

//                       const SizedBox(height: 4), // ✅ Reduced spacing
//                       // Title
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         child: Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: 10, // ✅ Reduced font size
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white.withOpacity(0.8),
//                             letterSpacing: 1.0, // ✅ Reduced letter spacing
//                           ),
//                           maxLines: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // _metrics_counter.dart
// import 'package:flutter/material.dart';

// class MetricsCounter extends StatefulWidget {
//   final int totalAttendance;
//   final int teamMembers;
//   final int projects;
//   final String timeline;

//   const MetricsCounter({
//     super.key,
//     required this.totalAttendance,
//     required this.teamMembers,
//     required this.projects,
//     required this.timeline,
//   });

//   @override
//   State<MetricsCounter> createState() => _MetricsCounterState();
// }

// class _MetricsCounterState extends State<MetricsCounter>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutCubic,
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Column(
//           children: [
//             const SizedBox(height: 8),

//             // Responsive Metrics Grid
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final isLandscape =
//                     MediaQuery.of(context).orientation == Orientation.landscape;
//                 final crossAxisCount = isLandscape ? 4 : 2;
//                 final childAspectRatio = isLandscape ? 0.9 : 1.1;

//                 return GridView.count(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisCount: crossAxisCount,
//                   childAspectRatio: childAspectRatio,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                   children: [
//                     _buildCounterCard(
//                       context,
//                       'ATTENDANCE',
//                       widget.totalAttendance,
//                       Colors.green.shade400,
//                     ),
//                     _buildCounterCard(
//                       context,
//                       'TEAM',
//                       widget.teamMembers,
//                       Colors.cyan.shade400,
//                     ),
//                     _buildCounterCard(
//                       context,
//                       'PROJECTS',
//                       widget.projects,
//                       Colors.orange.shade400,
//                     ),
//                     _buildCounterCard(
//                       context,
//                       'TIMELINE',
//                       widget.timeline,
//                       Colors.purple.shade400,
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCounterCard(
//     BuildContext context,
//     String title,
//     dynamic value,
//     Color color,
//   ) {
//     final isLandscape =
//         MediaQuery.of(context).orientation == Orientation.landscape;

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
//         ),
//         border: Border.all(color: color.withOpacity(0.3), width: 1.0),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Counter Value - Large and Prominent
//               if (value is int)
//                 AnimatedBuilder(
//                   animation: _animation,
//                   builder: (context, child) {
//                     final animatedValue = (value * _animation.value).toInt();
//                     return Text(
//                       animatedValue.toString(),
//                       style: TextStyle(
//                         fontSize: isLandscape ? 18 : 20,
//                         fontWeight: FontWeight.w900,
//                         color: color,
//                       ),
//                     );
//                   },
//                 )
//               else
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     value.toString(),
//                     style: TextStyle(
//                       fontSize: isLandscape ? 14 : 16,
//                       fontWeight: FontWeight.w800,
//                       color: color,
//                     ),
//                     maxLines: 1,
//                   ),
//                 ),

//               const SizedBox(height: 6),

//               // Title - Clean and Minimal
//               FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: isLandscape ? 10 : 11,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                   maxLines: 1,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class MetricsCounter extends StatefulWidget {
//   final int totalAttendance;
//   final int teamMembers;
//   final int projects;
//   final String timeline;

//   const MetricsCounter({
//     super.key,
//     required this.totalAttendance,
//     required this.teamMembers,
//     required this.projects,
//     required this.timeline,
//   });

//   @override
//   State<MetricsCounter> createState() => _MetricsCounterState();
// }

// class _MetricsCounterState extends State<MetricsCounter>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutCubic,
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.white.withOpacity(0.15),
//             Colors.white.withOpacity(0.05),
//           ],
//         ),
//         border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Column(
//           children: [
//             //  Header
//             Container(
//               // padding: const EdgeInsets.all(16),
//               // decoration: BoxDecoration(
//               //   border: Border(
//               //     bottom: BorderSide(
//               //       color: Colors.white.withOpacity(0.1),
//               //       width: 1.5,
//               //     ),
//               //   ),
//               // ),
//               // child: Row(
//               //   children: [
//               //     Container(
//               //       padding: const EdgeInsets.all(6),
//               //       decoration: BoxDecoration(
//               //         gradient: LinearGradient(
//               //           colors: [Colors.cyan.shade400, Colors.blue.shade400],
//               //         ),
//               //         shape: BoxShape.circle,
//               //       ),
//               //       child: const Icon(
//               //         Icons.analytics_rounded,
//               //         color: Colors.white,
//               //         size: 16,
//               //       ),
//               //     ),
//               //     const SizedBox(width: 12),
//               //     Expanded(
//               //       child: Text(
//               //         ' METRICS MATRIX',
//               //         style: TextStyle(
//               //           fontSize: 16,
//               //           fontWeight: FontWeight.w800,
//               //           color: Colors.white,
//               //           letterSpacing: 1.2,
//               //         ),
//               //       ),
//               //     ),
//               //   ],
//               // ),
//             ),

//             const SizedBox(height: 16),

//             // Metrics Grid
//             GridView.count(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: 2,
//               childAspectRatio: 1.2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               children: [
//                 _buildMetricCard(
//                   context,
//                   ' ATTENDANCE',
//                   widget.totalAttendance,
//                   Icons.people_alt_rounded,
//                   Colors.green.shade400,
//                   '',
//                 ),
//                 _buildMetricCard(
//                   context,
//                   'TOTAL TEAM',
//                   widget.teamMembers,
//                   Icons.group_rounded,
//                   Colors.cyan.shade400,
//                   '',
//                 ),
//                 _buildMetricCard(
//                   context,
//                   'PROJECT',
//                   widget.projects,
//                   Icons.work_rounded,
//                   Colors.orange.shade400,
//                   '',
//                 ),
//                 _buildMetricCard(
//                   context,
//                   'TIMELINE',
//                   widget.timeline,
//                   Icons.access_time_rounded,
//                   Colors.purple.shade400,
//                   '',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricCard(
//     BuildContext context,
//     String title,
//     dynamic value,
//     IconData icon,
//     Color color,
//     String subtitle,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
//         ),
//         border: Border.all(color: color.withOpacity(0.3), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Icon with Circular Background
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
//                   ),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: color.withOpacity(0.4), width: 1.5),
//                 ),
//                 child: Icon(icon, color: color, size: 20),
//               ),

//               const SizedBox(height: 12),

//               // Animated Counter/Value
//               if (value is int)
//                 AnimatedBuilder(
//                   animation: _animation,
//                   builder: (context, child) {
//                     final animatedValue = (value * _animation.value).toInt();
//                     return Text(
//                       animatedValue.toString(),
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w800,
//                         color: color,
//                         letterSpacing: 0.5,
//                       ),
//                     );
//                   },
//                 )
//               else
//                 Text(
//                   value.toString(),
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: color,
//                     letterSpacing: 0.5,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//               const SizedBox(height: 8),

//               // Title
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white.withOpacity(0.9),
//                   letterSpacing: 0.8,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//               ),

//               const SizedBox(height: 4),

//               // Subtitle
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: 8,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white.withOpacity(0.6),
//                   letterSpacing: 0.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
