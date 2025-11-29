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
  final DateTime? actualEndDate;
  final double estEffortHrs;
  final double? actualEffortHrs;
  final TaskStatus status;
  final String description; // Made required
  final String? deliverables;
  final String? taskHistory;
  final String? managerComments;
  final String? notes;
  final bool billable;
  final List<AttachedFile>? attachedFiles; // NEW

  Task({
    required this.taskId,
    required this.projectId,
    required this.projectName,
    required this.taskName,
    required this.type,
    required this.priority,
    required this.estEndDate,
    this.actualEndDate,
    required this.estEffortHrs,
    this.actualEffortHrs,
    required this.status,
    required this.billable,
    this.taskHistory,
    this.managerComments,
    required this.description, // Required now
    this.deliverables,
    this.notes,
    this.attachedFiles,
  });
}

// NEW class for file attachments
class AttachedFile {
  final String fileName;
  final String filePath;
  final String fileType; // 'pdf', 'image', etc.

  AttachedFile({
    required this.fileName,
    required this.filePath,
    required this.fileType,
  });
}