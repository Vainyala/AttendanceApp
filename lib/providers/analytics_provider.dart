import 'package:flutter/material.dart';

enum AnalyticsMode { daily, weekly, monthly, quarterly }

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsMode _mode = AnalyticsMode.daily;
  DateTime _selectedDate = DateTime.now();
  int _selectedWeekIndex = 0;
  int _selectedMonthIndex = 0;
  int _selectedQuarterIndex = 0;
  String? _selectedProjectId;

  // Getters
  AnalyticsMode get mode => _mode;
  DateTime get selectedDate => _selectedDate;
  int get selectedWeekIndex => _selectedWeekIndex;
  int get selectedMonthIndex => _selectedMonthIndex;
  int get selectedQuarterIndex => _selectedQuarterIndex;
  String? get selectedProjectId => _selectedProjectId;

  // Setters with notifyListeners
  void setMode(AnalyticsMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setWeekIndex(int index) {
    _selectedWeekIndex = index;
    notifyListeners();
  }

  void setMonthIndex(int index) {
    _selectedMonthIndex = index;
    notifyListeners();
  }

  void setQuarterIndex(int index) {
    _selectedQuarterIndex = index;
    notifyListeners();
  }

  void setProjectId(String? id) {
    _selectedProjectId = id;
    notifyListeners();
  }
}