
import 'package:flutter/material.dart';

import '../../models/regularisationmodels/manager_regularisation_model.dart';
import '../../models/regularisationmodels/regularisation_model.dart';

class ManagerRegularisationService {
  // Mock implementation - replace with actual API calls
  Future<List<ManagerRegularisationRequest>>
  getAllRegularisationRequests() async {
    await Future.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return [
      ManagerRegularisationRequest(
        id: '1',
        userId: 'user1',
        employeeId: 'EMP001',
        employeeName: 'Raj Sharma',
        employeeEmail: 'raj.sharma@nutantek.com', // ✅ Add employeeEmail
        employeeRole: 'Senior Developer',
        employeePhoto: '',
        projectId: 'project1',
        projectName: 'Mobile App Development',
        date: DateTime(now.year, now.month, 15),
        requestedDate: DateTime(now.year, now.month, 16),
        type: RegularisationType.fullDay,
        status: RegularisationStatus.pending,
        reason:
            'Traffic jam due to accident on the highway. Had to take alternate route which took extra time.',
        supportingDocs: [],
        actualCheckIn: const TimeOfDay(hour: 10, minute: 30),
        actualCheckOut: const TimeOfDay(hour: 19, minute: 0),
        expectedCheckIn: const TimeOfDay(hour: 9, minute: 0),
        expectedCheckOut: const TimeOfDay(hour: 18, minute: 0),
        shortfallTime: const Duration(hours: 1, minutes: 30),
        createdAt: DateTime(now.year, now.month, 16),
        updatedAt: DateTime(now.year, now.month, 16),
      ),
      ManagerRegularisationRequest(
        id: '2',
        userId: 'user2',
        employeeId: 'EMP002',
        employeeName: 'Priya Singh',
        employeeEmail: 'priya.singh@nutantek.com', // ✅ Add employeeEmail
        employeeRole: 'UI/UX Designer',
        employeePhoto: '',
        projectId: 'project2',
        projectName: 'Website Redesign',
        date: DateTime(now.year, now.month, 16),
        requestedDate: DateTime(now.year, now.month, 17),
        approvedDate: DateTime(now.year, now.month, 17),
        type: RegularisationType.halfDay,
        status: RegularisationStatus.approved,
        reason:
            'Medical appointment for routine checkup. Had informed in advance.',
        managerRemarks:
            'Medical reason verified. Approved as per company policy.',
        approvedBy: 'Manager User',
        supportingDocs: [],
        actualCheckIn: const TimeOfDay(hour: 9, minute: 0),
        actualCheckOut: const TimeOfDay(hour: 16, minute: 0),
        expectedCheckIn: const TimeOfDay(hour: 9, minute: 0),
        expectedCheckOut: const TimeOfDay(hour: 18, minute: 0),
        shortfallTime: const Duration(hours: 2),
        createdAt: DateTime(now.year, now.month, 17),
        updatedAt: DateTime(now.year, now.month, 17),
      ),
      ManagerRegularisationRequest(
        id: '3',
        userId: 'user3',
        employeeId: 'EMP003',
        employeeName: 'Amit Kumar',
        employeeEmail: 'amit.kumar@nutantek.com', // ✅ Add employeeEmail
        employeeRole: 'QA Engineer',
        employeePhoto: '',
        projectId: 'project1',
        projectName: 'Mobile App Development',
        date: DateTime(now.year, now.month, 17),
        requestedDate: DateTime(now.year, now.month, 18),
        type: RegularisationType.checkIn,
        status: RegularisationStatus.pending,
        reason:
            'Forgot to punch in the biometric system. Was present and working.',
        supportingDocs: [],
        actualCheckIn: const TimeOfDay(hour: 9, minute: 15),
        actualCheckOut: const TimeOfDay(hour: 18, minute: 45),
        expectedCheckIn: const TimeOfDay(hour: 9, minute: 0),
        expectedCheckOut: const TimeOfDay(hour: 18, minute: 0),
        shortfallTime: const Duration(minutes: 15),
        createdAt: DateTime(now.year, now.month, 18),
        updatedAt: DateTime(now.year, now.month, 18),
      ),
      // ✅ Additional sample data for more employees
      ManagerRegularisationRequest(
        id: '4',
        userId: 'user4',
        employeeId: 'EMP004',
        employeeName: 'Neha Patel',
        employeeEmail: 'neha.patel@nutantek.com', // ✅ Add employeeEmail
        employeeRole: 'Project Manager',
        employeePhoto: '',
        projectId: 'project3',
        projectName: 'CRM Implementation',
        date: DateTime(now.year, now.month, 18),
        requestedDate: DateTime(now.year, now.month, 19),
        type: RegularisationType.checkOut,
        status: RegularisationStatus.pending,
        reason: 'Client meeting ran longer than expected.',
        supportingDocs: [],
        actualCheckIn: const TimeOfDay(hour: 9, minute: 0),
        actualCheckOut: const TimeOfDay(hour: 20, minute: 30),
        expectedCheckIn: const TimeOfDay(hour: 9, minute: 0),
        expectedCheckOut: const TimeOfDay(hour: 18, minute: 0),
        shortfallTime: const Duration(hours: 2, minutes: 30),
        createdAt: DateTime(now.year, now.month, 19),
        updatedAt: DateTime(now.year, now.month, 19),
      ),
      ManagerRegularisationRequest(
        id: '5',
        userId: 'user5',
        employeeId: 'EMP005',
        employeeName: 'Suresh Verma',
        employeeEmail: 'suresh.verma@nutantek.com', // ✅ Add employeeEmail
        employeeRole: 'Backend Developer',
        employeePhoto: '',
        projectId: 'project4',
        projectName: 'Healthcare Management System',
        date: DateTime(now.year, now.month, 19),
        requestedDate: DateTime(now.year, now.month, 20),
        approvedDate: DateTime(now.year, now.month, 20),
        type: RegularisationType.fullDay,
        status: RegularisationStatus.approved,
        reason: 'Worked from home due to severe weather conditions.',
        managerRemarks: 'Weather alert verified. Approved for remote work.',
        approvedBy: 'Manager User',
        supportingDocs: [],
        actualCheckIn: const TimeOfDay(hour: 9, minute: 0),
        actualCheckOut: const TimeOfDay(hour: 18, minute: 0),
        expectedCheckIn: const TimeOfDay(hour: 9, minute: 0),
        expectedCheckOut: const TimeOfDay(hour: 18, minute: 0),
        shortfallTime: const Duration(minutes: 0),
        createdAt: DateTime(now.year, now.month, 20),
        updatedAt: DateTime(now.year, now.month, 20),
      ),
    ];
  }

