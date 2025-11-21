// view_models/manager_regularisation_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/regularisationmodels/manager_regularisation_model.dart';
import '../../models/regularisationmodels/regularisation_model.dart';
import '../../services/projectservices/project_service.dart';
import '../../services/regularisationservices/manager_regularisation_service.dart';

class ManagerRegularisationViewModel with ChangeNotifier {
  final ManagerRegularisationService _service;
  final ProjectService _projectService; // ✅ Add ProjectService dependency

  List<ManagerRegularisationRequest> _allRequests = [];
  ManagerRegularisationStats _stats = ManagerRegularisationStats(
    totalRequests: 0,
    pendingRequests: 0,
    approvedRequests: 0,
    rejectedRequests: 0,
    currentMonthRequests: 0,
  );
  bool _isLoading = false;
  String _error = '';
  ManagerRegularisationFilter _currentFilter =
      ManagerRegularisationFilter.pending;
  bool _isExporting = false;

  ManagerRegularisationViewModel(
    this._service,
    this._projectService, // ✅ Add this parameter
  );

  // Getters
  List<ManagerRegularisationRequest> get allRequests => _allRequests;
  ManagerRegularisationStats get stats => _stats;
  bool get isLoading => _isLoading;
  String get error => _error;
  ManagerRegularisationFilter get currentFilter => _currentFilter;
  bool get isExporting => _isExporting;

  // Filtered requests
  List<ManagerRegularisationRequest> get filteredRequests {
    switch (_currentFilter) {
      case ManagerRegularisationFilter.pending:
        return _allRequests.where((req) => req.isPending).toList();
      case ManagerRegularisationFilter.approved:
        return _allRequests.where((req) => req.isApproved).toList();
      case ManagerRegularisationFilter.rejected:
        return _allRequests.where((req) => req.isRejected).toList();
      case ManagerRegularisationFilter.all:
      default:
        return _allRequests;
    }
  }

  // ✅ NEW METHOD: Get employee projects
  List<String> getEmployeeProjects(String employeeEmail) {
    try {
      final projects = _projectService.getProjectSync();
      final employeeProjects = <String>[];

      for (final project in projects) {
        final isAssigned = project.assignedTeam.any(
          (member) => member.email == employeeEmail,
        );
        if (isAssigned) {
          employeeProjects.add(project.name);
        }
      }

      return employeeProjects.isNotEmpty
          ? employeeProjects
          : ['No Projects Assigned'];
    } catch (e) {
      return ['Error loading projects'];
    }
  }

