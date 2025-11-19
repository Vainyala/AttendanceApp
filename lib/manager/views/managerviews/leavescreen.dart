
import 'package:AttendanceApp/manager/views/managerviews/timeline.dart';
import 'package:flutter/material.dart';

import '../../core/view_models/theme_view_model.dart';
import '../../core/widgets/bottom_navigation.dart';
import '../../models/user_model.dart';
import 'manager_dashboard_screen.dart';
import 'manager_regularisation_screen.dart';

class LeaveScreen extends StatelessWidget {
  final User user;

  const LeaveScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Leave Management',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Leave Balance Cards
                _buildLeaveBalanceSection(),
                const SizedBox(height: 20),

                // Quick Actions
                // _buildQuickActions(),
                // const SizedBox(height: 20),

                // Leave Applications
                _buildLeaveApplications(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ManagerBottomNavigation(
        currentIndex: 2,
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
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimelineScreen(user: user),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLeaveBalanceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.beach_access, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Leave Balance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildLeaveBalanceCard('Casual Leave', '12/18', Colors.blue),
                _buildLeaveBalanceCard('Sick Leave', '8/12', Colors.green),
                _buildLeaveBalanceCard('Earned Leave', '15/20', Colors.orange),
                _buildLeaveBalanceCard(
                  'Maternity Leave',
                  '84/90',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCard(String title, String balance, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            balance,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            'Days Available',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton('Apply Leave', Icons.add, Colors.blue),
                _buildActionButton(
                  'Leave History',
                  Icons.history,
                  Colors.green,
                ),
                _buildActionButton('Team Leaves', Icons.people, Colors.orange),
                _buildActionButton('Policy', Icons.description, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLeaveApplications() {
    final leaveApplications = [
      LeaveApplication(
        employeeName: 'Raj Sharma',
        leaveType: 'Casual Leave',
        duration: '2 days',
        dates: '15-16 Mar 2024',
        status: 'pending',
      ),
      LeaveApplication(
        employeeName: 'Priya Singh',
        leaveType: 'Sick Leave',
        duration: '1 day',
        dates: '18 Mar 2024',
        status: 'approved',
      ),
      LeaveApplication(
        employeeName: 'Amit Kumar',
        leaveType: 'Earned Leave',
        duration: '5 days',
        dates: '20-24 Mar 2024',
        status: 'rejected',
      ),
      LeaveApplication(
        employeeName: 'Neha Patel',
        leaveType: 'Maternity Leave',
        duration: '90 days',
        dates: '01 Apr - 30 Jun 2024',
        status: 'pending',
      ),
    ];

    final pendingCount = leaveApplications
        .where((app) => app.status == 'pending')
        .length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pending_actions, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Pending Approvals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pendingCount Pending',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...leaveApplications.map(
              (application) => _buildLeaveApplicationCard(application),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveApplicationCard(LeaveApplication application) {
    Color statusColor;
    String statusText;

    switch (application.status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'APPROVED';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'REJECTED';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'PENDING';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getColorFromName(application.employeeName),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(application.employeeName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Application Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.employeeName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${application.leaveType} • ${application.duration}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  application.dates,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    final index = name.length % colors.length;
    return colors[index];
  }

  String _getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
  }
}

class LeaveApplication {
  final String employeeName;
  final String leaveType;
  final String duration;
  final String dates;
  final String status;

  LeaveApplication({
    required this.employeeName,
    required this.leaveType,
    required this.duration,
    required this.dates,
    required this.status,
  });
}

// import 'package:attendanceapp/core/widgets/bottom_navigation.dart';
// import 'package:attendanceapp/models/user_model.dart';
// import 'package:attendanceapp/views/managerviews/manager_dashboard_screen.dart';
// import 'package:attendanceapp/views/managerviews/regularisation_screen.dart';
// import 'package:attendanceapp/views/managerviews/timeline.dart';
// import 'package:flutter/material.dart';
// import 'package:attendanceapp/core/view_models/theme_view_model.dart';

// class LeaveScreen extends StatelessWidget {
//   final User user; // ✅ User parameter add karo

//   const LeaveScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text(
//           'Leave Management',
//           style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
//         ),
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Container(
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
//               // Leave Balance Cards
//               _buildLeaveBalanceSection(),
//               const SizedBox(height: 20),

//               // Quick Actions
//               _buildQuickActions(),
//               const SizedBox(height: 20),

//               // Leave Applications
//               _buildLeaveApplications(),

//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: ManagerBottomNavigation(
//         currentIndex: 2,
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
//           } else if (index == 3) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => TimelineScreen(user: user),
//               ), // ✅ User pass karo
//             );
//           }
//         },
//       ),
//     );
//   }

//   // ... baaki methods same rahenge

//   Widget _buildLeaveBalanceSection() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Header
//           Row(
//             children: [
//               Icon(
//                 Icons.beach_access_rounded,
//                 color: AppColors.primary,
//                 size: 24,
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Leave Balance',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Leave Balance Cards
//           Row(
//             children: [
//               Expanded(
//                 child: _buildLeaveBalanceCard(
//                   'Casual Leave',
//                   '12/18',
//                   Colors.blue.shade600,
//                   Icons.beach_access_rounded,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildLeaveBalanceCard(
//                   'Sick Leave',
//                   '8/12',
//                   Colors.green.shade600,
//                   Icons.medical_services_rounded,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildLeaveBalanceCard(
//                   'Earned Leave',
//                   '15/20',
//                   Colors.orange.shade600,
//                   Icons.work_history_rounded,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildLeaveBalanceCard(
//                   'Maternity Leave',
//                   '84/90',
//                   Colors.purple.shade600,
//                   Icons.family_restroom_rounded,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLeaveBalanceCard(
//     String title,
//     String balance,
//     Color color,
//     IconData icon,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, color: color, size: 18),
//               ),
//               const Spacer(),
//               Text(
//                 balance,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Days Available',
//             style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 24),
//               const SizedBox(width: 10),
//               const Text(
//                 'Quick Actions',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildActionButton(
//                 'Apply Leave',
//                 Icons.add_circle_outline_rounded,
//                 Colors.blue.shade600,
//               ),
//               _buildActionButton(
//                 'Leave History',
//                 Icons.history_rounded,
//                 Colors.green.shade600,
//               ),
//               _buildActionButton(
//                 'Team Leaves',
//                 Icons.people_alt_rounded,
//                 Colors.orange.shade600,
//               ),
//               _buildActionButton(
//                 'Policy',
//                 Icons.description_rounded,
//                 Colors.purple.shade600,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton(String label, IconData icon, Color color) {
//     return Column(
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Icon(icon, color: color, size: 24),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade700,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildLeaveApplications() {
//     final leaveApplications = [
//       LeaveApplication(
//         employeeName: 'Raj Sharma',
//         leaveType: 'Casual Leave',
//         duration: '2 days',
//         dates: '15-16 Mar 2024',
//         status: 'pending',
//         profileColor: Colors.blue.shade600,
//       ),
//       LeaveApplication(
//         employeeName: 'Priya Singh',
//         leaveType: 'Sick Leave',
//         duration: '1 day',
//         dates: '18 Mar 2024',
//         status: 'approved',
//         profileColor: Colors.green.shade600,
//       ),
//       LeaveApplication(
//         employeeName: 'Amit Kumar',
//         leaveType: 'Earned Leave',
//         duration: '5 days',
//         dates: '20-24 Mar 2024',
//         status: 'rejected',
//         profileColor: Colors.orange.shade600,
//       ),
//       LeaveApplication(
//         employeeName: 'Neha Patel',
//         leaveType: 'Maternity Leave',
//         duration: '90 days',
//         dates: '01 Apr - 30 Jun 2024',
//         status: 'pending',
//         profileColor: Colors.purple.shade600,
//       ),
//     ];

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.pending_actions_rounded,
//                 color: AppColors.primary,
//                 size: 24,
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Pending Approvals',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${leaveApplications.where((app) => app.status == 'pending').length} Pending',
//                   style: TextStyle(
//                     color: Colors.blue.shade700,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ...leaveApplications.map(
//             (application) => _buildLeaveApplicationCard(application),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLeaveApplicationCard(LeaveApplication application) {
//     Color statusColor;
//     String statusText;

//     switch (application.status) {
//       case 'approved':
//         statusColor = Colors.green;
//         statusText = 'APPROVED';
//         break;
//       case 'rejected':
//         statusColor = Colors.red;
//         statusText = 'REJECTED';
//         break;
//       default:
//         statusColor = Colors.orange;
//         statusText = 'PENDING';
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           // Profile Avatar
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: application.profileColor,
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 _getInitials(application.employeeName),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Application Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   application.employeeName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '${application.leaveType} • ${application.duration}',
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   application.dates,
//                   style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),

//           // Status Badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: statusColor.withOpacity(0.3)),
//             ),
//             child: Text(
//               statusText,
//               style: TextStyle(
//                 color: statusColor,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getInitials(String name) {
//     return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
//   }
// }

// class LeaveApplication {
//   final String employeeName;
//   final String leaveType;
//   final String duration;
//   final String dates;
//   final String status;
//   final Color profileColor;

//   LeaveApplication({
//     required this.employeeName,
//     required this.leaveType,
//     required this.duration,
//     required this.dates,
//     required this.status,
//     required this.profileColor,
//   });
// }
