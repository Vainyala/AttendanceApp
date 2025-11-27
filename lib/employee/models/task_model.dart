import 'package:flutter/material.dart';

enum TaskStatus { assigned, resolved, closed, pending, open }
enum TaskPriority { urgent, high, medium, normal }
enum TimeFilter { daily, weekly, monthly }

class Task {
  final String taskId;
  final String projectId;
  final String projectName;
  final String taskName;
  final String type;
  final TaskPriority priority;
  final DateTime estEndDate;
  final double estEffortHrs;
  final TaskStatus status;
  final String? description;
  final String? deliverables;

  Task({
    required this.taskId,
    required this.projectId,
    required this.projectName,
    required this.taskName,
    required this.type,
    required this.priority,
    required this.estEndDate,
    required this.estEffortHrs,
    required this.status,
    this.description,
    this.deliverables,
  });
}