
import 'package:intl/intl.dart';

import '../../models/attendancemodels/attendance_analytics_model.dart';
import '../../models/team_model.dart';

class AttendanceAnalyticsService {
  AttendanceAnalytics generateAnalytics(
    List<TeamMember> teamMembers,
    String period, {
    DateTime? selectedDate,
  }) {
    final date = selectedDate ?? DateTime.now();
    final labels = _getGraphLabels(period, date);
    final graphData = _generateGraphData(teamMembers, period, labels, date);
    final individualData = _generateIndividualData(teamMembers, period, date);
    final statistics = _calculateStatistics(individualData, teamMembers.length);

    return AttendanceAnalytics(
      period: period,
      graphData: graphData,
      individualData: individualData,
      statistics: statistics,
      labels: labels,
    );
  }

  Map<String, List<double>> _generateGraphData(
    List<TeamMember> teamMembers,
    String period,
    List<String> labels,
    DateTime selectedDate,
  ) {
    Map<String, List<double>> graphData = {
      'present': List.filled(labels.length, 0.0),
      'late': List.filled(labels.length, 0.0),
      'absent': List.filled(labels.length, 0.0),
    };

    // Generate date-aware data based on selected period and date
    for (int i = 0; i < labels.length; i++) {
      switch (period) {
        case 'daily':
          // Generate data based on day of week
          final dayOfWeek = selectedDate.weekday;
          double basePresent =
              teamMembers.length * _getDailyAttendanceRate(dayOfWeek);
          double baseLate = teamMembers.length * _getDailyLateRate(dayOfWeek);
          double baseAbsent =
              teamMembers.length * _getDailyAbsentRate(dayOfWeek);

          // Adjust based on time of day
          if (i < 2) {
            // Morning (9AM, 11AM)
            graphData['present']![i] = (basePresent * 0.95);
            graphData['late']![i] = (baseLate * 0.8);
            graphData['absent']![i] = (baseAbsent * 0.7);
          } else if (i < 4) {
            // Afternoon (1PM, 3PM)
            graphData['present']![i] = (basePresent * 0.85);
            graphData['late']![i] = (baseLate * 1.2);
            graphData['absent']![i] = (baseAbsent * 1.1);
          } else {
            // Evening (5PM, 7PM)
            graphData['present']![i] = (basePresent * 0.9);
            graphData['late']![i] = (baseLate * 0.9);
            graphData['absent']![i] = (baseAbsent * 0.9);
          }
          break;

        case 'weekly':
          // Generate weekly data based on selected week
          final weekMultiplier = _getWeekMultiplier(selectedDate);
          double multiplier = 1.0;
          switch (i) {
            case 0: // Monday
              multiplier = 0.85 * weekMultiplier;
              break;
            case 1: // Tuesday
              multiplier = 0.95 * weekMultiplier;
              break;
            case 2: // Wednesday
              multiplier = 1.0 * weekMultiplier;
              break;
            case 3: // Thursday
              multiplier = 0.98 * weekMultiplier;
              break;
            case 4: // Friday
              multiplier = 0.92 * weekMultiplier;
              break;
            case 5: // Saturday
              multiplier = 0.75 * weekMultiplier;
              break;
          }
          graphData['present']![i] = (teamMembers.length * 0.8 * multiplier);
          graphData['late']![i] =
              (teamMembers.length * 0.12 * (2 - multiplier));
          graphData['absent']![i] =
              (teamMembers.length * 0.08 * (2 - multiplier));
          break;

        case 'monthly':
          // Generate monthly data based on selected month
          final monthMultiplier = _getMonthMultiplier(selectedDate.month);
          double presentMultiplier = (1.0 - (i * 0.05)) * monthMultiplier;
          double absentMultiplier = (0.8 + (i * 0.05)) * (2 - monthMultiplier);

          graphData['present']![i] =
              (teamMembers.length * 0.85 * presentMultiplier);
          graphData['late']![i] = (teamMembers.length * 0.1);
          graphData['absent']![i] =
              (teamMembers.length * 0.05 * absentMultiplier);
          break;

        case 'quarterly':
          // Generate quarterly data
          final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
          final quarterMultiplier = _getQuarterMultiplier(quarter);

          // For quarterly, we show 3 months data
          List<double> monthlyPattern = _getQuarterlyPattern(quarter);
          if (i < monthlyPattern.length) {
            graphData['present']![i] =
                (teamMembers.length * monthlyPattern[i] * quarterMultiplier);
            graphData['late']![i] = (teamMembers.length * 0.1);
            graphData['absent']![i] =
                (teamMembers.length * (1.0 - monthlyPattern[i] - 0.1));
          } else {
            graphData['present']![i] = (teamMembers.length * 0.85);
            graphData['late']![i] = (teamMembers.length * 0.1);
            graphData['absent']![i] = (teamMembers.length * 0.05);
          }
          break;
      }

      // Ensure values are within bounds
      graphData['present']![i] = graphData['present']![i].clamp(
        0,
        teamMembers.length.toDouble(),
      );
      graphData['late']![i] = graphData['late']![i].clamp(
        0,
        teamMembers.length.toDouble(),
      );
      graphData['absent']![i] = graphData['absent']![i].clamp(
        0,
        teamMembers.length.toDouble(),
      );
    }

    return graphData;
  }

