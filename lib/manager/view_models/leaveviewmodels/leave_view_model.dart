// view_models/leave_view_model.dart
import 'package:AttendanceApp/manager/models/leavemodels/leave_model.dart';
import 'package:AttendanceApp/manager/services/leaveservices/leave_database_service.dart';
import 'package:flutter/foundation.dart';

class LeaveViewModel with ChangeNotifier {
  final LeaveDatabaseService _databaseService = LeaveDatabaseService();

  List<LeaveApplication> _leaveApplications = [];
  LeaveFilter _currentFilter = LeaveFilter.all;
  bool _isLoading = false;
  String _errorMessage = '';

  List<LeaveApplication> get leaveApplications => _leaveApplications;
  LeaveFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<LeaveApplication> get filteredApplications {
    switch (_currentFilter) {
      case LeaveFilter.pending:
        return _leaveApplications
            .where((app) => app.status == LeaveStatus.pending)
            .toList();
      case LeaveFilter.approved:
        return _leaveApplications
            .where((app) => app.status == LeaveStatus.approved)
            .toList();
      case LeaveFilter.rejected:
        return _leaveApplications
            .where((app) => app.status == LeaveStatus.rejected)
            .toList();
      case LeaveFilter.query:
        return _leaveApplications
            .where((app) => app.status == LeaveStatus.query)
            .toList();
      case LeaveFilter.all:
      default:
        return _leaveApplications;
    }
  }

  // Dashboard counters for current month
  Map<String, int> get dashboardCounters {
    final currentMonthApps = _leaveApplications
        .where((app) => app.isCurrentMonth)
        .toList();

    return {
      'total': currentMonthApps.length,
      'pending': currentMonthApps
          .where((app) => app.status == LeaveStatus.pending)
          .length,
      'approved': currentMonthApps
          .where((app) => app.status == LeaveStatus.approved)
          .length,
      'rejected': currentMonthApps
          .where((app) => app.status == LeaveStatus.rejected)
          .length,
      'query': currentMonthApps
          .where((app) => app.status == LeaveStatus.query)
          .length,
    };
  }

  // Load all leave applications
  // view_models/leaveviewmodels/leave_view_model.dart
  Future<void> loadLeaveApplications() async {
    _setLoading(true);
    try {
      print('🔄 Loading leave applications...');

      // Pehle database schema check karo
      await _databaseService.checkDatabaseSchema();

      _leaveApplications = await _databaseService.getAllLeaveApplications();

      print('✅ Successfully loaded ${_leaveApplications.length} applications');
      _errorMessage = '';
    } catch (e, stackTrace) {
      print('❌ Error loading leave applications: $e');
      print('📋 Stack trace: $stackTrace');
      _errorMessage = 'Failed to load leave applications: $e';

      // Emergency fallback
      _leaveApplications = _getSafeTemporaryData();
    } finally {
      _setLoading(false);
    }
  }

