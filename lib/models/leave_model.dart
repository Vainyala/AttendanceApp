import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LeaveModel {
  final String id;
  final String userId;
  final DateTime fromDate;
  final DateTime toDate;
  final TimeOfDay fromTime;
  final TimeOfDay toTime;
  final String leaveType;
  final String notes;
  final bool isHalfDayFrom;
  final bool isHalfDayTo;
  final String status; // pending, approved, rejected
  final DateTime appliedDate;

  LeaveModel({
    required this.id,
    required this.userId,
    required this.fromDate,
    required this.toDate,
    required this.fromTime,
    required this.toTime,
    required this.leaveType,
    required this.notes,
    this.isHalfDayFrom = false,
    this.isHalfDayTo = false,
    this.status = 'pending',
    required this.appliedDate,
  });
}