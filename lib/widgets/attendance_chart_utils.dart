import 'package:fl_chart/fl_chart.dart';
import '../models/attendance_model.dart';

class AttendanceChartUtils {
  static List<FlSpot> getChartData(List<AttendanceModel> weeklyAttendance) {
    Map<int, double> dailyHours = {};

    for (int i = 0; i < weeklyAttendance.length - 1; i += 2) {
      if (i + 1 < weeklyAttendance.length &&
          weeklyAttendance[i].type == AttendanceType.enter &&
          weeklyAttendance[i + 1].type == AttendanceType.exit) {
        final checkIn = weeklyAttendance[i];
        final checkOut = weeklyAttendance[i + 1];
        final day = checkIn.timestamp.weekday;
        final duration = checkOut.timestamp.difference(checkIn.timestamp);
        final hours = duration.inMinutes / 60.0;

        dailyHours[day] = (dailyHours[day] ?? 0) + hours;
      }
    }

    List<FlSpot> spots = [];
    for (int i = 1; i <= 7; i++) {
      spots.add(FlSpot(i.toDouble(), dailyHours[i] ?? 0));
    }

    return spots;
  }
}
