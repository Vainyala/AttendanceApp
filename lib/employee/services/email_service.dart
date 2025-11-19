import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // TODO: Add your API URL

  // Send OTP to email
  static Future<bool> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  // Verify OTP
  static Future<bool> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Get employee data after verification
  static Future<Map<String, dynamic>?> getEmployeeData(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employee-data?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching employee data: $e');
      return null;
    }
  }
}