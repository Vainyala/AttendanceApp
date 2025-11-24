// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class EmployeeLeavesScreen extends StatelessWidget {
//   final String employeeName;
//   final String employeeId;
//   final String department;
//   final String designation;

//   const EmployeeLeavesScreen({
//     Key? key,
//     this.employeeName = 'Rajesh Kumar',
//     this.employeeId = 'EMP-2024',
//     this.department = 'Flutter Development',
//     this.designation = 'Senior Developer',
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     // Fake employee data - specific employee ke liye
//     final employeeData = {
//       'name': employeeName,
//       'employeeId': employeeId,
//       'department': department,
//       'designation': designation,
//     };

//     // Fake monthly leaves data - specific employee ke liye
//     final monthlyLeaves = {
//       'pending': 3,
//       'approved': 8,
//       'rejected': 2,
//       'total': 13,
//     };

//     // Fake leave requests list - specific employee ke liye
//     final List<Map<String, dynamic>> leaveRequests = [
//       {
//         'id': 'LV-001',
//         'type': 'Sick Leave',
//         'from': DateTime(2024, 1, 15),
//         'to': DateTime(2024, 1, 16),
//         'days': 2,
//         'status': 'approved',
//         'appliedOn': DateTime(2024, 1, 10),
//       },
//       {
//         'id': 'LV-002',
//         'type': 'Casual Leave',
//         'from': DateTime(2024, 1, 20),
//         'to': DateTime(2024, 1, 20),
//         'days': 1,
//         'status': 'pending',
//         'appliedOn': DateTime(2024, 1, 18),
//       },
//       {
//         'id': 'LV-003',
//         'type': 'Annual Leave',
//         'from': DateTime(2024, 1, 25),
//         'to': DateTime(2024, 1, 27),
//         'days': 3,
//         'status': 'pending',
//         'appliedOn': DateTime(2024, 1, 22),
//       },
//       {
//         'id': 'LV-004',
//         'type': 'Emergency Leave',
//         'from': DateTime(2024, 1, 5),
//         'to': DateTime(2024, 1, 5),
//         'days': 1,
//         'status': 'rejected',
//         'appliedOn': DateTime(2024, 1, 4),
//       },
//       {
//         'id': 'LV-005',
//         'type': 'Work From Home',
//         'from': DateTime(2024, 1, 12),
//         'to': DateTime(2024, 1, 12),
//         'days': 1,
//         'status': 'approved',
//         'appliedOn': DateTime(2024, 1, 10),
//       },
//     ];

//     return Scaffold(
//       backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
//       appBar: AppBar(
//         title: Text('$employeeName - Leave History'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Employee Card
//             _buildEmployeeCard(employeeData, isDarkMode),
//             const SizedBox(height: 20),

//             // Monthly Overview
//             _buildMonthlyOverview(monthlyLeaves, isDarkMode),
//             const SizedBox(height: 20),

//             // Leave Requests Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Leave Requests',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: isDarkMode ? Colors.white : Colors.black,
//                   ),
//                 ),
//                 Text(
//                   '${DateFormat('MMMM yyyy').format(DateTime.now())}',
//                   style: TextStyle(
//                     color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Leave Requests List
//             _buildLeaveRequestsList(leaveRequests, isDarkMode),
//           ],
//         ),
//       ),
//     );
//   }

//   // ... (same _buildEmployeeCard, _buildMonthlyOverview, _buildStatItem,
//   // _buildStatDivider, _buildLeaveRequestsList, _buildLeaveRequestItem methods
//   // jo pehle diye the wahi rahenge)
// }