  Map<String, Map<String, double>> _generateIndividualData(
    List<TeamMember> teamMembers,
    String period,
    DateTime selectedDate,
  ) {
    Map<String, Map<String, double>> individualData = {};

    for (final member in teamMembers) {
      final hash = member.email.hashCode.abs();

      // Generate period-aware individual data
      double baseAttendance = _getBaseAttendanceRate(
        period,
        selectedDate,
        hash,
      );
      double baseHours = _getBaseHours(period, selectedDate, hash);
      double baseProductivity = _getBaseProductivity(
        period,
        selectedDate,
        hash,
      );

      individualData[member.email] = {
        'attendanceRate': baseAttendance,
        'avgHours': baseHours,
        'productivity': baseProductivity,
        'presentDays': (15 + hash % 10).toDouble(),
      };
    }

    return individualData;
  }

  // Helper methods for date-aware data generation

  double _getDailyAttendanceRate(int dayOfWeek) {
    switch (dayOfWeek) {
      case DateTime.monday:
        return 0.75;
      case DateTime.friday:
        return 0.80;
      case DateTime.saturday:
        return 0.65;
      case DateTime.sunday:
        return 0.60;
      default:
        return 0.85; // Tue, Wed, Thu
    }
  }

  double _getDailyLateRate(int dayOfWeek) {
    switch (dayOfWeek) {
      case DateTime.monday:
        return 0.15;
      case DateTime.friday:
        return 0.12;
      default:
        return 0.10;
    }
  }

  double _getDailyAbsentRate(int dayOfWeek) {
    switch (dayOfWeek) {
      case DateTime.monday:
        return 0.10;
      case DateTime.saturday:
        return 0.25;
      case DateTime.sunday:
        return 0.30;
      default:
        return 0.05;
    }
  }

  double _getWeekMultiplier(DateTime date) {
    // First week of month usually has better attendance
    final weekInMonth = ((date.day - 1) ~/ 7) + 1;
    switch (weekInMonth) {
      case 1:
        return 1.1; // First week
      case 2:
        return 1.0; // Second week
      case 3:
        return 0.95; // Third week
      case 4:
        return 0.90; // Fourth week
      case 5:
        return 0.85; // Fifth week (if exists)
      default:
        return 1.0;
    }
  }

  double _getMonthMultiplier(int month) {
    // Seasonal variations
    switch (month) {
      case 1:
        return 0.95; // January - post holidays
      case 12:
        return 0.90; // December - holiday season
      case 6:
      case 7:
        return 0.85; // Summer months
      case 9:
        return 1.1; // September - back from vacations
      default:
        return 1.0;
    }
  }