  // State management methods
  Future<void> loadManagerRegularisationData() async {
    _setLoading(true);
    _error = '';

    try {
      _allRequests = await _service.getAllRegularisationRequests();
      _stats = await _service.getRegularisationStats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load regularisation data: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeFilter(ManagerRegularisationFilter filter) async {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<bool> approveRequest(String requestId, String managerRemarks) async {
    if (managerRemarks.length < 200) {
      _error = 'Manager remarks must be at least 200 characters';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      await _service.approveRequest(requestId, managerRemarks);

      // Update local state
      final index = _allRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _allRequests[index] = _allRequests[index].copyWith(
          status: RegularisationStatus.approved,
          managerRemarks: managerRemarks,
          approvedDate: DateTime.now(),
        );
        _stats = await _service.getRegularisationStats();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to approve request: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectRequest(String requestId, String managerRemarks) async {
    if (managerRemarks.length < 200) {
      _error = 'Manager remarks must be at least 200 characters';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      await _service.rejectRequest(requestId, managerRemarks);

      // Update local state
      final index = _allRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _allRequests[index] = _allRequests[index].copyWith(
          status: RegularisationStatus.rejected,
          managerRemarks: managerRemarks,
        );
        _stats = await _service.getRegularisationStats();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to reject request: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestMoreInfo(String requestId, String managerRemarks) async {
    if (managerRemarks.length < 200) {
      _error = 'Manager query must be at least 200 characters';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      await _service.requestMoreInfo(requestId, managerRemarks);
      return true;
    } catch (e) {
      _error = 'Failed to send query: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> exportToExcel() async {
    _setExporting(true);
    try {
      await _service.exportToExcel(filteredRequests);
      // Show success message
    } catch (e) {
      _error = 'Failed to export data: ${e.toString()}';
      notifyListeners();
    } finally {
      _setExporting(false);
    }
  }

  // Helper methods
  Color getStatusColor(RegularisationStatus status) {
    switch (status) {
      case RegularisationStatus.pending:
        return Colors.orange;
      case RegularisationStatus.approved:
        return Colors.green;
      case RegularisationStatus.rejected:
        return Colors.red;
      case RegularisationStatus.cancelled:
        return Colors.grey;
    }
  }

  String getStatusText(RegularisationStatus status) {
    switch (status) {
      case RegularisationStatus.pending:
        return 'Pending';
      case RegularisationStatus.approved:
        return 'Approved';
      case RegularisationStatus.rejected:
        return 'Rejected';
      case RegularisationStatus.cancelled:
        return 'Cancelled';
    }
  }

  String getTypeText(RegularisationType type) {
    switch (type) {
      case RegularisationType.checkIn:
        return 'Check-in Only';
      case RegularisationType.checkOut:
        return 'Check-out Only';
      case RegularisationType.fullDay:
        return 'Full Day';
      case RegularisationType.halfDay:
        return 'Half Day';
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setExporting(bool exporting) {
    _isExporting = exporting;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}

enum ManagerRegularisationFilter { all, pending, approved, rejected }
// // view_models/manager_regularisation_view_model.dart
// import 'package:attendanceapp/models/regularisationmodels/manager_regularisation_model.dart';
// import 'package:attendanceapp/models/regularisationmodels/regularisation_model.dart';
// import 'package:attendanceapp/services/regularisationservices/manager_regularisation_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class ManagerRegularisationViewModel with ChangeNotifier {
//   final ManagerRegularisationService _service;

//   List<ManagerRegularisationRequest> _allRequests = [];
//   ManagerRegularisationStats _stats = ManagerRegularisationStats(
//     totalRequests: 0,
//     pendingRequests: 0,
//     approvedRequests: 0,
//     rejectedRequests: 0,
//     currentMonthRequests: 0,
//   );
//   bool _isLoading = false;
//   String _error = '';
//   ManagerRegularisationFilter _currentFilter =
//       ManagerRegularisationFilter.pending;
//   bool _isExporting = false;

//   ManagerRegularisationViewModel(this._service);

//   // Getters
//   List<ManagerRegularisationRequest> get allRequests => _allRequests;
//   ManagerRegularisationStats get stats => _stats;
//   bool get isLoading => _isLoading;
//   String get error => _error;
//   ManagerRegularisationFilter get currentFilter => _currentFilter;
//   bool get isExporting => _isExporting;

//   // Filtered requests
//   List<ManagerRegularisationRequest> get filteredRequests {
//     switch (_currentFilter) {
//       case ManagerRegularisationFilter.pending:
//         return _allRequests.where((req) => req.isPending).toList();
//       case ManagerRegularisationFilter.approved:
//         return _allRequests.where((req) => req.isApproved).toList();
//       case ManagerRegularisationFilter.rejected:
//         return _allRequests.where((req) => req.isRejected).toList();
//       case ManagerRegularisationFilter.all:
//       default:
//         return _allRequests;
//     }
//   }

//   // State management methods
//   Future<void> loadManagerRegularisationData() async {
//     _setLoading(true);
//     _error = '';

//     try {
//       _allRequests = await _service.getAllRegularisationRequests();
//       _stats = await _service.getRegularisationStats();
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to load regularisation data: ${e.toString()}';
//       notifyListeners();
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> changeFilter(ManagerRegularisationFilter filter) async {
//     _currentFilter = filter;
//     notifyListeners();
//   }

//   Future<bool> approveRequest(String requestId, String managerRemarks) async {
//     if (managerRemarks.length < 200) {
//       _error = 'Manager remarks must be at least 200 characters';
//       notifyListeners();
//       return false;
//     }

//     try {
//       _setLoading(true);
//       await _service.approveRequest(requestId, managerRemarks);

//       // Update local state
//       final index = _allRequests.indexWhere((req) => req.id == requestId);
//       if (index != -1) {
//         _allRequests[index] = _allRequests[index].copyWith(
//           status: RegularisationStatus.approved,
//           managerRemarks: managerRemarks,
//           approvedDate: DateTime.now(),
//         );
//         _stats = await _service.getRegularisationStats();
//         notifyListeners();
//       }
//       return true;
//     } catch (e) {
//       _error = 'Failed to approve request: ${e.toString()}';
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<bool> rejectRequest(String requestId, String managerRemarks) async {
//     if (managerRemarks.length < 200) {
//       _error = 'Manager remarks must be at least 200 characters';
//       notifyListeners();
//       return false;
//     }

//     try {
//       _setLoading(true);
//       await _service.rejectRequest(requestId, managerRemarks);

//       // Update local state
//       final index = _allRequests.indexWhere((req) => req.id == requestId);
//       if (index != -1) {
//         _allRequests[index] = _allRequests[index].copyWith(
//           status: RegularisationStatus.rejected,
//           managerRemarks: managerRemarks,
//         );
//         _stats = await _service.getRegularisationStats();
//         notifyListeners();
//       }
//       return true;
//     } catch (e) {
//       _error = 'Failed to reject request: ${e.toString()}';
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<bool> requestMoreInfo(String requestId, String managerRemarks) async {
//     if (managerRemarks.length < 200) {
//       _error = 'Manager query must be at least 200 characters';
//       notifyListeners();
//       return false;
//     }

//     try {
//       _setLoading(true);
//       await _service.requestMoreInfo(requestId, managerRemarks);
//       return true;
//     } catch (e) {
//       _error = 'Failed to send query: ${e.toString()}';
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> exportToExcel() async {
//     _setExporting(true);
//     try {
//       await _service.exportToExcel(filteredRequests);
//       // Show success message
//     } catch (e) {
//       _error = 'Failed to export data: ${e.toString()}';
//       notifyListeners();
//     } finally {
//       _setExporting(false);
//     }
//   }

//   // Helper methods
//   Color getStatusColor(RegularisationStatus status) {
//     switch (status) {
//       case RegularisationStatus.pending:
//         return Colors.orange;
//       case RegularisationStatus.approved:
//         return Colors.green;
//       case RegularisationStatus.rejected:
//         return Colors.red;
//       case RegularisationStatus.cancelled:
//         return Colors.grey;
//     }
//   }

//   String getStatusText(RegularisationStatus status) {
//     switch (status) {
//       case RegularisationStatus.pending:
//         return 'Pending';
//       case RegularisationStatus.approved:
//         return 'Approved';
//       case RegularisationStatus.rejected:
//         return 'Rejected';
//       case RegularisationStatus.cancelled:
//         return 'Cancelled';
//     }
//   }

//   String getTypeText(RegularisationType type) {
//     switch (type) {
//       case RegularisationType.checkIn:
//         return 'Check-in Only';
//       case RegularisationType.checkOut:
//         return 'Check-out Only';
//       case RegularisationType.fullDay:
//         return 'Full Day';
//       case RegularisationType.halfDay:
//         return 'Half Day';
//     }
//   }

//   // Private methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _setExporting(bool exporting) {
//     _isExporting = exporting;
//     notifyListeners();
//   }

//   void clearError() {
//     _error = '';
//     notifyListeners();
//   }
// }

// enum ManagerRegularisationFilter { all, pending, approved, rejected }
