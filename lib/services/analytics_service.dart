import '../models/attendance_model.dart';
import '../models/analytics_data.dart';
import '../screens/attendance_analytics_screen.dart';
import 'storage_service.dart';

class AnalyticsService {

  // Get summary for date range
  static Future<AttendanceSummary> getSummary(
      String userId,
      DateTime start,
      DateTime end,
      {String? projectId}
      ) async {
    final allAttendance = await StorageService.getAttendanceHistory();

    final filtered = allAttendance.where((record) {
      final matchesDate = record.timestamp.isAfter(start.subtract(Duration(days: 1))) &&
          record.timestamp.isBefore(end.add(Duration(days: 1)));
      final matchesUser = record.userId == userId;
      final matchesProject = projectId == null || record.projectName == projectId;

      return matchesDate && matchesUser && matchesProject;
    }).toList();

    // Group by date
    Map<String, List<AttendanceModel>> byDate = {};
    for (var record in filtered) {
      final dateKey = '${record.timestamp.year}-${record.timestamp.month}-${record.timestamp.day}';
      byDate.putIfAbsent(dateKey, () => []).add(record);
    }

    int present = 0, absent = 0, late = 0, halfDay = 0;
    double totalHours = 0;

    byDate.forEach((date, records) {
      records.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      if (records.isEmpty) {
        absent++;
      } else {
        final checkIn = records.firstWhere(
              (r) => r.type == AttendanceType.enter || r.type == AttendanceType.checkIn,
          orElse: () => records.first,
        );

        final checkOut = records.lastWhere(
              (r) => r.type == AttendanceType.exit || r.type == AttendanceType.checkOut,
          orElse: () => records.last,
        );

        if (checkIn.isLate) late++;

        final duration = checkIn.getDuration(checkOut);
        if (duration != null) {
          final hours = duration.inMinutes / 60.0;
          totalHours += hours;

          if (hours < 4) {
            halfDay++;
          } else {
            present++;
          }
        } else {
          present++;
        }
      }
    });

    return AttendanceSummary(
      present: present,
      absent: absent,
      late: late,
      halfDay: halfDay,
      avgHours: byDate.isNotEmpty ? totalHours / byDate.length : 0,
    );
  }

  // Get daily records
  static Future<List<AttendanceModel>> getDailyRecords(
      String userId,
      DateTime date,
      {String? projectId}
      ) async {
    final allAttendance = await StorageService.getAttendanceHistory();

    return allAttendance.where((record) {
      final matchesDate = record.timestamp.year == date.year &&
          record.timestamp.month == date.month &&
          record.timestamp.day == date.day;
      final matchesUser = record.userId == userId;
      final matchesProject = projectId == null || record.projectName == projectId;

      return matchesDate && matchesUser && matchesProject;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get chart data for weekly/monthly view
  static Map<String, double> getChartData(
      List<AttendanceModel> records,
      AnalyticsMode mode,
      ) {
    Map<String, double> data = {};

    // Group by date and calculate hours
    Map<String, List<AttendanceModel>> byDate = {};
    for (var record in records) {
      String key;
      if (mode == AnalyticsMode.daily) {
        key = '${record.timestamp.hour}:00';
      } else {
        key = '${record.timestamp.year}-${record.timestamp.month}-${record.timestamp.day}';
      }
      byDate.putIfAbsent(key, () => []).add(record);
    }

    byDate.forEach((key, records) {
      records.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final checkIn = records.firstWhere(
            (r) => r.type == AttendanceType.enter || r.type == AttendanceType.checkIn,
        orElse: () => records.first,
      );

      final checkOut = records.lastWhere(
            (r) => r.type == AttendanceType.exit || r.type == AttendanceType.checkOut,
        orElse: () => records.last,
      );

      final duration = checkIn.getDuration(checkOut);
      data[key] = duration != null ? duration.inMinutes / 60.0 : 0;
    });

    return data;
  }
}