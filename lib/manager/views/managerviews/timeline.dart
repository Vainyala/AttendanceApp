import 'package:attendanceapp/manager/core/widgets/bottom_navigation.dart';
import 'package:attendanceapp/manager/models/user_model.dart';
import 'package:attendanceapp/manager/views/managerviews/leavescreen.dart';
import 'package:attendanceapp/manager/views/managerviews/manager_dashboard_screen.dart';
import 'package:attendanceapp/manager/views/managerviews/manager_regularisation_screen.dart';
import 'package:attendanceapp/manager/views/managerviews/regularisation_screen.dart';
import 'package:flutter/material.dart';
import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';

class TimelineScreen extends StatelessWidget {
  final User user;
  const TimelineScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Project Timeline',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        backgroundColor: AppColors.grey300,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.secondary.withOpacity(0.1),
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Stats
              _buildHeaderStats(),
              const SizedBox(height: 2),

              // Timeline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTimeline(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: 3,
        onTabChanged: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ManagerDashboardScreen(user: user),
              ),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManagerRegularisationScreen(user: user),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManagerLeaveScreen(user: user),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [AppColors.primary, AppColors.primaryDark],
        // ),
      ),
      child: Column(
        children: [
          const Text(
            'Project Progress Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('75%', 'Completed', Icons.check_circle_rounded),
              _buildStatItem('3', 'Active', Icons.play_arrow_rounded),
              _buildStatItem('1', 'Pending', Icons.schedule_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    final timelineEvents = [
      TimelineEvent(
        title: 'Project Kickoff',
        description: 'Initial meeting with client and team alignment',
        date: '15 Jan 2024',
        time: '10:00 AM',
        status: 'completed',
        icon: Icons.flag_rounded,
      ),
      TimelineEvent(
        title: 'Requirements Gathering',
        description: 'Detailed requirements analysis and documentation',
        date: '20 Jan 2024',
        time: '2:30 PM',
        status: 'completed',
        icon: Icons.description_rounded,
      ),
      TimelineEvent(
        title: 'UI/UX Design',
        description: 'Wireframing and prototype development',
        date: '25 Jan 2024',
        time: '11:00 AM',
        status: 'completed',
        icon: Icons.design_services_rounded,
      ),
      TimelineEvent(
        title: 'Frontend Development',
        description: 'Flutter app development and implementation',
        date: '05 Feb 2024',
        time: '9:00 AM',
        status: 'in-progress',
        icon: Icons.code_rounded,
      ),
      TimelineEvent(
        title: 'Backend Integration',
        description: 'API development and database setup',
        date: '15 Feb 2024',
        time: '10:00 AM',
        status: 'pending',
        icon: Icons.storage_rounded,
      ),
      TimelineEvent(
        title: 'Testing Phase',
        description: 'Quality assurance and bug fixing',
        date: '25 Feb 2024',
        time: '3:00 PM',
        status: 'pending',
        icon: Icons.bug_report_rounded,
      ),
      TimelineEvent(
        title: 'Deployment',
        description: 'Production deployment and launch',
        date: '05 Mar 2024',
        time: '11:00 AM',
        status: 'pending',
        icon: Icons.rocket_launch_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Project Timeline',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...timelineEvents.asMap().entries.map(
            (entry) => _buildTimelineItem(
              entry.value,
              entry.key,
              timelineEvents.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineEvent event, int index, int totalItems) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          Column(
            children: [
              // Top connector line (except for first item)
              if (index > 0)
                Container(
                  width: 2,
                  height: 20,
                  color: _getStatusColor(event.status).withOpacity(0.2),
                ),

              // Timeline dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getStatusColor(event.status),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),

              // Bottom connector line (except for last item)
              if (index < totalItems - 1)
                Container(
                  width: 2,
                  height: 20,
                  color: _getStatusColor(event.status).withOpacity(0.2),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Event content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(event.status).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(event.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          event.icon,
                          size: 16,
                          color: _getStatusColor(event.status),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(event.status),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(event.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(event.status),
                          style: TextStyle(
                            color: _getStatusColor(event.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in-progress':
        return AppColors.warning;
      case 'pending':
        return AppColors.info;
      default:
        return AppColors.grey500;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'DONE';
      case 'in-progress':
        return 'IN PROGRESS';
      case 'pending':
        return 'UPCOMING';
      default:
        return 'UNKNOWN';
    }
  }
}

class TimelineEvent {
  final String title;
  final String description;
  final String date;
  final String time;
  final String status;
  final IconData icon;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.icon,
  });
}

// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/views/managerviews/leavescreen.dart';
// import 'package:attendanceapp/views/managerviews/manager_dashboard_screen.dart';
// import 'package:attendanceapp/views/managerviews/regularisation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';

// class TimelineScreen extends StatelessWidget {
//   final User user;
//   const TimelineScreen({super.key, required this.user});

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     backgroundColor: Colors.grey.shade50,
//   //     appBar: AppBar(
//   //       title: const Text(
//   //         'Project Timeline',
//   //         style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
//   //       ),
//   //       backgroundColor: AppColors.primary,
//   //       elevation: 0,
//   //       centerTitle: true,
//   //     ),
//   //     body: SingleChildScrollView(
//   //       physics: const BouncingScrollPhysics(),
//   //       child: Column(
//   //         children: [
//   //           // Header Stats
//   //           _buildHeaderStats(),
//   //           const SizedBox(height: 20),

//   //           // Timeline
//   //           Padding(
//   //             padding: const EdgeInsets.symmetric(horizontal: 16),
//   //             child: _buildTimeline(),
//   //           ),

//   //           const SizedBox(height: 30),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           Colors.transparent, // ✅ Colors.grey.shade50 se change kiya
//       appBar: AppBar(
//         title: const Text(
//           'Project Timeline',
//           style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
//         ),
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Container(
//         // ✅ Container add kiya
//         decoration: BoxDecoration(
//           // ✅ Gradient decoration add kiya
//           gradient: RadialGradient(
//             center: Alignment.topLeft,
//             radius: 2.0,
//             colors: [
//               QuickAIColors.cyber.primary.withOpacity(0.3),
//               QuickAIColors.cyber.secondary.withOpacity(0.2),
//               Colors.black,
//             ],
//             stops: const [0.0, 0.5, 1.0],
//           ),
//         ),
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             children: [
//               // Header Stats
//               _buildHeaderStats(),
//               const SizedBox(height: 20),

//               // Timeline
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _buildTimeline(),
//               ),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: 3,
//         onTabChanged: (index) {
//           if (index == 0) {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ManagerDashboardScreen(user: user),
//               ), // ✅ Yahan user use karo
//               (route) => false,
//             );
//           } else if (index == 1) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => RegularisationScreen(user: user),
//               ), // ✅ User pass karo
//             );
//           } else if (index == 2) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => LeaveScreen(user: user),
//               ), // ✅ User pass karo
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildHeaderStats() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.primary, AppColors.secondary],
//         ),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             'Project Progress Overview',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatItem('75%', 'Completed', Icons.check_circle_rounded),
//               _buildStatItem('3', 'Active', Icons.play_arrow_rounded),
//               _buildStatItem('1', 'Pending', Icons.schedule_rounded),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String value, String label, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.white, size: 20),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
//         ),
//       ],
//     );
//   }

//   Widget _buildTimeline() {
//     final timelineEvents = [
//       TimelineEvent(
//         title: 'Project Kickoff',
//         description: 'Initial meeting with client and team alignment',
//         date: '15 Jan 2024',
//         time: '10:00 AM',
//         status: 'completed',
//         icon: Icons.flag_rounded,
//       ),
//       TimelineEvent(
//         title: 'Requirements Gathering',
//         description: 'Detailed requirements analysis and documentation',
//         date: '20 Jan 2024',
//         time: '2:30 PM',
//         status: 'completed',
//         icon: Icons.description_rounded,
//       ),
//       TimelineEvent(
//         title: 'UI/UX Design',
//         description: 'Wireframing and prototype development',
//         date: '25 Jan 2024',
//         time: '11:00 AM',
//         status: 'completed',
//         icon: Icons.design_services_rounded,
//       ),
//       TimelineEvent(
//         title: 'Frontend Development',
//         description: 'Flutter app development and implementation',
//         date: '05 Feb 2024',
//         time: '9:00 AM',
//         status: 'in-progress',
//         icon: Icons.code_rounded,
//       ),
//       TimelineEvent(
//         title: 'Backend Integration',
//         description: 'API development and database setup',
//         date: '15 Feb 2024',
//         time: '10:00 AM',
//         status: 'pending',
//         icon: Icons.storage_rounded,
//       ),
//       TimelineEvent(
//         title: 'Testing Phase',
//         description: 'Quality assurance and bug fixing',
//         date: '25 Feb 2024',
//         time: '3:00 PM',
//         status: 'pending',
//         icon: Icons.bug_report_rounded,
//       ),
//       TimelineEvent(
//         title: 'Deployment',
//         description: 'Production deployment and launch',
//         date: '05 Mar 2024',
//         time: '11:00 AM',
//         status: 'pending',
//         icon: Icons.rocket_launch_rounded,
//       ),
//     ];

//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.timeline_rounded,
//                   color: AppColors.primary,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'Project Timeline',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...timelineEvents.asMap().entries.map(
//               (entry) => _buildTimelineItem(
//                 entry.value,
//                 entry.key,
//                 timelineEvents.length,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimelineItem(TimelineEvent event, int index, int totalItems) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Timeline line and dot
//           Column(
//             children: [
//               // Top connector line (except for first item)
//               if (index > 0)
//                 Container(
//                   width: 2,
//                   height: 20,
//                   color: _getStatusColor(event.status).withOpacity(0.3),
//                 ),

//               // Timeline dot
//               Container(
//                 width: 20,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(event.status),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 3),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _getStatusColor(event.status).withOpacity(0.5),
//                       blurRadius: 8,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//               ),

//               // Bottom connector line (except for last item)
//               if (index < totalItems - 1)
//                 Container(
//                   width: 2,
//                   height: 20,
//                   color: _getStatusColor(event.status).withOpacity(0.3),
//                 ),
//             ],
//           ),

//           const SizedBox(width: 16),

//           // Event content
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _getStatusColor(event.status).withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: _getStatusColor(event.status).withOpacity(0.2),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: _getStatusColor(event.status).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           event.icon,
//                           size: 16,
//                           color: _getStatusColor(event.status),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           event.title,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: _getStatusColor(event.status),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: _getStatusColor(event.status).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           _getStatusText(event.status),
//                           style: TextStyle(
//                             color: _getStatusColor(event.status),
//                             fontSize: 10,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     event.description,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                       height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.calendar_today_rounded,
//                         size: 12,
//                         color: Colors.grey.shade500,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         event.date,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Icon(
//                         Icons.access_time_rounded,
//                         size: 12,
//                         color: Colors.grey.shade500,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         event.time,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'completed':
//         return Colors.green;
//       case 'in-progress':
//         return Colors.orange;
//       case 'pending':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status) {
//       case 'completed':
//         return 'DONE';
//       case 'in-progress':
//         return 'IN PROGRESS';
//       case 'pending':
//         return 'UPCOMING';
//       default:
//         return 'UNKNOWN';
//     }
//   }
// }

// class TimelineEvent {
//   final String title;
//   final String description;
//   final String date;
//   final String time;
//   final String status;
//   final IconData icon;

//   TimelineEvent({
//     required this.title,
//     required this.description,
//     required this.date,
//     required this.time,
//     required this.status,
//     required this.icon,
//   });
// }
