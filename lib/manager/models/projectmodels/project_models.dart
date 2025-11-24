import 'package:attendanceapp/manager/models/team_model.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // planning, active, completed, on-hold
  final String priority; // low, medium, high, urgent
  final double progress;
  final double budget;
  final String client;
  final List<TeamMember> assignedTeam;
  final List<ProjectTask> tasks;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.priority,
    required this.progress,
    required this.budget,
    required this.client,
    required this.assignedTeam,
    required this.tasks,
    required this.createdAt,
  });

  int get totalTasks => tasks.length;
  int get completedTasks =>
      tasks.where((task) => task.status == 'completed').length;
  int get teamSize => assignedTeam.length;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  bool get isOverdue => DateTime.now().isAfter(endDate);
}

class ProjectTask {
  final String id;
  final String title;
  final String description;
  final String status; // todo, in-progress, completed
  final String priority; // low, medium, high
  final DateTime dueDate;
  final List<String> assignedTo;
  final DateTime createdAt;

  ProjectTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.assignedTo,
    required this.createdAt,
  });
}

class ProjectFormData {
  String name = '';
  String description = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));
  String status = 'planning';
  String priority = 'medium';
  double budget = 0.0;
  String client = '';
  List<String> assignedTeamIds = [];
}
