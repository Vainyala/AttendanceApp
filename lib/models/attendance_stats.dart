class AttendanceStats {
  final int present;
  final int absent;
  final int late;
  final int leave;
  final int totalDays;
  final int attendancePercentage;

  AttendanceStats({
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.totalDays,
    required this.attendancePercentage,
  });
}