  List<LeaveApplication> _getSafeTemporaryData() {
    final now = DateTime.now();
    print('🆘 Using temporary fallback data');

    return [
      LeaveApplication(
        employeeId: 'EMP001',
        employeeName: 'Raj Sharma',
        employeeRole: 'Senior Developer',
        employeeEmail: 'raj.sharma@company.com',
        employeePhone: '+91 9876543210',
        employeePhoto: '',
        projectName: 'Mobile App Development',
        leaveType: LeaveType.casual,
        startDate: DateTime(now.year, now.month, 15),
        endDate: DateTime(now.year, now.month, 16),
        totalDays: 2,
        reason: 'Family wedding ceremony in hometown',
        status: LeaveStatus.pending,
        appliedDate: DateTime(now.year, now.month, 10, 9, 30),
        contactNumber: '+91 9876543210',
        handoverPersonName: 'Amit Kumar',
        handoverPersonEmail: 'amit.kumar@company.com',
        handoverPersonPhone: '+91 9876543212',
        handoverPersonPhoto: '',
      ),
      LeaveApplication(
        employeeId: 'EMP002',
        employeeName: 'Priya Singh',
        employeeRole: 'UI/UX Designer',
        employeeEmail: 'priya.singh@company.com',
        employeePhone: '+91 9876543211',
        employeePhoto: '',
        projectName: 'Website Redesign',
        leaveType: LeaveType.sick,
        startDate: DateTime(now.year, now.month, 18),
        endDate: DateTime(now.year, now.month, 18),
        totalDays: 1,
        reason: 'Medical checkup and rest advised by doctor',
        status: LeaveStatus.approved,
        appliedDate: DateTime(now.year, now.month, 12, 14, 15),
        managerRemarks: 'Approved as per medical requirement',
        contactNumber: '+91 9876543211',
        handoverPersonName: 'Neha Patel',
        handoverPersonEmail: 'neha.patel@company.com',
        handoverPersonPhone: '+91 9876543213',
        handoverPersonPhoto: '',
      ),
      LeaveApplication(
        employeeId: 'EMP003',
        employeeName: 'Amit Kumar',
        employeeRole: 'QA Engineer',
        employeeEmail: 'amit.kumar@company.com',
        employeePhone: '+91 9876543212',
        employeePhoto: '',
        projectName: 'Mobile App Development',
        leaveType: LeaveType.earned,
        startDate: DateTime(now.year, now.month, 20),
        endDate: DateTime(now.year, now.month, 24),
        totalDays: 5,
        reason: 'Vacation with family to hill station',
        status: LeaveStatus.rejected,
        appliedDate: DateTime(now.year, now.month, 5, 11, 0),
        managerRemarks: 'Project deadline conflict',
        contactNumber: '+91 9876543212',
        handoverPersonName: 'Raj Sharma',
        handoverPersonEmail: 'raj.sharma@company.com',
        handoverPersonPhone: '+91 9876543210',
        handoverPersonPhoto: '',
      ),
    ];
  }
  // Future<void> loadLeaveApplications() async {
  //   _setLoading(true);
  //   try {
  //     _leaveApplications = await _databaseService.getAllLeaveApplications();
  //     _errorMessage = '';
  //   } catch (e) {
  //     _errorMessage = 'Failed to load leave applications: $e';
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Load applications by status
  // Future<void> loadLeaveApplicationsByStatus(LeaveStatus status) async {
  //   _setLoading(true);
  //   try {
  //     _leaveApplications = await _databaseService.getLeaveApplicationsByStatus(
  //       status,
  //     );
  //     _errorMessage = '';
  //   } catch (e) {
  //     _errorMessage = 'Failed to load leave applications: $e';
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Update filter
  void setFilter(LeaveFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Update leave status with manager comments
  Future<bool> updateLeaveStatus(
    int applicationId,
    LeaveStatus status,
    String managerRemarks,
    String approvedBy,
  ) async {
    _setLoading(true);
    try {
      await _databaseService.updateLeaveStatus(
        applicationId,
        status,
        managerRemarks,
        approvedBy,
      );
      await loadLeaveApplications();
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update leave status: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Export to Excel
  Future<List<Map<String, dynamic>>> exportToExcel() async {
    try {
      final exportData = await _databaseService.getExportData(_currentFilter);
      _errorMessage = '';
      return exportData;
    } catch (e) {
      _errorMessage = 'Failed to export data: $e';
      return [];
    }
  }

  // Get leave statistics
  Future<LeaveStats> getLeaveStats() async {
    try {
      final stats = await _databaseService.getLeaveStats();
      _errorMessage = '';
      return stats;
    } catch (e) {
      _errorMessage = 'Failed to load statistics: $e';
      return LeaveStats(
        totalRequests: 0,
        pendingRequests: 0,
        approvedRequests: 0,
        rejectedRequests: 0,
        currentMonthRequests: 0,
      );
    }
  }

  // Get leave application by ID
  Future<LeaveApplication?> getLeaveApplicationById(int id) async {
    try {
      final application = await _databaseService.getLeaveApplicationById(id);
      _errorMessage = '';
      return application;
    } catch (e) {
      _errorMessage = 'Failed to load application: $e';
      return null;
    }
  }

  // Search leave applications
  Future<void> searchLeaveApplications(String query) async {
    _setLoading(true);
    try {
      if (query.isEmpty) {
        await loadLeaveApplications();
      } else {
        _leaveApplications = await _databaseService.searchLeaveApplications(
          query,
        );
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to search applications: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Initialize sample data for manager
  Future<void> initializeSampleData() async {
    _setLoading(true);
    try {
      // Database service already has sample data in its initialization
      // Just load the applications
      await loadLeaveApplications();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to initialize sample data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Get leave balances for employee
  Future<List<LeaveBalance>> getLeaveBalances(String employeeId) async {
    try {
      final balances = await _databaseService.getLeaveBalances(employeeId);
      _errorMessage = '';
      return balances;
    } catch (e) {
      _errorMessage = 'Failed to load leave balances: $e';
      return [];
    }
  }

  // Create new leave application
  Future<bool> createLeaveApplication(LeaveApplication application) async {
    _setLoading(true);
    try {
      await _databaseService.insertLeaveApplication(application);
      await loadLeaveApplications();
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create leave application: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing leave application
  Future<bool> updateLeaveApplication(LeaveApplication application) async {
    _setLoading(true);
    try {
      await _databaseService.updateLeaveApplication(application);
      await loadLeaveApplications();
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update leave application: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete leave application
  Future<bool> deleteLeaveApplication(int id) async {
    _setLoading(true);
    try {
      await _databaseService.deleteLeaveApplication(id);
      await loadLeaveApplications();
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete leave application: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get current month applications
  Future<List<LeaveApplication>> getCurrentMonthApplications() async {
    try {
      final applications = await _databaseService.getCurrentMonthApplications();
      _errorMessage = '';
      return applications;
    } catch (e) {
      _errorMessage = 'Failed to load current month applications: $e';
      return [];
    }
  }

  // Get applications by employee
  Future<List<LeaveApplication>> getLeaveApplicationsByEmployee(
    String employeeId,
  ) async {
    try {
      final applications = await _databaseService
          .getLeaveApplicationsByEmployee(employeeId);
      _errorMessage = '';
      return applications;
    } catch (e) {
      _errorMessage = 'Failed to load employee applications: $e';
      return [];
    }
  }

  // Get employee leave statistics
  Future<Map<String, int>> getEmployeeLeaveStats(String employeeId) async {
    try {
      final stats = await _databaseService.getEmployeeLeaveStats(employeeId);
      _errorMessage = '';
      return stats;
    } catch (e) {
      _errorMessage = 'Failed to load employee statistics: $e';
      return {'total': 0, 'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }

  // Helper method to create a sample leave application for testing
  LeaveApplication createSampleLeaveApplication() {
    final now = DateTime.now();
    return LeaveApplication(
      employeeId: 'EMP001',
      employeeName: 'Sample Employee',
      employeeRole: 'Developer',
      employeeEmail: 'sample@company.com',
      employeePhone: '+91 9876543210',
      employeePhoto: '',
      projectName: 'Sample Project',
      leaveType: LeaveType.casual,
      startDate: now.add(const Duration(days: 7)),
      endDate: now.add(const Duration(days: 8)),
      totalDays: 2,
      reason: 'Sample reason for leave application',
      status: LeaveStatus.pending,
      appliedDate: now,
      contactNumber: '+91 9876543210',
      handoverPersonName: 'Handover Person',
      handoverPersonEmail: 'handover@company.com',
      handoverPersonPhone: '+91 9876543211',
      handoverPersonPhoto: '',
    );
  }

  //   void _initializeData() {
  //   final viewModel = context.read<LeaveViewModel>();

  //   // Pehle database reset karo (temporary)
  //   // _databaseService.resetDatabase().then((_) {
  //     viewModel.loadLeaveApplications().then((_) {
  //       if (viewModel.leaveApplications.isEmpty) {
  //         viewModel.initializeSampleData();
  //       }
  //     });
  //   // });
  // }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Dispose method to close database connection
  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }
}
