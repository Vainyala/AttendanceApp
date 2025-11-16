// import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
// import 'package:provider/provider.dart';
// import '../providers/analytics_provider.dart';
// import '../utils/app_colors.dart';
// import 'package:AttendanceApp/screens/attendance_analytics_screen.dart';
//
// class DateSelector extends StatelessWidget {
//   final VoidCallback onTap;
//
//   DateSelector({required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<AnalyticsProvider>(context);
//
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(
//             icon: Icon(Icons.chevron_left, size: 28),
//             onPressed: () {
//               if (_mode == AnalyticsMode.daily) {
//                 _changeDate(-1);
//               } else if (_mode == AnalyticsMode.weekly && _selectedWeekIndex < 3) {
//                 setState(() => _selectedWeekIndex++);
//               } else if (_mode == AnalyticsMode.monthly && _selectedMonthIndex < 3) {
//                 setState(() => _selectedMonthIndex++);
//               } else if (_mode == AnalyticsMode.quarterly && _selectedQuarterIndex < 3) {
//                 setState(() => _selectedQuarterIndex++);
//               }
//             },
//             color: AppColors.primaryBlue,
//             style: IconButton.styleFrom(
//               backgroundColor: AppColors.textLight,
//               shape: CircleBorder(),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 if (_mode == AnalyticsMode.daily) {
//                   _selectDate();
//                 } else if (_mode == AnalyticsMode.weekly) {
//                   _showWeekDrawer();
//                 } else if (_mode == AnalyticsMode.monthly) {
//                   _showMonthDrawer();
//                 } else if (_mode == AnalyticsMode.quarterly) {
//                   _showQuarterDrawer();
//                 }
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//                 decoration: BoxDecoration(
//                   color: AppColors.textLight,
//                   borderRadius: BorderRadius.circular(25),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 20),
//                     SizedBox(width: 12),
//                     Flexible(
//                       child: Text(
//                         _getDateLabel(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.textHint.shade800,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.chevron_right, size: 28),
//             onPressed: () {
//               if (_mode == AnalyticsMode.daily) {
//                 _changeDate(1);
//               } else if (_mode == AnalyticsMode.weekly && _selectedWeekIndex > 0) {
//                 setState(() => _selectedWeekIndex--);
//               } else if (_mode == AnalyticsMode.monthly && _selectedMonthIndex > 0) {
//                 setState(() => _selectedMonthIndex--);
//               } else if (_mode == AnalyticsMode.quarterly && _selectedQuarterIndex > 0) {
//                 setState(() => _selectedQuarterIndex--);
//               }
//             },
//             color: AppColors.primaryBlue,
//             style: IconButton.styleFrom(
//               backgroundColor: AppColors.textLight,
//               shape: CircleBorder(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
