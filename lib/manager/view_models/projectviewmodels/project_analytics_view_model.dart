// view_models/projectviewmodels/project_analytics_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:attendanceapp/manager/models/projectmodels/project_models.dart'; // Use the correct import
import 'package:attendanceapp/manager/models/projectmodels/project_analytics_model.dart';

class ProjectAnalyticsViewModel with ChangeNotifier {
  ProjectAnalytics? _analytics;
  String _selectedPeriod = 'weekly';
  List<Project> _projects = []; // Now using Project from project_models.dart
  int _totalEmployees = 0;

  ProjectAnalytics? get analytics => _analytics;
  String get selectedPeriod => _selectedPeriod;
  List<Project> get projects => _projects;
  int get totalEmployees => _totalEmployees;

  // Initialize with projects from ProjectViewModel
  void initializeWithProjects(List<Project> projects) {
    _projects = List<Project>.from(projects);
    _totalEmployees = _calculateTotalEmployees();
    _analytics = _generateAnalytics();
    notifyListeners();
  }

  // Update when projects change in main ProjectViewModel
  void updateProjects(List<Project> projects) {
    _projects = List<Project>.from(projects);
    _totalEmployees = _calculateTotalEmployees();
    _analytics = _generateAnalytics();
    notifyListeners();
  }

  // Calculate total employees across all projects
  int _calculateTotalEmployees() {
    if (_projects.isEmpty) return 0;

    // Sum up team sizes from all projects
    return _projects.fold(0, (sum, project) => sum + project.teamSize);
  }

  ProjectAnalytics _generateAnalytics() {
    final graphData = <String, List<double>>{
      'planning': [],
      'active': [],
      'completed': [],
      'onHold': [],
    };

    final labels = _getLabelsForPeriod();
    final statusDistribution = _calculateStatusDistribution();
    final additionalStats = _calculateAdditionalStats();

    // Generate sample data for demonstration
    _generateSampleGraphData(graphData, labels.length);

    return ProjectAnalytics(
      graphData: graphData,
      labels: labels,
      totalProjects: _projects.length,
      totalEmployees: _totalEmployees,
      statusDistribution: statusDistribution,
      additionalStats: additionalStats,
    );
  }

  void _generateSampleGraphData(
    Map<String, List<double>> graphData,
    int labelCount,
  ) {
    // Generate sample data for demonstration
    for (int i = 0; i < labelCount; i++) {
      graphData['planning']!.add((_projects.length * 0.2).toDouble());
      graphData['active']!.add((_projects.length * 0.5).toDouble());
      graphData['completed']!.add((_projects.length * 0.2).toDouble());
      graphData['onHold']!.add((_projects.length * 0.1).toDouble());
    }
  }

