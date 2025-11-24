// import 'package:attendanceapp/manager/views/managerviews/fake_employee_leavescreen.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MonthlyOverviewWidget extends StatelessWidget {
//   final bool isDarkMode;
//   final Map<String, int>? counters;
//   final VoidCallback? onTap;

//   const MonthlyOverviewWidget({
//     Key? key,
//     required this.isDarkMode,
//     this.counters,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final Map<String, int> displayCounters = counters ?? _getDefaultCounters();

//     return GestureDetector(
//       onTap:
//           onTap ??
//           () {
//             // Default behavior - EmployeeLeavesScreen open karega
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => EmployeeLeavesScreen()),
//             );
//           },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//         decoration: BoxDecoration(
//           color: isDarkMode ? Colors.grey[900] : Colors.white,
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(24),
//             bottomRight: Radius.circular(24),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 16,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.analytics_rounded,
//                     color: Colors.blue,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Monthly Overview - ${DateFormat('MMMM yyyy').format(DateTime.now())}',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: isDarkMode ? Colors.white : Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 _buildStatItem(
//                   'Total',
//                   displayCounters['total']!.toString(),
//                   Colors.blue,
//                   isDarkMode,
//                 ),
//                 _buildStatDivider(isDarkMode),
//                 _buildStatItem(
//                   'Pending',
//                   displayCounters['pending']!.toString(),
//                   Colors.orange,
//                   isDarkMode,
//                 ),
//                 _buildStatDivider(isDarkMode),
//                 _buildStatItem(
//                   'Approved',
//                   displayCounters['approved']!.toString(),
//                   Colors.green,
//                   isDarkMode,
//                 ),
//                 _buildStatDivider(isDarkMode),
//                 _buildStatItem(
//                   'Rejected',
//                   displayCounters['rejected']!.toString(),
//                   Colors.red,
//                   isDarkMode,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(
//     String title,
//     String value,
//     Color color,
//     bool isDarkMode,
//   ) {
//     return Expanded(
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatDivider(bool isDarkMode) {
//     return Container(
//       width: 1,
//       height: 30,
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
//     );
//   }

//   Map<String, int> _getDefaultCounters() {
//     return {'total': 28, 'pending': 8, 'approved': 16, 'rejected': 4};
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyOverviewWidget extends StatelessWidget {
  final bool isDarkMode;
  final Map<String, int>? counters;

  const MonthlyOverviewWidget({
    Key? key,
    required this.isDarkMode,
    this.counters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, int> displayCounters = counters ?? _getDefaultCounters();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Monthly Overview - ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                'Total',
                displayCounters['total']!.toString(),
                Colors.blue,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Pending',
                displayCounters['pending']!.toString(),
                Colors.orange,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Approved',
                displayCounters['approved']!.toString(),
                Colors.green,
                isDarkMode,
              ),
              _buildStatDivider(isDarkMode),
              _buildStatItem(
                'Rejected',
                displayCounters['rejected']!.toString(),
                Colors.red,
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDarkMode) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
    );
  }

  Map<String, int> _getDefaultCounters() {
    return {'total': 28, 'pending': 8, 'approved': 16, 'rejected': 4};
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// Widget _buildMonthlyOverview(bool isDarkMode) {
//   // Realistic fake data - month ke hisaab se
//   final Map<String, int> fakeCounters = {
//     'total': 28, // Typical month mein 25-30 requests
//     'pending': 8, // 8 pending requests
//     'approved': 16, // 16 approved
//     'rejected': 4, // 4 rejected
//   };

//   return Container(
//     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//     decoration: BoxDecoration(
//       color: isDarkMode ? Colors.grey[900] : Colors.white,
//       borderRadius: const BorderRadius.only(
//         bottomLeft: Radius.circular(24),
//         bottomRight: Radius.circular(24),
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 16,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Icons.analytics_rounded,
//                 color: Colors.blue,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Monthly Overview - ${DateFormat('MMMM yyyy').format(DateTime.now())}',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: isDarkMode ? Colors.white : Colors.black,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             _buildStatItem(
//               'Total',
//               fakeCounters['total']!.toString(),
//               Colors.blue,
//               isDarkMode,
//             ),
//             _buildStatDivider(isDarkMode),
//             _buildStatItem(
//               'Pending',
//               fakeCounters['pending']!.toString(),
//               Colors.orange,
//               isDarkMode,
//             ),
//             _buildStatDivider(isDarkMode),
//             _buildStatItem(
//               'Approved',
//               fakeCounters['approved']!.toString(),
//               Colors.green,
//               isDarkMode,
//             ),
//             _buildStatDivider(isDarkMode),
//             _buildStatItem(
//               'Rejected',
//               fakeCounters['rejected']!.toString(),
//               Colors.red,
//               isDarkMode,
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildStatItem(
//   String title,
//   String value,
//   Color color,
//   bool isDarkMode,
// ) {
//   return Expanded(
//     child: Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 12,
//             color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildStatDivider(bool isDarkMode) {
//   return Container(
//     width: 1,
//     height: 30,
//     margin: const EdgeInsets.symmetric(horizontal: 8),
//     color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
//   );
// }
