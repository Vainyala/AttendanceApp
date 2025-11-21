
import '../widgets/date_time_utils.dart';

class AttendanceRecords {
  final DateTime date;
  final String status;
  final String checkIn;
  final String checkOut;
  final double hours;

  AttendanceRecords({
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.hours,
  });

  String get dateFormatted {
    final day = date.day.toString().padLeft(2, '0');
    final monthName = DateTimeUtils.months[date.month];

    return "$day/$monthName/${date.year}";
  }



  String get dayName {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}