  List<String> _getLabelsForPeriod() {
    switch (_selectedPeriod) {
      case 'daily':
        return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
      case 'weekly':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'monthly':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      case 'yearly':
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
      default:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }

  Map<String, double> _calculateStatusDistribution() {
    final planningProjects = _projects
        .where((p) => p.status.toLowerCase() == 'planning')
        .length;
    final activeProjects = _projects
        .where((p) => p.status.toLowerCase() == 'active')
        .length;
    final completedProjects = _projects
        .where((p) => p.status.toLowerCase() == 'completed')
        .length;
    final onHoldProjects = _projects
        .where((p) => p.status.toLowerCase() == 'on-hold')
        .length;
    final total = _projects.length;

    return {
      'planning': total > 0 ? (planningProjects / total * 100) : 0.0,
      'active': total > 0 ? (activeProjects / total * 100) : 0.0,
      'completed': total > 0 ? (completedProjects / total * 100) : 0.0,
      'onHold': total > 0 ? (onHoldProjects / total * 100) : 0.0,
    };
  }

  Map<String, dynamic> _calculateAdditionalStats() {
    return {
      'activeProjectsCount': activeProjectsCount,
      'completedProjectsCount': completedProjectsCount,
      'onHoldProjectsCount': onHoldProjectsCount,
      'planningProjectsCount': planningProjectsCount,
      'overdueCount': overdueProjects.length,
      'projectsEndingSoonCount': projectsEndingSoon.length,
      'totalBudget': _calculateTotalBudget(),
      'averageProgress': _calculateAverageProgress(),
    };
  }

  // Basic project statistics
  int get activeProjectsCount =>
      _projects.where((p) => p.status.toLowerCase() == 'active').length;
  int get completedProjectsCount =>
      _projects.where((p) => p.status.toLowerCase() == 'completed').length;
  int get onHoldProjectsCount =>
      _projects.where((p) => p.status.toLowerCase() == 'on-hold').length;
  int get planningProjectsCount =>
      _projects.where((p) => p.status.toLowerCase() == 'planning').length;

  List<Project> get overdueProjects {
    final now = DateTime.now();
    return _projects
        .where(
          (p) =>
              p.endDate.isBefore(now) && p.status.toLowerCase() != 'completed',
        )
        .toList();
  }

  List<Project> get projectsEndingSoon {
    final now = DateTime.now();
    return _projects
        .where(
          (p) =>
              p.endDate.isAfter(now) &&
              p.endDate.difference(now).inDays <= 7 &&
              p.status.toLowerCase() != 'completed',
        )
        .toList();
  }

  double _calculateTotalBudget() {
    return _projects.fold(0.0, (sum, project) => sum + project.budget);
  }

  double _calculateAverageProgress() {
    if (_projects.isEmpty) return 0.0;
    return _projects.fold(0.0, (sum, project) => sum + project.progress) /
        _projects.length;
  }

  void setSelectedPeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      _analytics = _generateAnalytics();
      notifyListeners();
    }
  }

  String getPeriodDisplayName(String period) {
    switch (period) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Weekly';
    }
  }

  String getGraphSubtitle() {
    switch (_selectedPeriod) {
      case 'daily':
        return 'Project distribution overview';
      case 'weekly':
        return 'Weekly project status distribution';
      case 'monthly':
        return 'Monthly project status overview';
      case 'yearly':
        return 'Annual project status distribution';
      default:
        return 'Project status overview';
    }
  }

  // Get projects by status
  List<Project> getProjectsByStatus(String status) {
    return _projects
        .where((p) => p.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // Get project health metrics
  Map<String, dynamic> getProjectHealthMetrics() {
    final now = DateTime.now();
    int healthy = 0, atRisk = 0, critical = 0;

    for (final project in _projects) {
      if (project.status.toLowerCase() == 'completed') {
        healthy++;
      } else if (project.endDate.isAfter(now)) {
        final daysRemaining = project.endDate.difference(now).inDays;
        if (daysRemaining > 14) {
          healthy++;
        } else if (daysRemaining > 7) {
          atRisk++;
        } else {
          critical++;
        }
      } else {
        critical++; // Overdue projects
      }
    }

    return {
      'healthy': healthy,
      'atRisk': atRisk,
      'critical': critical,
      'total': _projects.length,
    };
  }

  // Get project timeline statistics
  double get averageProjectDuration {
    if (_projects.isEmpty) return 0.0;
    final totalDuration = _projects.fold(0.0, (sum, project) {
      final duration = project.endDate.difference(project.startDate).inDays;
      return sum + duration;
    });
    return totalDuration / _projects.length;
  }

  // Get project status timeline
  Map<String, int> getProjectStatusTimeline() {
    final now = DateTime.now();
    int startingSoon = 0, inProgress = 0, endingSoon = 0, completed = 0;

    for (final project in _projects) {
      if (project.status.toLowerCase() == 'completed') {
        completed++;
      } else if (project.startDate.isAfter(now)) {
        startingSoon++;
      } else if (project.endDate.difference(now).inDays <= 7) {
        endingSoon++;
      } else {
        inProgress++;
      }
    }

    return {
      'startingSoon': startingSoon,
      'inProgress': inProgress,
      'endingSoon': endingSoon,
      'completed': completed,
    };
  }

  // Get attendance data for project teams
  Map<String, int> getProjectTeamAttendance(Project project) {
    final teamSize = project.teamSize;
    return {
      'present': (teamSize * 0.7).round(),
      'absent': (teamSize * 0.1).round(),
      'leave': (teamSize * 0.15).round(),
      'late': (teamSize * 0.05).round(),
    };
  }
}

// // view_models/projectviewmodels/project_analytics_view_model.dart
// import 'package:flutter/foundation.dart';
// import 'package:attendanceapp/models/project_model.dart';
// import 'package:attendanceapp/models/projectmodels/project_analytics_model.dart';

// class ProjectAnalyticsViewModel with ChangeNotifier {
//   ProjectAnalytics? _analytics;
//   String _selectedPeriod = 'weekly';
//   List<Project> _projects = [];
//   int _totalEmployees = 0;

//   ProjectAnalytics? get analytics => _analytics;
//   String get selectedPeriod => _selectedPeriod;
//   List<Project> get projects => _projects;
//   int get totalEmployees => _totalEmployees;

//   // Initialize with projects from ProjectViewModel
//   void initializeWithProjects(List<Project> projects) {
//     _projects = List<Project>.from(projects);
//     _totalEmployees = _calculateTotalEmployees();
//     _analytics = _generateAnalytics();
//     notifyListeners();
//   }

//   // Update when projects change in main ProjectViewModel
//   void updateProjects(List<Project> projects) {
//     _projects = List<Project>.from(projects);
//     _totalEmployees = _calculateTotalEmployees();
//     _analytics = _generateAnalytics();
//     notifyListeners();
//   }

//   // Simplified - we'll use a fixed number for demo
//   int _calculateTotalEmployees() {
//     // For now, return a fixed number since we can't access team data
//     return _projects.length * 3; // Assume 3 employees per project on average
//   }

//   ProjectAnalytics _generateAnalytics() {
//     final graphData = <String, List<double>>{
//       'planning': [],
//       'active': [],
//       'completed': [],
//       'onHold': [],
//     };

//     final labels = _getLabelsForPeriod();
//     final statusDistribution = _calculateStatusDistribution();
//     final additionalStats = _calculateAdditionalStats();

//     // Generate sample data for demonstration
//     _generateSampleGraphData(graphData, labels.length);

//     return ProjectAnalytics(
//       graphData: graphData,
//       labels: labels,
//       totalProjects: _projects.length,
//       totalEmployees: _totalEmployees,
//       statusDistribution: statusDistribution,
//       additionalStats: additionalStats,
//     );
//   }

//   void _generateSampleGraphData(
//     Map<String, List<double>> graphData,
//     int labelCount,
//   ) {
//     // Generate sample data for demonstration
//     for (int i = 0; i < labelCount; i++) {
//       graphData['planning']!.add((_projects.length * 0.2).toDouble());
//       graphData['active']!.add((_projects.length * 0.5).toDouble());
//       graphData['completed']!.add((_projects.length * 0.2).toDouble());
//       graphData['onHold']!.add((_projects.length * 0.1).toDouble());
//     }
//   }

//   int _getProjectPeriodIndex(Project project, int totalPeriods) {
//     // Use startDate for period calculations
//     final projectDate = project.startDate;

//     switch (_selectedPeriod) {
//       case 'daily':
//         return (projectDate.hour % totalPeriods).clamp(0, totalPeriods - 1);
//       case 'weekly':
//         return (projectDate.weekday - 1).clamp(0, totalPeriods - 1);
//       case 'monthly':
//         final firstDay = DateTime(projectDate.year, projectDate.month, 1);
//         final weekNumber = ((projectDate.day + firstDay.weekday - 1) / 7)
//             .ceil();
//         return (weekNumber - 1).clamp(0, totalPeriods - 1);
//       case 'yearly':
//         return (projectDate.month - 1).clamp(0, totalPeriods - 1);
//       default:
//         return 0;
//     }
//   }

//   List<String> _getLabelsForPeriod() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return ['9AM', '11AM', '1PM', '3PM', '5PM', '7PM'];
//       case 'weekly':
//         return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//       case 'monthly':
//         return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
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
//         return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     }
//   }

//   Map<String, double> _calculateStatusDistribution() {
//     final planningProjects = _projects
//         .where((p) => p.status == 'planning')
//         .length;
//     final activeProjects = _projects.where((p) => p.status == 'active').length;
//     final completedProjects = _projects
//         .where((p) => p.status == 'completed')
//         .length;
//     final onHoldProjects = _projects.where((p) => p.status == 'on-hold').length;
//     final total = _projects.length;

//     return {
//       'planning': total > 0 ? (planningProjects / total * 100) : 0.0,
//       'active': total > 0 ? (activeProjects / total * 100) : 0.0,
//       'completed': total > 0 ? (completedProjects / total * 100) : 0.0,
//       'onHold': total > 0 ? (onHoldProjects / total * 100) : 0.0,
//     };
//   }

//   Map<String, dynamic> _calculateAdditionalStats() {
//     return {
//       'activeProjectsCount': activeProjectsCount,
//       'completedProjectsCount': completedProjectsCount,
//       'onHoldProjectsCount': onHoldProjectsCount,
//       'planningProjectsCount': planningProjectsCount,
//       'overdueCount': overdueProjects.length,
//       'projectsEndingSoonCount': projectsEndingSoon.length,
//     };
//   }

//   // Basic project statistics using only status and dates
//   int get activeProjectsCount =>
//       _projects.where((p) => p.status == 'active').length;
//   int get completedProjectsCount =>
//       _projects.where((p) => p.status == 'completed').length;
//   int get onHoldProjectsCount =>
//       _projects.where((p) => p.status == 'on-hold').length;
//   int get planningProjectsCount =>
//       _projects.where((p) => p.status == 'planning').length;

//   List<Project> get overdueProjects {
//     final now = DateTime.now();
//     return _projects
//         .where((p) => p.endDate.isBefore(now) && p.status != 'completed')
//         .toList();
//   }

//   List<Project> get projectsEndingSoon {
//     final now = DateTime.now();
//     return _projects
//         .where(
//           (p) =>
//               p.endDate.isAfter(now) &&
//               p.endDate.difference(now).inDays <= 7 &&
//               p.status != 'completed',
//         )
//         .toList();
//   }

//   void setSelectedPeriod(String period) {
//     if (_selectedPeriod != period) {
//       _selectedPeriod = period;
//       _analytics = _generateAnalytics();
//       notifyListeners();
//     }
//   }

//   String getPeriodDisplayName(String period) {
//     switch (period) {
//       case 'daily':
//         return 'Daily';
//       case 'weekly':
//         return 'Weekly';
//       case 'monthly':
//         return 'Monthly';
//       case 'yearly':
//         return 'Yearly';
//       default:
//         return 'Weekly';
//     }
//   }

//   String getGraphSubtitle() {
//     switch (_selectedPeriod) {
//       case 'daily':
//         return 'Project distribution overview';
//       case 'weekly':
//         return 'Weekly project status distribution';
//       case 'monthly':
//         return 'Monthly project status overview';
//       case 'yearly':
//         return 'Annual project status distribution';
//       default:
//         return 'Project status overview';
//     }
//   }

//   // Get projects by status
//   List<Project> getProjectsByStatus(String status) {
//     return _projects.where((p) => p.status == status).toList();
//   }

//   // Get project health metrics
//   Map<String, dynamic> getProjectHealthMetrics() {
//     final now = DateTime.now();
//     int healthy = 0, atRisk = 0, critical = 0;

//     for (final project in _projects) {
//       if (project.status == 'completed') {
//         healthy++;
//       } else if (project.endDate.isAfter(now)) {
//         final daysRemaining = project.endDate.difference(now).inDays;
//         if (daysRemaining > 14) {
//           healthy++;
//         } else if (daysRemaining > 7) {
//           atRisk++;
//         } else {
//           critical++;
//         }
//       } else {
//         critical++; // Overdue projects
//       }
//     }

//     return {
//       'healthy': healthy,
//       'atRisk': atRisk,
//       'critical': critical,
//       'total': _projects.length,
//     };
//   }

//   // Get project timeline statistics
//   double get averageProjectDuration {
//     if (_projects.isEmpty) return 0.0;
//     final totalDuration = _projects.fold(0.0, (sum, project) {
//       final duration = project.endDate.difference(project.startDate).inDays;
//       return sum + duration;
//     });
//     return totalDuration / _projects.length;
//   }

//   // Get project status timeline
//   Map<String, int> getProjectStatusTimeline() {
//     final now = DateTime.now();
//     int startingSoon = 0, inProgress = 0, endingSoon = 0, completed = 0;

//     for (final project in _projects) {
//       if (project.status == 'completed') {
//         completed++;
//       } else if (project.startDate.isAfter(now)) {
//         startingSoon++;
//       } else if (project.endDate.difference(now).inDays <= 7) {
//         endingSoon++;
//       } else {
//         inProgress++;
//       }
//     }

//     return {
//       'startingSoon': startingSoon,
//       'inProgress': inProgress,
//       'endingSoon': endingSoon,
//       'completed': completed,
//     };
//   }
// }