  double _getQuarterMultiplier(int quarter) {
    switch (quarter) {
      case 1:
        return 0.95; // Q1 - post holidays
      case 2:
        return 1.0; // Q2 - stable
      case 3:
        return 0.90; // Q3 - vacation season
      case 4:
        return 1.05; // Q4 - year end push
      default:
        return 1.0;
    }
  }

  List<double> _getQuarterlyPattern(int quarter) {
    switch (quarter) {
      case 1:
        return [0.85, 0.88, 0.90]; // Jan, Feb, Mar
      case 2:
        return [0.92, 0.90, 0.88]; // Apr, May, Jun
      case 3:
        return [0.80, 0.75, 0.82]; // Jul, Aug, Sep
      case 4:
        return [0.88, 0.92, 0.85]; // Oct, Nov, Dec
      default:
        return [0.85, 0.85, 0.85];
    }
  }

  double _getBaseAttendanceRate(String period, DateTime date, int hash) {
    double base = 75.0 + (hash % 25); // 75-99%

    // Adjust based on period and date
    switch (period) {
      case 'daily':
        return base * _getDailyAttendanceRate(date.weekday);
      case 'weekly':
        return base * _getWeekMultiplier(date);
      case 'monthly':
        return base * _getMonthMultiplier(date.month);
      case 'quarterly':
        return base * _getQuarterMultiplier(((date.month - 1) ~/ 3) + 1);
      default:
        return base;
    }
  }

  double _getBaseHours(String period, DateTime date, int hash) {
    double base = 7.0 + (hash % 30) / 10; // 7.0-9.9 hours

    // Slight variations based on period
    switch (period) {
      case 'daily':
        return base * (date.weekday == DateTime.friday ? 0.95 : 1.0);
      case 'weekly':
        return base * _getWeekMultiplier(date);
      default:
        return base;
    }
  }

  double _getBaseProductivity(String period, DateTime date, int hash) {
    double base = 70.0 + (hash % 30); // 70-99%

    // Productivity patterns
    switch (period) {
      case 'monthly':
        return base * _getMonthMultiplier(date.month);
      case 'quarterly':
        return base * _getQuarterMultiplier(((date.month - 1) ~/ 3) + 1);
      default:
        return base;
    }
  }

  List<String> _getGraphLabels(String period, DateTime selectedDate) {
    switch (period) {
      case 'daily':
        return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
      case 'weekly':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      case 'monthly':
        final daysInMonth = DateTime(
          selectedDate.year,
          selectedDate.month + 1,
          0,
        ).day;
        return ['W1', 'W2', 'W3', 'W4', if (daysInMonth > 28) 'W5'];
      case 'quarterly':
        final quarter = ((selectedDate.month - 1) ~/ 3) + 1;
        final months = _getQuarterMonths(quarter);
        return months.map((month) => _getMonthAbbreviation(month)).toList();
      default:
        return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
    }
  }

  List<int> _getQuarterMonths(int quarter) {
    switch (quarter) {
      case 1:
        return [1, 2, 3]; // Jan, Feb, Mar
      case 2:
        return [4, 5, 6]; // Apr, May, Jun
      case 3:
        return [7, 8, 9]; // Jul, Aug, Sep
      case 4:
        return [10, 11, 12]; // Oct, Nov, Dec
      default:
        return [1, 2, 3];
    }
  }

  String _getMonthAbbreviation(int month) {
    final date = DateTime(2023, month);
    return DateFormat('MMM').format(date);
  }

