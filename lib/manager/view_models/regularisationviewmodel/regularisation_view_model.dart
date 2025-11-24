// view_models/regularisation_view_model.dart
import 'package:attendanceapp/manager/models/projectmodels/project_models.dart';
import 'package:attendanceapp/manager/models/regularisationmodels/regularisation_model.dart';
import 'package:attendanceapp/manager/services/regularisationservices/regularisation_service.dart';
import 'package:attendanceapp/manager/services/regularisationservices/regularisation_local_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegularisationViewModel with ChangeNotifier {
  final RegularisationService _apiService = RegularisationService();
  final RegularisationLocalService _localService = RegularisationLocalService();

  int? _currentUserId; // Add user ID for local storage

  bool _isLoading = false;
  String? _errorMessage;
  List<RegularisationRequest> _requests = [];
  List<Project> _userProjects = [];
  RegularisationFilter _currentFilter = RegularisationFilter.pending;
  bool _isSyncing = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RegularisationRequest> get requests => _requests;
  List<Project> get userProjects => _userProjects;
  RegularisationFilter get currentFilter => _currentFilter;
  bool get isSyncing => _isSyncing;

  // Filtered requests with search capability
  List<RegularisationRequest> get filteredRequests {
    List<RegularisationRequest> filtered = _requests;

    switch (_currentFilter) {
      case RegularisationFilter.pending:
        filtered = filtered.where((r) => r.isPending).toList();
        break;
      case RegularisationFilter.approved:
        filtered = filtered.where((r) => r.isApproved).toList();
        break;
      case RegularisationFilter.rejected:
        filtered = filtered.where((r) => r.isRejected).toList();
        break;
      case RegularisationFilter.all:
      default:
        break;
    }

    return filtered;
  }

  // Statistics with local data
  Map<String, int> get requestStats {
    return {
      'total': _requests.length,
      'pending': _requests.where((r) => r.isPending).length,
      'approved': _requests.where((r) => r.isApproved).length,
      'rejected': _requests.where((r) => r.isRejected).length,
    };
  }

  // Initialize data with offline support
  Future<void> initialize({int? userId}) async {
    _currentUserId = userId;
    _setLoading(true);
    _errorMessage = null;

    try {
      // Try to load from API first
      await _loadFromAPI();
      _logSuccess('Data loaded from API successfully');
    } catch (e) {
      _errorMessage = 'Failed to load from API: $e';
      _logWarning('Falling back to local data');

      // Fallback to local data
      await _loadFromLocal();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadFromAPI() async {
    final apiRequests = await _apiService.getMyRegularisationRequests();
    final apiProjects = await _apiService.getUserProjects();

    // Save to local database
    if (_currentUserId != null) {
      for (final request in apiRequests) {
        await _localService.insertRequest(request);
      }
    }

    _requests = apiRequests;
    _userProjects = apiProjects;
    notifyListeners();
  }

  Future<void> _loadFromLocal() async {
    if (_currentUserId != null) {
      _requests = await _localService.getAllRequests(
        _currentUserId!.toString(),
      );
      _userProjects = await _apiService
          .getUserProjects(); // Projects can still load from API
      notifyListeners();
    }
  }

  // Sync data with backend
  Future<void> syncData() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      await _loadFromAPI();
      _logSuccess('Data synced successfully');
    } catch (e) {
      _errorMessage = 'Sync failed: $e';
      _handleError(_errorMessage!);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Filter changes
  void changeFilter(RegularisationFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Create new regularisation request with offline support
  Future<RequestResult> createRegularisationRequest(
    RegularisationFormData formData,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Validate form data
      final validationError = formData.validate();
      if (validationError != null) {
        return RequestResult(false, validationError);
      }

      // Create request via API
      final newRequest = await _apiService.createRequest(formData);

      // Save to local database
      if (_currentUserId != null) {
        await _localService.insertRequest(newRequest);
      }

      _requests.insert(0, newRequest);
      _logSuccess('Regularisation request created successfully');
      notifyListeners();

      return RequestResult(true, 'Request created successfully');
    } catch (e) {
      _errorMessage = 'Failed to create request: $e';
      _handleError(_errorMessage!);

      // Create offline request
      final offlineRequest = RegularisationRequest(
        id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId?.toString() ?? 'unknown',
        projectId: formData.projectId,
        date: formData.date,
        requestedDate: DateTime.now(),
        type: formData.type,
        status: RegularisationStatus.pending,
        reason: formData.reason,
        supportingDocs: formData.supportingDocs,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_currentUserId != null) {
        await _localService.insertRequest(offlineRequest);
      }
      _requests.insert(0, offlineRequest);
      notifyListeners();

      return RequestResult(
        true,
        'Request saved offline. Will sync when online.',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Update regularisation request
  Future<RequestResult> updateRegularisationRequest(
    String requestId,
    RegularisationFormData formData,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final validationError = formData.validate();
      if (validationError != null) {
        return RequestResult(false, validationError);
      }

      final updatedRequest = await _apiService.updateRequest(
        requestId,
        formData,
      );

      // Update local database
      if (_currentUserId != null) {
        await _localService.insertRequest(updatedRequest);
      }

      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = updatedRequest;
      }

      _logSuccess('Regularisation request updated successfully');
      notifyListeners();
      return RequestResult(true, 'Request updated successfully');
    } catch (e) {
      _errorMessage = 'Failed to update request: $e';
      _handleError(_errorMessage!);
      return RequestResult(false, 'Failed to update request');
    } finally {
      _setLoading(false);
    }
  }

  // Cancel regularisation request
  Future<RequestResult> cancelRegularisationRequest(String requestId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _apiService.cancelRequest(requestId);

      // Update local database
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        final cancelledRequest = _requests[index].copyWith(
          status: RegularisationStatus.cancelled,
          updatedAt: DateTime.now(),
        );

        if (_currentUserId != null) {
          await _localService.insertRequest(cancelledRequest);
        }

        _requests[index] = cancelledRequest;
      }

      _logSuccess('Regularisation request cancelled');
      notifyListeners();
      return RequestResult(true, 'Request cancelled successfully');
    } catch (e) {
      _errorMessage = 'Failed to cancel request: $e';
      _handleError(_errorMessage!);
      return RequestResult(false, 'Failed to cancel request');
    } finally {
      _setLoading(false);
    }
  }

  // Check if date can be regularised
  bool canRegulariseDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    // Allow regularisation for dates within last 30 days
    return difference.inDays <= 30 && difference.inDays >= 0;
  }

  // Get project name by ID
  String getProjectName(String projectId) {
    try {
      final project = _userProjects.firstWhere(
        (p) => p.id == projectId,
        orElse: () => Project(
          id: '',
          name: 'Unknown Project',
          description: '',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          status: 'active',
          priority: 'medium',
          progress: 0,
          budget: 0,
          client: '',
          assignedTeam: [],
          tasks: [],
          createdAt: DateTime.now(),
        ),
      );
      return project.name;
    } catch (e) {
      return 'Unknown Project';
    }
  }

  // Search requests
  List<RegularisationRequest> searchRequests(String query) {
    if (query.isEmpty) return filteredRequests;

    final lowercaseQuery = query.toLowerCase();
    return filteredRequests.where((request) {
      return request.reason.toLowerCase().contains(lowercaseQuery) ||
          request.displayType.toLowerCase().contains(lowercaseQuery) ||
          getProjectName(
            request.projectId,
          ).toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await initialize(userId: _currentUserId);
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String message) {
    if (kDebugMode) {
      print('❌ RegularisationViewModel: $message');
    }
  }

  void _logSuccess(String message) {
    if (kDebugMode) {
      print('✅ RegularisationViewModel: $message');
    }
  }

  void _logWarning(String message) {
    if (kDebugMode) {
      print('⚠️ RegularisationViewModel: $message');
    }
  }

  @override
  void dispose() {
    _requests.clear();
    _userProjects.clear();
    super.dispose();
  }
}

// Helper classes
enum RegularisationFilter { all, pending, approved, rejected }

class RequestResult {
  final bool success;
  final String message;

  RequestResult(this.success, this.message);
}
