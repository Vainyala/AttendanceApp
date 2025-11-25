import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  static const List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String formatDateTime(DateTime dateTime) {
    return '${days[dateTime.weekday - 1]} ${months[dateTime.month - 1]} ${dateTime.day} ${dateTime.year}';
  }

  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  static String formatTimeOnly(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  static String formatFullDateTime(DateTime date, TimeOfDay time) {
    final formattedDate = formatDateTime(date);
    final formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return '$formattedDate at $formattedTime';
  }

}



class DateFormattingUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  static String formatDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String formatTimeWithPeriod(TimeOfDay time, String period) {
    return '${formatTime(time)} $period';
  }

}