  // Rest of the methods remain the same...
  Map<String, dynamic> _calculateStatistics(
    Map<String, Map<String, double>> individualData,
    int teamSize,
  ) {
    if (teamSize == 0) {
      return {
        'attendanceRate': 0,
        'avgHours': '0.0',
        'productivity': 0,
        'totalMembers': 0,
      };
    }

    double totalAttendance = 0;
    double totalHours = 0;
    double totalProductivity = 0;

    individualData.forEach((email, data) {
      totalAttendance += data['attendanceRate'] ?? 0;
      totalHours += data['avgHours'] ?? 0;
      totalProductivity += data['productivity'] ?? 0;
    });

    return {
      'attendanceRate': (totalAttendance / teamSize).round(),
      'avgHours': (totalHours / teamSize).toStringAsFixed(1),
      'productivity': (totalProductivity / teamSize).round(),
      'totalMembers': teamSize,
    };
  }

  List<Insight> generateInsights(Map<String, dynamic> statistics) {
    final attendanceRate = statistics['attendanceRate'] ?? 0;
    final avgHours =
        double.tryParse(statistics['avgHours']?.toString() ?? '0.0') ?? 0.0;
    final productivity = statistics['productivity'] ?? 0;

    List<Insight> insights = [];

    if (attendanceRate >= 90) {
      insights.add(
        Insight(
          text:
              'Excellent! Team attendance rate is $attendanceRate%, well above company average',
          type: 'positive',
        ),
      );
    } else if (attendanceRate >= 75) {
      insights.add(
        Insight(
          text:
              'Good! Team attendance rate is $attendanceRate%, meeting company standards',
          type: 'positive',
        ),
      );
    } else {
      insights.add(
        Insight(
          text:
              'Team attendance rate is $attendanceRate%, needs improvement to reach 85% target',
          type: 'warning',
        ),
      );
    }

    if (avgHours >= 8.5) {
      insights.add(
        Insight(
          text:
              'Average working hours: ${avgHours.toStringAsFixed(1)}h/day - Great commitment!',
          type: 'positive',
        ),
      );
    } else {
      insights.add(
        Insight(
          text:
              'Average working hours: ${avgHours.toStringAsFixed(1)}h/day (Target: 8.5h)',
          type: 'info',
        ),
      );
    }

    if (productivity >= 80) {
      insights.add(
        Insight(
          text:
              'Outstanding! Productivity score of $productivity% shows high efficiency',
          type: 'positive',
        ),
      );
    } else if (productivity >= 70) {
      insights.add(
        Insight(
          text:
              'Productivity score of $productivity% is good, with room for improvement',
          type: 'info',
        ),
      );
    } else {
      insights.add(
        Insight(
          text:
              'Productivity score of $productivity% needs attention and improvement strategies',
          type: 'warning',
        ),
      );
    }

    insights.add(
      Insight(
        text:
            'Best performance typically observed between 10AM-12PM. Consider optimizing schedules.',
        type: 'info',
      ),
    );

    return insights;
  }

  List<PerformanceMetric> getPerformanceMetrics() {
    return [
      PerformanceMetric(
        title: 'Total Working Days',
        value: '22',
        subtitle: 'Target: 20',
      ),
      PerformanceMetric(
        title: 'Average Hours/Day',
        value: '8.5',
        subtitle: 'Target: 8.5',
      ),
      PerformanceMetric(
        title: 'On-time Arrival',
        value: '85%',
        subtitle: 'Good',
      ),
      PerformanceMetric(
        title: 'Productivity Score',
        value: '78%',
        subtitle: 'Improving',
      ),
    ];
  }
}

// import 'package:attendanceapp/models/attendancemodels/attendance_analytics_model.dart';
// import 'package:attendanceapp/models/team_model.dart';

// class AttendanceAnalyticsService {
//   AttendanceAnalytics generateAnalytics(
//     List<TeamMember> teamMembers,
//     String period,
//   ) {
//     final graphData = _generateGraphData(teamMembers, period);
//     final individualData = _generateIndividualData(teamMembers);
//     final statistics = _calculateStatistics(individualData, teamMembers.length);

