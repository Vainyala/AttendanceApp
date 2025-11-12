class AttendanceSummary {
  final int present;
  final int absent;
  final int late;
  final int halfDay;
  final double avgHours;

  AttendanceSummary({
    required this.present,
    required this.absent,
    required this.late,
    required this.halfDay,
    required this.avgHours,
  });
}

enum AnalyticsMode { daily, weekly, monthly, quarterly }

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);
}