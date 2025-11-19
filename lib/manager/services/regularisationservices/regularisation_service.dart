

import '../../models/projectmodels/project_models.dart' show Project;
import '../../models/regularisationmodels/regularisation_model.dart';

class RegularisationService {
  // Mock implementation - replace with actual API calls
  Future<List<RegularisationRequest>> getMyRegularisationRequests() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    return [
      RegularisationRequest(
        id: '1',
        userId: 'user1',
        projectId: 'project1',
        date: DateTime.now().subtract(const Duration(days: 2)),
        requestedDate: DateTime.now().subtract(const Duration(days: 1)),
        type: RegularisationType.fullDay,
        status: RegularisationStatus.pending,
        reason: 'Forgot to check-in',
        supportingDocs: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      RegularisationRequest(
        id: '2',
        userId: 'user1',
        projectId: 'project2',
        date: DateTime.now().subtract(const Duration(days: 5)),
        requestedDate: DateTime.now().subtract(const Duration(days: 4)),
        approvedDate: DateTime.now().subtract(const Duration(days: 3)),
        type: RegularisationType.checkOut,
        status: RegularisationStatus.approved,
        reason: 'System issue',
        approvedBy: 'manager1',
        supportingDocs: [],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<List<Project>> getUserProjects() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Project(
        id: 'project1',
        name: 'Mobile App Development',
        description: 'Flutter based mobile application',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 60)),
        status: 'active',
        priority: 'high',
        progress: 65.0,
        budget: 50000.0,
        client: 'Tech Corp',
        assignedTeam: [],
        tasks: [],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Project(
        id: 'project2',
        name: 'Website Redesign',
        description: 'Company website redesign project',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        status: 'active',
        priority: 'medium',
        progress: 30.0,
        budget: 25000.0,
        client: 'Design Studio',
        assignedTeam: [],
        tasks: [],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  Future<RegularisationRequest> createRequest(
    RegularisationFormData formData,
  ) async {
    await Future.delayed(const Duration(seconds: 2));

    return RegularisationRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id', // Get from auth
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
  }

  Future<RegularisationRequest> updateRequest(
    String requestId,
    RegularisationFormData formData,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    // In real implementation, fetch the existing request and update it
    return RegularisationRequest(
      id: requestId,
      userId: 'current_user_id',
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
  }

  Future<void> cancelRequest(String requestId) async {
    await Future.delayed(const Duration(seconds: 1));
    // API call to cancel request
  }
}
