import 'dart:ui';

import 'package:AttendanceApp/manager/models/team_model.dart';
import 'package:flutter/foundation.dart';

import '../../models/projectmodels/project_models.dart';
import '../../services/managerservices/project_service.dart';

class ProjectViewModel with ChangeNotifier {
  final ProjectService _service = ProjectService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Project> _projects = [];
  List<TeamMember> _availableTeam = [];
  String _selectedView = 'projects'; // projects, attendance, employees

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Project> get projects => _projects;
  List<TeamMember> get availableTeam => _availableTeam;
  String get selectedView => _selectedView;

  Future<void> initialize() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _loadProjects();
      await _loadAvailableTeam();
      _logSuccess('Project data initialized');
    } catch (e) {
      _errorMessage = 'Failed to load projects: $e';
      _handleError(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadProjects() async {
    _projects = await _service.getProjects();
  }

  Future<void> _loadAvailableTeam() async {
    _availableTeam = await _service.getAvailableTeam();
  }

  void changeView(String view) {
    if (_selectedView == view) return;

    _selectedView = view;
    _logAction('View changed to: $view');
    notifyListeners();
  }

  Future<void> createProject(ProjectFormData formData) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _service.createProject(formData);
      await _loadProjects(); // Refresh the list
      _logSuccess('Project created successfully: ${formData.name}');
    } catch (e) {
      _errorMessage = 'Failed to create project: $e';
      _handleError(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProject(String projectId, ProjectFormData formData) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _service.updateProject(projectId, formData);
      await _loadProjects(); // Refresh the list
      _logSuccess('Project updated successfully: ${formData.name}');
    } catch (e) {
      _errorMessage = 'Failed to update project: $e';
      _handleError(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProject(String projectId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _service.deleteProject(projectId);
      await _loadProjects(); // Refresh the list
      _logSuccess('Project deleted successfully');
    } catch (e) {
      _errorMessage = 'Failed to delete project: $e';
      _handleError(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  Color getStatusColor(String status) {
    const statusColors = {
      'planning': AppColors.info,
      'active': AppColors.success,
      'completed': AppColors.primary,
      'on-hold': AppColors.warning,
    };
    return statusColors[status] ?? AppColors.grey500;
  }

  Color getPriorityColor(String priority) {
    const priorityColors = {
      'low': AppColors.success,
      'medium': AppColors.warning,
      'high': AppColors.error,
      'urgent': AppColors.error,
    };
    return priorityColors[priority] ?? AppColors.grey500;
  }

  String getStatusText(String status) {
    const statusText = {
      'planning': 'Planning',
      'active': 'Active',
      'completed': 'Completed',
      'on-hold': 'On Hold',
    };
    return statusText[status] ?? 'Unknown';
  }

  String getPriorityText(String priority) {
    const priorityText = {
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'urgent': 'Urgent',
    };
    return priorityText[priority] ?? 'Unknown';
  }

  // New method for loading projects specifically for attendance screen
  Future<void> loadProjects() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _loadProjects();
      _logSuccess('Projects loaded successfully');
    } catch (e) {
      _errorMessage = 'Failed to load projects: $e';
      _handleError(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  // New method to get project by ID
  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // New method to get projects by status
  List<Project> getProjectsByStatus(String status) {
    return _projects.where((project) => project.status == status).toList();
  }

  // New method to get active projects count
  int get activeProjectsCount {
    return _projects.where((project) => project.status == 'active').length;
  }

  // New method to get completed projects count
  int get completedProjectsCount {
    return _projects.where((project) => project.status == 'completed').length;
  }

  // New method to get total team members across all projects
  int get totalTeamMembers {
    return _projects.fold(0, (sum, project) => sum + project.teamSize);
  }

  // New method to get total tasks across all projects
  int get totalTasks {
    return _projects.fold(0, (sum, project) => sum + project.totalTasks);
  }

  // New method to get completed tasks across all projects
  int get completedTasks {
    return _projects.fold(0, (sum, project) => sum + project.completedTasks);
  }

  // New method to get projects assigned to specific employee
  List<Project> getProjectsByEmployee(String employeeEmail) {
    return _projects.where((project) {
      return project.assignedTeam.any(
        (member) => member.email == employeeEmail,
      );
    }).toList();
  }

  // New method to get employee workload (number of assigned projects)
  int getEmployeeWorkload(String employeeEmail) {
    return _projects.where((project) {
      return project.assignedTeam.any(
        (member) => member.email == employeeEmail,
      );
    }).length;
  }

  // New method to get project progress statistics
  Map<String, dynamic> getProjectStatistics() {
    final total = _projects.length;
    final active = activeProjectsCount;
    final completed = completedProjectsCount;
    final planning = getProjectsByStatus('planning').length;
    final onHold = getProjectsByStatus('on-hold').length;

    final totalProgress =
        _projects.fold(0.0, (sum, project) => sum + project.progress) / total;

    return {
      'total': total,
      'active': active,
      'completed': completed,
      'planning': planning,
      'onHold': onHold,
      'averageProgress': totalProgress.isNaN ? 0.0 : totalProgress,
    };
  }

  // New method to get upcoming deadlines (projects ending in next 30 days)
  List<Project> getUpcomingDeadlines() {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    return _projects.where((project) {
      return project.endDate.isAfter(now) &&
          project.endDate.isBefore(thirtyDaysFromNow) &&
          project.status == 'active';
    }).toList();
  }

  // New method to get overdue projects
  List<Project> getOverdueProjects() {
    final now = DateTime.now();

    return _projects.where((project) {
      return project.endDate.isBefore(now) && project.status == 'active';
    }).toList();
  }

  // New method to get high priority projects
  List<Project> getHighPriorityProjects() {
    return _projects.where((project) {
      return project.priority == 'high' || project.priority == 'urgent';
    }).toList();
  }

  // New method to search projects by name or client
  List<Project> searchProjects(String query) {
    if (query.isEmpty) return _projects;

    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) {
      return project.name.toLowerCase().contains(lowercaseQuery) ||
          project.client.toLowerCase().contains(lowercaseQuery) ||
          project.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // New method to get team members not assigned to any project
  List<TeamMember> getAvailableTeamMembers() {
    final assignedEmails = <String>{};

    for (final project in _projects) {
      for (final member in project.assignedTeam) {
        assignedEmails.add(member.email);
      }
    }

    return _availableTeam
        .where((member) => !assignedEmails.contains(member.email))
        .toList();
  }

  // New method to get project timeline data for charts
  Map<String, List<Project>> getProjectsByTimeline() {
    final now = DateTime.now();
    final upcoming = <Project>[];
    final current = <Project>[];
    final completed = <Project>[];

    for (final project in _projects) {
      if (project.status == 'completed') {
        completed.add(project);
      } else if (project.endDate.isAfter(now)) {
        if (project.startDate.isBefore(now)) {
          current.add(project);
        } else {
          upcoming.add(project);
        }
      }
    }

    return {'upcoming': upcoming, 'current': current, 'completed': completed};
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String message) {
    if (kDebugMode) {
      print('❌ ProjectViewModel: $message');
    }
  }

  void _logSuccess(String message) {
    if (kDebugMode) {
      print('✅ ProjectViewModel: $message');
    }
  }

  void _logAction(String message) {
    if (kDebugMode) {
      print('🔧 ProjectViewModel: $message');
    }
  }

  @override
  void dispose() {
    _projects.clear();
    _availableTeam.clear();
    super.dispose();
  }
}

// import 'dart:ui';

// import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// import 'package:attendanceapp/models/projectmodels/project_models.dart';
// import 'package:attendanceapp/models/team_model.dart';
// import 'package:attendanceapp/services/projectservices/project_service.dart';
// import 'package:flutter/foundation.dart';

// class ProjectViewModel with ChangeNotifier {
//   final ProjectService _service = ProjectService();

//   bool _isLoading = false;
//   String? _errorMessage;
//   List<Project> _projects = [];
//   List<TeamMember> _availableTeam = [];
//   String _selectedView = 'projects'; // projects, attendance, employees

//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   List<Project> get projects => _projects;
//   List<TeamMember> get availableTeam => _availableTeam;
//   String get selectedView => _selectedView;

//   Future<void> initialize() async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       await _loadProjects();
//       await _loadAvailableTeam();
//       _logSuccess('Project data initialized');
//     } catch (e) {
//       _errorMessage = 'Failed to load projects: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> _loadProjects() async {
//     _projects = await _service.getProjects();
//   }

//   Future<void> _loadAvailableTeam() async {
//     _availableTeam = await _service.getAvailableTeam();
//   }

//   void changeView(String view) {
//     if (_selectedView == view) return;

//     _selectedView = view;
//     _logAction('View changed to: $view');
//     notifyListeners();
//   }

//   Future<void> createProject(ProjectFormData formData) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       await _service.createProject(formData);
//       await _loadProjects(); // Refresh the list
//       _logSuccess('Project created successfully: ${formData.name}');
//     } catch (e) {
//       _errorMessage = 'Failed to create project: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> updateProject(String projectId, ProjectFormData formData) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       await _service.updateProject(projectId, formData);
//       await _loadProjects(); // Refresh the list
//       _logSuccess('Project updated successfully: ${formData.name}');
//     } catch (e) {
//       _errorMessage = 'Failed to update project: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> deleteProject(String projectId) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       await _service.deleteProject(projectId);
//       await _loadProjects(); // Refresh the list
//       _logSuccess('Project deleted successfully');
//     } catch (e) {
//       _errorMessage = 'Failed to delete project: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Color getStatusColor(String status) {
//     const statusColors = {
//       'planning': AppColors.info,
//       'active': AppColors.success,
//       'completed': AppColors.primary,
//       'on-hold': AppColors.warning,
//     };
//     return statusColors[status] ?? AppColors.grey500;
//   }

//   Color getPriorityColor(String priority) {
//     const priorityColors = {
//       'low': AppColors.success,
//       'medium': AppColors.warning,
//       'high': AppColors.error,
//       'urgent': AppColors.error,
//     };
//     return priorityColors[priority] ?? AppColors.grey500;
//   }

//   String getStatusText(String status) {
//     const statusText = {
//       'planning': 'Planning',
//       'active': 'Active',
//       'completed': 'Completed',
//       'on-hold': 'On Hold',
//     };
//     return statusText[status] ?? 'Unknown';
//   }

//   String getPriorityText(String priority) {
//     const priorityText = {
//       'low': 'Low',
//       'medium': 'Medium',
//       'high': 'High',
//       'urgent': 'Urgent',
//     };
//     return priorityText[priority] ?? 'Unknown';
//   }

//   // New method for loading projects specifically for attendance screen
//   Future<void> loadProjects() async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       await _loadProjects();
//       _logSuccess('Projects loaded successfully');
//     } catch (e) {
//       _errorMessage = 'Failed to load projects: $e';
//       _handleError(_errorMessage!);
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // New method to get project by ID
//   Project? getProjectById(String projectId) {
//     try {
//       return _projects.firstWhere((project) => project.id == projectId);
//     } catch (e) {
//       return null;
//     }
//   }

//   // New method to get projects by status
//   List<Project> getProjectsByStatus(String status) {
//     return _projects.where((project) => project.status == status).toList();
//   }

//   // New method to get active projects count
//   int get activeProjectsCount {
//     return _projects.where((project) => project.status == 'active').length;
//   }

//   // New method to get completed projects count
//   int get completedProjectsCount {
//     return _projects.where((project) => project.status == 'completed').length;
//   }

//   // New method to get total team members across all projects
//   int get totalTeamMembers {
//     return _projects.fold(0, (sum, project) => sum + project.teamSize);
//   }

//   // New method to get total tasks across all projects
//   int get totalTasks {
//     return _projects.fold(0, (sum, project) => sum + project.totalTasks);
//   }

//   // New method to get completed tasks across all projects
//   int get completedTasks {
//     return _projects.fold(0, (sum, project) => sum + project.completedTasks);
//   }

//   // Private methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _handleError(String message) {
//     if (kDebugMode) {
//       print('❌ ProjectViewModel: $message');
//     }
//   }

//   void _logSuccess(String message) {
//     if (kDebugMode) {
//       print('✅ ProjectViewModel: $message');
//     }
//   }

//   void _logAction(String message) {
//     if (kDebugMode) {
//       print('🔧 ProjectViewModel: $message');
//     }
//   }

//   @override
//   void dispose() {
//     _projects.clear();
//     _availableTeam.clear();
//     super.dispose();
//   }
// }

// // import 'dart:ui';

// // import 'package:attendanceapp/core/view_models/theme_view_model.dart';
// // import 'package:attendanceapp/models/projectmodels/project_models.dart';
// // import 'package:attendanceapp/models/team_model.dart';
// // import 'package:attendanceapp/services/projectservices/project_service.dart';
// // import 'package:flutter/foundation.dart';

// // class ProjectViewModel with ChangeNotifier {
// //   final ProjectService _service = ProjectService();

// //   bool _isLoading = false;
// //   String? _errorMessage;
// //   List<Project> _projects = [];
// //   List<TeamMember> _availableTeam = [];
// //   String _selectedView = 'projects'; // projects, attendance, employees

// //   bool get isLoading => _isLoading;
// //   String? get errorMessage => _errorMessage;
// //   List<Project> get projects => _projects;
// //   List<TeamMember> get availableTeam => _availableTeam;
// //   String get selectedView => _selectedView;

// //   Future<void> initialize() async {
// //     _setLoading(true);
// //     _errorMessage = null;

// //     try {
// //       await _loadProjects();
// //       await _loadAvailableTeam();
// //       _logSuccess('Project data initialized');
// //     } catch (e) {
// //       _errorMessage = 'Failed to load projects: $e';
// //       _handleError(_errorMessage!);
// //     } finally {
// //       _setLoading(false);
// //     }
// //   }

// //   Future<void> _loadProjects() async {
// //     _projects = await _service.getProjects();
// //   }

// //   Future<void> _loadAvailableTeam() async {
// //     _availableTeam = await _service.getAvailableTeam();
// //   }

// //   void changeView(String view) {
// //     if (_selectedView == view) return;

// //     _selectedView = view;
// //     _logAction('View changed to: $view');
// //     notifyListeners();
// //   }

// //   Future<void> createProject(ProjectFormData formData) async {
// //     _setLoading(true);
// //     _errorMessage = null;

// //     try {
// //       await _service.createProject(formData);
// //       await _loadProjects(); // Refresh the list
// //       _logSuccess('Project created successfully: ${formData.name}');
// //     } catch (e) {
// //       _errorMessage = 'Failed to create project: $e';
// //       _handleError(_errorMessage!);
// //     } finally {
// //       _setLoading(false);
// //     }
// //   }

// //   Future<void> updateProject(String projectId, ProjectFormData formData) async {
// //     _setLoading(true);
// //     _errorMessage = null;

// //     try {
// //       await _service.updateProject(projectId, formData);
// //       await _loadProjects(); // Refresh the list
// //       _logSuccess('Project updated successfully: ${formData.name}');
// //     } catch (e) {
// //       _errorMessage = 'Failed to update project: $e';
// //       _handleError(_errorMessage!);
// //     } finally {
// //       _setLoading(false);
// //     }
// //   }

// //   Future<void> deleteProject(String projectId) async {
// //     _setLoading(true);
// //     _errorMessage = null;

// //     try {
// //       await _service.deleteProject(projectId);
// //       await _loadProjects(); // Refresh the list
// //       _logSuccess('Project deleted successfully');
// //     } catch (e) {
// //       _errorMessage = 'Failed to delete project: $e';
// //       _handleError(_errorMessage!);
// //     } finally {
// //       _setLoading(false);
// //     }
// //   }

// //   Color getStatusColor(String status) {
// //     const statusColors = {
// //       'planning': AppColors.info,
// //       'active': AppColors.success,
// //       'completed': AppColors.primary,
// //       'on-hold': AppColors.warning,
// //     };
// //     return statusColors[status] ?? AppColors.grey500;
// //   }

// //   Color getPriorityColor(String priority) {
// //     const priorityColors = {
// //       'low': AppColors.success,
// //       'medium': AppColors.warning,
// //       'high': AppColors.error,
// //       'urgent': AppColors.error,
// //     };
// //     return priorityColors[priority] ?? AppColors.grey500;
// //   }

// //   String getStatusText(String status) {
// //     const statusText = {
// //       'planning': 'Planning',
// //       'active': 'Active',
// //       'completed': 'Completed',
// //       'on-hold': 'On Hold',
// //     };
// //     return statusText[status] ?? 'Unknown';
// //   }

// //   String getPriorityText(String priority) {
// //     const priorityText = {
// //       'low': 'Low',
// //       'medium': 'Medium',
// //       'high': 'High',
// //       'urgent': 'Urgent',
// //     };
// //     return priorityText[priority] ?? 'Unknown';
// //   }

// //   // Private methods
// //   void _setLoading(bool loading) {
// //     _isLoading = loading;
// //     notifyListeners();
// //   }

// //   void _handleError(String message) {
// //     if (kDebugMode) {
// //       print('❌ ProjectViewModel: $message');
// //     }
// //   }

// //   void _logSuccess(String message) {
// //     if (kDebugMode) {
// //       print('✅ ProjectViewModel: $message');
// //     }
// //   }

// //   void _logAction(String message) {
// //     if (kDebugMode) {
// //       print('🔧 ProjectViewModel: $message');
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _projects.clear();
// //     _availableTeam.clear();
// //     super.dispose();
// //   }
// // }
