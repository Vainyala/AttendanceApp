import 'package:attendanceapp/manager/models/project_model.dart';

class ProjectService {
  Future<List<Project>> getManagerProjects(String managerEmail) async {
    // Mock data - replace with SQLite implementation
    return [
      Project(
        name: 'E-Commerce Platform',
        description: 'Development of new e-commerce platform',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 30),
        status: 'active',
        teamSize: 8,
      ),
      Project(
        name: 'Mobile App Redesign',
        description: 'Redesign of customer mobile application',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 5, 31),
        status: 'active',
        teamSize: 5,
      ),
    ];
  }
}
