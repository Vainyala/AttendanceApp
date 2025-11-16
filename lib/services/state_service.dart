import 'package:flutter/material.dart';
import '../utils/app_colors.dart';



class StateService extends ChangeNotifier {
  // Regularisation data
  List<Map<String, dynamic>> _regularisationRecords = [];

  // Leave data
  List<Map<String, dynamic>> _appliedLeaves = [];

  List<Map<String, dynamic>> get regularisationRecords => _regularisationRecords;
  List<Map<String, dynamic>> get appliedLeaves => _appliedLeaves;

  void addRegularisation(Map<String, dynamic> record) {
    _regularisationRecords.add(record);
    notifyListeners();
  }

  void addLeave(Map<String, dynamic> leave) {
    _appliedLeaves.insert(0, leave);
    notifyListeners();
  }

  void updateLeave(String id, Map<String, dynamic> updatedLeave) {
    final index = _appliedLeaves.indexWhere((l) => l['id'] == id);
    if (index != -1) {
      _appliedLeaves[index] = updatedLeave;
      notifyListeners();
    }
  }

  void cancelLeave(String id) {
    _appliedLeaves.removeWhere((l) => l['id'] == id);
    notifyListeners();
  }
}