//     return AttendanceAnalytics(
//       period: period,
//       graphData: graphData,
//       individualData: individualData,
//       statistics: statistics,
//     );
//   }

//   Map<String, List<double>> _generateGraphData(
//     List<TeamMember> teamMembers,
//     String period,
//   ) {
//     final labels = _getGraphLabels(period);
//     Map<String, List<double>> graphData = {
//       'present': [],
//       'late': [],
//       'absent': [],
//     };

//     for (final label in labels) {
//       graphData['present']!.add((teamMembers.length * 0.7).toDouble());
//       graphData['late']!.add((teamMembers.length * 0.2).toDouble());
//       graphData['absent']!.add((teamMembers.length * 0.1).toDouble());
//     }

//     return graphData;
//   }

//   Map<String, Map<String, double>> _generateIndividualData(
//     List<TeamMember> teamMembers,
//   ) {
//     Map<String, Map<String, double>> individualData = {};

//     for (final member in teamMembers) {
//       individualData[member.email] = {
//         'attendanceRate': (70 + member.email.hashCode % 30).toDouble(),
//         'avgHours': 7.5 + (member.email.hashCode % 15) / 10,
//         'productivity': 75.0 + (member.email.hashCode % 20),
//       };
//     }

//     return individualData;
//   }

//   Map<String, dynamic> _calculateStatistics(
//     Map<String, Map<String, double>> individualData,
//     int teamSize,
//   ) {
//     double totalAttendance = 0;
//     double totalHours = 0;
//     double totalProductivity = 0;

//     individualData.forEach((email, data) {
//       totalAttendance += data['attendanceRate'] ?? 0;
//       totalHours += data['avgHours'] ?? 0;
//       totalProductivity += data['productivity'] ?? 0;
//     });

//     return {
//       'attendanceRate': (totalAttendance / teamSize).round(),
//       'avgHours': (totalHours / teamSize).toStringAsFixed(1),
//       'productivity': (totalProductivity / teamSize).round(),
//     };
//   }

//   List<String> _getGraphLabels(String period) {
//     switch (period) {
//       case 'daily':
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//       case 'weekly':
//         return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//       case 'monthly':
//         return ['Week1', 'Week2', 'Week3', 'Week4', 'Week5'];
//       case 'yearly':
//         return [
//           'Jan',
//           'Feb',
//           'Mar',
//           'Apr',
//           'May',
//           'Jun',
//           'Jul',
//           'Aug',
//           'Sep',
//           'Oct',
//           'Nov',
//           'Dec',
//         ];
//       default:
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//     }
//   }

//   List<Insight> generateInsights(Map<String, dynamic> statistics) {
//     return [
//       Insight(
//         text:
//             'Team attendance rate is ${statistics['attendanceRate']}%, above company average of 85%',
//         type: 'positive',
//       ),
//       Insight(
//         text:
//             'Average working hours: ${statistics['avgHours']}h/day (Target: 9h)',
//         type: 'info',
//       ),
//       Insight(
//         text:
//             '${statistics['productivity']}% productivity score needs improvement',
//         type: 'warning',
//       ),
//       Insight(
//         text: 'Best performance time: 10AM-12PM, Consider optimizing schedules',
//         type: 'info',
//       ),
//     ];
//   }

//   List<PerformanceMetric> getPerformanceMetrics() {
//     return [
//       PerformanceMetric(
//         title: 'Total Working Days',
//         value: '22',
//         subtitle: 'Target: 20',
//       ),
//       PerformanceMetric(
//         title: 'Average Hours/Day',
//         value: '8.5',
//         subtitle: 'Target: 9.0',
//       ),
//       PerformanceMetric(
//         title: 'On-time Arrival',
//         value: '85%',
//         subtitle: 'Good',
//       ),
//       PerformanceMetric(
//         title: 'Productivity Score',
//         value: '78%',
//         subtitle: 'Improving',
//       ),
//     ];
//   }
// }
