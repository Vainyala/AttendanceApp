import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TimesheetProvider extends ChangeNotifier {
  // State variables
  TaskStatus? _selectedStatus; // Made nullable
  TaskPriority? _selectedPriority; // Made nullable
  TimeFilter _selectedTimeFilter = TimeFilter.daily;
  String _selectedProjectId = 'P001';
  DateTime _selectedDate = DateTime.now();
  DateTime? _fromDate;
  DateTime? _toDate;
  DateTime selectedDailyDate = DateTime.now();
  int selectedWeekIndex = 0;
  int selectedMonthIndex = DateTime.now().month;

  // Mock data
  List<Task> _tasks = [
    Task(
      taskId: 'T001',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Timesheet UI Design',
      type: 'Design',
      priority: TaskPriority.high,
      estEndDate: DateTime(2025, 12, 7),
      estEffortHrs: 8.0,
      status: TaskStatus.open,
      description: 'Design the timesheet UI module',
      deliverables: 'UI mockups and specifications',
      billable: false,
    ),
    Task(
      taskId: 'T002',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Backend API Integration',
      type: 'Development',
      priority: TaskPriority.urgent,
      estEndDate: DateTime(2025, 12,6),
      actualEndDate: DateTime(2025, 12, 29),
      estEffortHrs: 12.0,
      actualEffortHrs: 14.0,
      status: TaskStatus.assigned,
      description: 'Integrate REST APIs',
      deliverables: 'Working API integration',
      managerComments: 'good',
      taskHistory: 'Working API integration',
      billable: true,
    ),
    Task(
      taskId: 'T003',
      projectId: 'P002',
      projectName: 'Project Beta',
      taskName: 'Database Schema Design',
      type: 'Design',
      priority: TaskPriority.medium,
      estEndDate: DateTime(2025, 12, 5),
      actualEndDate: DateTime(2025, 12, 27),
      estEffortHrs: 4.0,
      actualEffortHrs: 15.0,
      status: TaskStatus.pending,
      description: 'Integrate REST APIs',
      deliverables: 'Working API integration',
      managerComments: 'good',
      taskHistory: 'Working API integration',
      billable: true,
    ),
    Task(
      taskId: 'T004',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Unit Testing',
      type: 'Testing',
      priority: TaskPriority.normal,
      estEndDate: DateTime(2025, 12, 5),
      actualEndDate: DateTime(2025, 12, 27),
      estEffortHrs: 4.0,
      actualEffortHrs: 9.0,
      status: TaskStatus.resolved,
      description: 'Integrate REST APIs',
      deliverables: 'Working API integration',
      managerComments: 'good',
      taskHistory: 'Working API integration',
      billable: false,
    ),
    Task(
      taskId: 'T005',
      projectId: 'P003',
      projectName: 'Project Gamma',
      taskName: 'Code Review',
      type: 'Review',
      priority: TaskPriority.high,
      estEndDate: DateTime(2025, 11, 24),
      actualEndDate: DateTime(2025, 12, 27),
      estEffortHrs: 4.0,
      actualEffortHrs: 9.0,
      status: TaskStatus.closed,
      description: 'Integrate REST APIs',
      deliverables: 'Working API integration',
      managerComments: 'good',
      taskHistory: 'Working API integration',
      billable: false,
    ),
    Task(
      taskId: 'T006',
      projectId: 'P001',
      projectName: 'Project Alpha',
      taskName: 'Backend API Integration - Phase 2',
      type: 'Development',
      priority: TaskPriority.urgent,
      estEndDate: DateTime(2025, 11, 25),
      actualEndDate: DateTime(2025, 12, 25),
      estEffortHrs: 12.0,
      actualEffortHrs: 24.0,
      status: TaskStatus.assigned,
      description: 'Integrate REST APIs',
      deliverables: 'Working API integration',
      managerComments: '........',
      taskHistory: 'Working API integration',
      billable: true,
    ),
  ];

  // Getters
  TaskStatus? get selectedStatus => _selectedStatus;
  TaskPriority? get selectedPriority => _selectedPriority;
  TimeFilter get selectedTimeFilter => _selectedTimeFilter;
  String get selectedProjectId => _selectedProjectId;
  DateTime get selectedDate => _selectedDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  List<Task> get allTasks => _tasks;

  // Initialize with null (no filter selected)
  TimesheetProvider() {
    _selectedStatus = null;
    _selectedPriority = null;
  }

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

  // FIXED: Setters now accept null to clear filters
  void setSelectedStatus(TaskStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSelectedPriority(TaskPriority? priority) {
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

  bool isSameDate(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// WEEK FILTER
  List<Task> filterByWeek(int weekIndex) {
    DateTime now = DateTime.now();
    DateTime start = now.subtract(Duration(days: (weekIndex + 1) * 7));
    DateTime end = now.subtract(Duration(days: weekIndex * 7));

    return _tasks
        .where((t) => t.estEndDate.isAfter(start) && t.estEndDate.isBefore(end))
        .toList();
  }

  /// MONTH FILTER
  List<Task> filterByMonth(int month) {
    return _tasks
        .where((t) =>
    t.estEndDate.month == month &&
        t.estEndDate.year == DateTime.now().year)
        .toList();
  }

  /// MAIN FILTER
  List<Task> getFilteredTasks() {
    if (selectedTimeFilter == TimeFilter.daily) {
      return _tasks
          .where((t) => isSameDate(t.estEndDate, selectedDailyDate))
          .toList();
    }
    if (selectedTimeFilter == TimeFilter.weekly) {
      return filterByWeek(selectedWeekIndex);
    }
    if (selectedTimeFilter == TimeFilter.monthly) {
      return filterByMonth(selectedMonthIndex);
    }
    return allTasks;
  }

  void setDailyDate(DateTime date) {
    selectedDailyDate = date;
    notifyListeners();
  }

  void setWeekIndex(int index) {
    selectedWeekIndex = index;
    notifyListeners();
  }

  void setMonthIndex(int index) {
    selectedMonthIndex = index;
    notifyListeners();
  }

  void incrementMonthIndex() {
    if (selectedMonthIndex < 12) {
      selectedMonthIndex++;
      notifyListeners();
    }
  }

  void decrementMonthIndex() {
    if (selectedMonthIndex > 1) {
      selectedMonthIndex--;
      notifyListeners();
    }
  }

  void incrementWeekIndex() {
    selectedWeekIndex++;
    notifyListeners();
  }

  void decrementWeekIndex() {
    if (selectedWeekIndex > 0) {
      selectedWeekIndex--;
      notifyListeners();
    }
  }

  void setFilter(TimeFilter filter) {
    _selectedTimeFilter = filter;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedStatus = null;
    _selectedPriority = null;
    notifyListeners();
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