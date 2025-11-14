
class AttendanceRecord {
  final DateTime date;
  final String status;
  final String checkIn;
  final String checkOut;
  final double hours;

  AttendanceRecord({
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.hours,
  });

  String get dateFormatted {
    final day = date.day.toString().padLeft(2, '0');
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '$day/${months[date.month - 1]}/${date.year}';
  }

  String get dayName {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}