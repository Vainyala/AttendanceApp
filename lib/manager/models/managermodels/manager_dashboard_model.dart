import 'package:attendanceapp/manager/models/attendance_model.dart';
import 'package:attendanceapp/manager/models/project_model.dart';
import 'package:attendanceapp/manager/models/team_model.dart';
import 'package:attendanceapp/manager/models/user_model.dart';

class ManagerDashboard {
  final User profile;
  final List<AttendanceRecord> teamAttendance;
  final List<TeamMember> teamMembers;
  final List<Project> projects;
  final DateTime currentDateTime;
  final WorkingHours workingHours;

  ManagerDashboard({
    required this.profile,
    required this.teamAttendance,
    required this.teamMembers,
    required this.projects,
    required this.currentDateTime,
    required this.workingHours,
  });
}

class WorkingHours {
  final DateTime? checkIn;
  final DateTime? checkOut;
  final Duration workedDuration;
  final bool isCheckedIn;

  WorkingHours({
    this.checkIn,
    this.checkOut,
    required this.workedDuration,
    required this.isCheckedIn,
  });

  Duration get remainingTime => const Duration(hours: 9) - workedDuration;
  bool get canCheckOut => workedDuration >= const Duration(hours: 9);
}

class DashboardStats {
  final int totalTeamMembers;
  final int presentToday;
  final int activeProjects;
  final int pendingLeaves;
  final int absentToday; // ✅ Naya field add kiya
  final int overallPresent; // ✅ Naya field add kiya

  DashboardStats({
    required this.totalTeamMembers,
    required this.presentToday,
    required this.activeProjects,
    required this.pendingLeaves,
    required this.absentToday, // ✅ Constructor mein add kiya
    required this.overallPresent, // ✅ Constructor mein add kiya
  });

  // Agar aapke paas fromJson method hai toh usme bhi add karo
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalTeamMembers: json['totalTeamMembers'] ?? 0,
      presentToday: json['presentToday'] ?? 0,
      activeProjects: json['activeProjects'] ?? 0,
      pendingLeaves: json['pendingLeaves'] ?? 0,
      absentToday: json['absentToday'] ?? 0, // ✅ JSON field add kiya
      overallPresent: json['overallPresent'] ?? 0, // ✅ JSON field add kiya
    );
  }

  // Convenience method for creating stats with calculated values
  factory DashboardStats.calculateFromData({
    required int totalTeamMembers,
    required int presentToday,
    required int activeProjects,
    required int pendingLeaves,
    int? overallPresent, // Optional - calculate if not provided
  }) {
    final absentToday = totalTeamMembers - presentToday;
    final calculatedOverallPresent =
        overallPresent ?? (presentToday * 20); // Default calculation

    return DashboardStats(
      totalTeamMembers: totalTeamMembers,
      presentToday: presentToday,
      activeProjects: activeProjects,
      pendingLeaves: pendingLeaves,
      absentToday: absentToday,
      overallPresent: calculatedOverallPresent,
    );
  }
}

// import 'package:attendanceapp/models/attendance_model.dart';
// import 'package:attendanceapp/models/project_model.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/models/user_model.dart';

// class ManagerDashboard {
//   final User profile;
//   final List<AttendanceRecord> teamAttendance;
//   final List<TeamMember> teamMembers;
//   final List<Project> projects;
//   final DateTime currentDateTime;
//   final WorkingHours workingHours;

//   ManagerDashboard({
//     required this.profile,
//     required this.teamAttendance,
//     required this.teamMembers,
//     required this.projects,
//     required this.currentDateTime,
//     required this.workingHours,
//   });
// }

// class WorkingHours {
//   final DateTime? checkIn;
//   final DateTime? checkOut;
//   final Duration workedDuration;
//   final bool isCheckedIn;

//   WorkingHours({
//     this.checkIn,
//     this.checkOut,
//     required this.workedDuration,
//     required this.isCheckedIn,
//   });

//   Duration get remainingTime => const Duration(hours: 9) - workedDuration;
//   bool get canCheckOut => workedDuration >= const Duration(hours: 9);
// }

// class DashboardStats {
//   final int totalTeamMembers;
//   final int presentToday;
//   final int activeProjects;
//   final int pendingLeaves;

//   DashboardStats({
//     required this.totalTeamMembers,
//     required this.presentToday,
//     required this.activeProjects,
//     required this.pendingLeaves,
//   });
// }
