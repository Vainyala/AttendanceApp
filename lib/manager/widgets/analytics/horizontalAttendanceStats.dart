import 'package:flutter/material.dart';

class HorizontalAttendanceStats extends StatelessWidget {
  final int totalEmployees;
  final int presentCount;
  final int leaveCount;
  final int absentCount;
  final int onTimeCount;
  final int lateCount;

  const HorizontalAttendanceStats({
    super.key,
    required this.totalEmployees,
    required this.presentCount,
    required this.leaveCount,
    required this.absentCount,
    required this.onTimeCount,
    required this.lateCount,
  });

  double _calculatePercentage(int count) {
    return totalEmployees > 0 ? (count / totalEmployees) * 100 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Team', totalEmployees, Colors.blue),
          _buildStatItem('Present', presentCount, Colors.green),
          _buildStatItem('Leave', leaveCount, Colors.orange),
          _buildStatItem('Absent', absentCount, Colors.red),
          _buildStatItem('OnTime', onTimeCount, Colors.teal),
          _buildStatItem('Late', lateCount, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_calculatePercentage(count).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 8, color: Colors.black54),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';

// class HorizontalAttendanceStats extends StatelessWidget {
//   final int totalEmployees;
//   final int presentCount;
//   final int leaveCount;
//   final int absentCount;
//   final int onTimeCount;
//   final int lateCount;

//   const HorizontalAttendanceStats({
//     super.key,
//     required this.totalEmployees,
//     required this.presentCount,
//     required this.leaveCount,
//     required this.absentCount,
//     required this.onTimeCount,
//     required this.lateCount,
//   });

//   double _calculatePercentage(int count) {
//     return totalEmployees > 0 ? (count / totalEmployees) * 100 : 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width,
//         minHeight: 70,
//         maxHeight: 85,
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _buildStatItem('Team', totalEmployees, 'Total', Colors.blue),
//           _buildStatItem(
//             'Present',
//             presentCount,
//             '${_calculatePercentage(presentCount).toStringAsFixed(1)}%',
//             Colors.green,
//           ),
//           _buildStatItem(
//             'Leave',
//             leaveCount,
//             '${_calculatePercentage(leaveCount).toStringAsFixed(1)}%',
//             Colors.orange,
//           ),
//           _buildStatItem(
//             'Absent',
//             absentCount,
//             '${_calculatePercentage(absentCount).toStringAsFixed(1)}%',
//             Colors.red,
//           ),
//           _buildStatItem(
//             'OnTime',
//             onTimeCount,
//             '${_calculatePercentage(onTimeCount).toStringAsFixed(1)}%',
//             Colors.teal,
//           ),
//           _buildStatItem(
//             'Late',
//             lateCount,
//             '${_calculatePercentage(lateCount).toStringAsFixed(1)}%',
//             Colors.amber,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(
//     String title,
//     int count,
//     String percentage,
//     Color color,
//   ) {
//     return Flexible(
//       fit: FlexFit.tight,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 2),
//         padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
//         constraints: BoxConstraints(
//           minWidth: 0, // Allow flexible width
//           maxWidth: 80, // Maximum width for each item
//         ),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(color: color.withOpacity(0.3)),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 9,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//               ),
//             ),
//             const SizedBox(height: 1),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 count.toString(),
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//                 maxLines: 1,
//               ),
//             ),
//             const SizedBox(height: 1),
//             FittedBox(
//               fit: BoxFit.scaleDown,
//               child: Text(
//                 percentage,
//                 style: const TextStyle(
//                   fontSize: 8,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black54,
//                 ),
//                 maxLines: 1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
