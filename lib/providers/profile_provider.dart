import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  // Editable fields
  String _phoneNumber = '+91-9767731178';
  String _email = 'vainyala.samal@nutantek.com';
  String _emergencyContact = '+91-9876543210';

  // Getters
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String get emergencyContact => _emergencyContact;

  // Setters
  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setEmergencyContact(String value) {
    _emergencyContact = value;
    notifyListeners();
  }

  // Update multiple fields at once
  void updateContactDetails(String phoneNumber, String email, String emergencyContact) {
    _phoneNumber = phoneNumber;
    _email = email;
    _emergencyContact = emergencyContact;
    notifyListeners();
  }

  // Reset to default values
  void resetContactDetails() {
    _phoneNumber = '+91-9767731178';
    _email = 'vainyala.samal@nutantek.com';
    _emergencyContact = '+91-9876543210';
    notifyListeners();
  }
}