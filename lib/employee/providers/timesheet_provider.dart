import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TimesheetProvider extends ChangeNotifier {
  // State variables
  TaskStatus _selectedStatus = TaskStatus.assigned;
  TaskPriority _selectedPriority = TaskPriority.urgent;
  TimeFilter _selectedTimeFilter = TimeFilter.daily;
  String _selectedProjectId = 'P001';
  DateTime _selectedDate = DateTime.now();
  DateTime? _fromDate;
  DateTime? _toDate;

  // Mock data
  List<Task> _tasks = [
    Task(
      taskId: 'T001',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Timesheet UI Design',
      type: 'Design',
      priority: TaskPriority.high,
      estEndDate: DateTime(2025, 11, 27),
      estEffortHrs: 8.0,
      status: TaskStatus.open,
      description: 'Design the timesheet UI module',
      deliverables: 'UI mockups and specifications',
    ),
    Task(
      taskId: 'T002',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Backend API Integration',
      type: 'Development',
      priority: TaskPriority.urgent,
      estEndDate: DateTime(2025, 11, 25),
      estEffortHrs: 12.0,
      status: TaskStatus.assigned,
      description: 'Integrate REST APIs',
      deliverables: 'Working API integration',
    ),
    Task(
      taskId: 'T003',
      projectId: 'P002',
      projectName: 'Project Beta',
      taskName: 'Database Schema Design',
      type: 'Design',
      priority: TaskPriority.medium,
      estEndDate: DateTime(2025, 11, 28),
      estEffortHrs: 6.0,
      status: TaskStatus.pending,
    ),
    Task(
      taskId: 'T004',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Unit Testing',
      type: 'Testing',
      priority: TaskPriority.normal,
      estEndDate: DateTime(2025, 11, 26),
      estEffortHrs: 10.0,
      status: TaskStatus.resolved,
    ),
    Task(
      taskId: 'T005',
      projectId: 'P003',
      projectName: 'Project Gamma',
      taskName: 'Code Review',
      type: 'Review',
      priority: TaskPriority.high,
      estEndDate: DateTime(2025, 11, 24),
      estEffortHrs: 4.0,
      status: TaskStatus.closed,
    ),
    Task(
      taskId: 'T001',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Timesheet UI Design',
      type: 'Design',
      priority: TaskPriority.high,
      estEndDate: DateTime(2025, 11, 27),
      estEffortHrs: 8.0,
      status: TaskStatus.open,
      description: 'Design the timesheet UI module',
      deliverables: 'UI mockups and specifications',
    ),
    Task(
      taskId: 'T002',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Backend API Integration',
      type: 'Development',
      priority: TaskPriority.urgent,
      estEndDate: DateTime(2025, 11, 25),
      estEffortHrs: 12.0,
      status: TaskStatus.assigned,
      description: 'Integrate REST APIs',
      deliverables: 'Working API integration',
    ),
    Task(
      taskId: 'T003',
      projectId: 'P002',
      projectName: 'Project Beta',
      taskName: 'Database Schema Design',
      type: 'Design',
      priority: TaskPriority.medium,
      estEndDate: DateTime(2025, 11, 28),
      estEffortHrs: 6.0,
      status: TaskStatus.pending,
    ),
    Task(
      taskId: 'T004',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Unit Testing',
      type: 'Testing',
      priority: TaskPriority.normal,
      estEndDate: DateTime(2025, 11, 26),
      estEffortHrs: 10.0,
      status: TaskStatus.resolved,
    ),
    Task(
      taskId: 'T005',
      projectId: 'P003',
      projectName: 'Project Gamma',
      taskName: 'Code Review',
      type: 'Review',
      priority: TaskPriority.high,
      estEndDate: DateTime(2025, 11, 24),
      estEffortHrs: 4.0,
      status: TaskStatus.closed,
    ),
  ];

  // Getters
  TaskStatus get selectedStatus => _selectedStatus;
  TaskPriority get selectedPriority => _selectedPriority;
  TimeFilter get selectedTimeFilter => _selectedTimeFilter;
  String get selectedProjectId => _selectedProjectId;
  DateTime get selectedDate => _selectedDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  List<Task> get allTasks => _tasks;

  // Get tasks filtered by status
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Get tasks filtered by priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // Get count by status
  int getStatusCount(TaskStatus status) {
    return getTasksByStatus(status).length;
  }

  // Get count by priority
  int getPriorityCount(TaskPriority priority) {
    return getTasksByPriority(priority).length;
  }

  // Get unique projects
  List<Map<String, String>> get projects {
    final projectMap = <String, String>{};
    for (var task in _tasks) {
      projectMap[task.projectId] = task.projectName;
    }
    return projectMap.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();
  }

  // Get tasks by project
  List<Task> getTasksByProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  // Get today's tasks
  List<Task> getTodaysTasks() {
    final today = DateTime.now();
    return _tasks.where((task) {
      return task.estEndDate.year == today.year &&
          task.estEndDate.month == today.month &&
          task.estEndDate.day == today.day;
    }).toList();
  }

  // Setters with notification
  void setSelectedStatus(TaskStatus status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSelectedPriority(TaskPriority priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSelectedTimeFilter(TimeFilter filter) {
    _selectedTimeFilter = filter;
    notifyListeners();
  }

  void setSelectedProject(String projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  // Add new task
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  // Update task
  void updateTask(String taskId, Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.taskId == taskId);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  // Get task by ID
  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.taskId == taskId);
    } catch (e) {
      return null;
    }
  }

  // Generate auto task ID
  String generateTaskId() {
    final maxId = _tasks.isEmpty
        ? 0
        : _tasks
        .map((t) => int.tryParse(t.taskId.substring(1)) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return 'T${(maxId + 1).toString().padLeft(3, '0')}';
  }
}
