import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../database/db_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final _storage = const FlutterSecureStorage();
  final _dbHelper = DatabaseHelper.instance;

  static const String _baseUrl = 'YOUR_API_BASE_URL'; // Replace with your API URL
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  AuthService._init();

  // Login with JWT
  Future<Map<String, dynamic>> login(String countryCode, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': '$countryCode$phone',
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Store tokens securely
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _refreshTokenKey, value: data['refreshToken']);
        await _storage.write(key: _userIdKey, value: data['user']['id'].toString());

        // Store user data in SQLite
        await _dbHelper.insertUser({
          'user_id': data['user']['id'].toString(),
          'name': data['user']['name'] ?? '',
          'email': data['user']['email'] ?? '',
          'phone': data['user']['phone'] ?? '',
          'role': data['user']['role'] ?? 'user',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        return {'success': true, 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Refresh JWT token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _tokenKey, value: data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Make authenticated API call
  Future<http.Response> authenticatedRequest(
      String endpoint, {
        String method = 'GET',
        Map<String, dynamic>? body,
      }) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http.Response response;

    switch (method.toUpperCase()) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: jsonEncode(body));
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: jsonEncode(body));
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        response = await http.get(uri, headers: headers);
    }

    // If token expired, try to refresh
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        // Retry the request with new token
        token = await getToken();
        headers['Authorization'] = 'Bearer $token';

        switch (method.toUpperCase()) {
          case 'POST':
            response = await http.post(uri, headers: headers, body: jsonEncode(body));
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers, body: jsonEncode(body));
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
          default:
            response = await http.get(uri, headers: headers);
        }
      }
    }

    return response;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _dbHelper.clearAllData();
  }

  // Get current user from SQLite
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userId = await getUserId();
    if (userId == null) return null;
    return await _dbHelper.getUserById(userId);
  }
}