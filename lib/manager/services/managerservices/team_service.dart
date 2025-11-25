import 'package:attendanceapp/manager/models/team_model.dart';

class TeamService {
  Future<List<TeamMember>> getTeamMembers(String managerEmail) async {
    // Mock data with phone numbers
    return [
      TeamMember(
        name: 'Raj Sharma',
        email: 'raj.sharma@nutantek.com',
        role: 'Senior Developer',
        status: 'active',
        phoneNumber: '+919876543210', // ✅ Add phone number
        joinDate: DateTime(2023, 1, 15), // ✅ Add required parameter
        department: 'Engineering', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Priya Singh',
        email: 'priya.singh@nutantek.com',
        role: 'UI/UX Designer',
        status: 'active',
        phoneNumber: '+919876543211', // ✅ Add phone number
        joinDate: DateTime(2023, 3, 20), // ✅ Add required parameter
        department: 'Design', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Amit Kumar',
        email: 'amit.kumar@nutantek.com',
        role: 'QA Engineer',
        status: 'active',
        phoneNumber: '+919876543212', // ✅ Add phone number
        joinDate: DateTime(2023, 2, 10), // ✅ Add required parameter
        department: 'Quality Assurance', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Neha Patel',
        email: 'neha.patel@nutantek.com',
        role: 'Project Manager',
        status: 'active',
        phoneNumber: '+919876543213', // ✅ Add phone number
        joinDate: DateTime(2022, 12, 1), // ✅ Add required parameter
        department: 'Management', // ✅ Add required parameter
      ),
      TeamMember(
        name: 'Suresh Verma',
        email: 'suresh.verma@nutantek.com',
        role: 'Backend Developer',
        status: 'active',
        phoneNumber: '+919876543214', // ✅ Add phone number
        joinDate: DateTime(2023, 4, 5), // ✅ Add required parameter
        department: 'Engineering', // ✅ Add required parameter
      ),
    ];
  }
}

// import 'package:attendanceapp/models/team_model.dart';

// class TeamService {
//   Future<List<TeamMember>> getTeamMembers(String managerEmail) async {
//     // Mock data with phone numbers
//     return [
//       TeamMember(
//         name: 'Raj Sharma',
//         email: 'raj.sharma@nutantek.com',
//         role: 'Senior Developer',
//         status: 'active',
//         phoneNumber: '+919876543210', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Priya Singh',
//         email: 'priya.singh@nutantek.com',
//         role: 'UI/UX Designer',
//         status: 'active',
//         phoneNumber: '+919876543211', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Amit Kumar',
//         email: 'amit.kumar@nutantek.com',
//         role: 'QA Engineer',
//         status: 'active',
//         phoneNumber: '+919876543212', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Neha Patel',
//         email: 'neha.patel@nutantek.com',
//         role: 'Project Manager',
//         status: 'active',
//         phoneNumber: '+919876543213', // ✅ Add phone number
//       ),
//       TeamMember(
//         name: 'Suresh Verma',
//         email: 'suresh.verma@nutantek.com',
//         role: 'Backend Developer',
//         status: 'active',
//         phoneNumber: '+919876543214', // ✅ Add phone number
//       ),
//     ];
//   }
// }

// import 'package:attendanceapp/models/team_model.dart';

// class TeamService {
//   Future<List<TeamMember>> getTeamMembers(String managerEmail) async {
//     // Mock data - replace with SQLite implementation
//     return [
//       TeamMember(
//         name: 'Raj Sharma',
//         email: 'raj.sharma@nutantek.com',
//         role: 'Senior Developer',
//         status: 'active',
//       ),
//       TeamMember(
//         name: 'Priya Singh',
//         email: 'priya.singh@nutantek.com',
//         role: 'UI/UX Designer',
//         status: 'active',
//       ),
//       TeamMember(
//         name: 'Amit Kumar',
//         email: 'amit.kumar@nutantek.com',
//         role: 'QA Engineer',
//         status: 'active',
//       ),
//     ];
//   }
// }
