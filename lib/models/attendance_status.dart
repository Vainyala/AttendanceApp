import 'dart:ui';
import 'package:flutter/material.dart';
enum AttendanceStatus {
  present,      // P
  absent,       // A
  partialLeave, // PL
  leave,        // L
  shortHalf,    // SHF
  holiday,      // H
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get code {
    switch (this) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.absent:
        return 'A';
      case AttendanceStatus.partialLeave:
        return 'PL';
      case AttendanceStatus.leave:
        return 'L';
      case AttendanceStatus.shortHalf:
        return 'SHF';
      case AttendanceStatus.holiday:
        return 'H';
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.partialLeave:
        return 'Partial Leave';
      case AttendanceStatus.leave:
        return 'Leave';
      case AttendanceStatus.shortHalf:
        return 'Short Half';
      case AttendanceStatus.holiday:
        return 'Holiday';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.partialLeave:
        return Colors.orange;
      case AttendanceStatus.leave:
        return Colors.blue;
      case AttendanceStatus.shortHalf:
        return Colors.amber;
      case AttendanceStatus.holiday:
        return Colors.purple;
    }
  }
}