  Future<ManagerRegularisationStats> getRegularisationStats() async {
    final requests = await getAllRegularisationRequests();
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);

    final currentMonthRequests = requests
        .where(
          (request) =>
              request.date.isAfter(currentMonthStart) ||
              request.date.isAtSameMomentAs(currentMonthStart),
        )
        .length;

    return ManagerRegularisationStats(
      totalRequests: requests.length,
      pendingRequests: requests.where((r) => r.isPending).length,
      approvedRequests: requests.where((r) => r.isApproved).length,
      rejectedRequests: requests.where((r) => r.isRejected).length,
      currentMonthRequests: currentMonthRequests,
    );
  }

  Future<void> approveRequest(String requestId, String managerRemarks) async {
    await Future.delayed(const Duration(seconds: 1));
    // API call to approve request with manager remarks
    print('Request $requestId approved with remarks: $managerRemarks');
  }

  Future<void> rejectRequest(String requestId, String managerRemarks) async {
    await Future.delayed(const Duration(seconds: 1));
    // API call to reject request with manager remarks
    print('Request $requestId rejected with remarks: $managerRemarks');
  }

  Future<void> requestMoreInfo(String requestId, String managerRemarks) async {
    await Future.delayed(const Duration(seconds: 1));
    // API call to request more information
    print('More info requested for $requestId: $managerRemarks');
  }

  // Export to Excel functionality
  Future<void> exportToExcel(
    List<ManagerRegularisationRequest> requests,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    // Implement Excel export logic
    print('Exporting ${requests.length} requests to Excel');
  }
}
