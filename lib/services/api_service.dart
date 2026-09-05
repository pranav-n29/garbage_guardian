import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String baseUrl =
      'http://10.150.12.116:5000/api';

  static const String _tokenKey = 'auth_token';

  String? _token;

  // ---------------------------------------------------------------
  // LOGIN STATUS
  // ---------------------------------------------------------------

  bool get isLoggedIn =>
      _token != null && _token!.isNotEmpty;

  // ---------------------------------------------------------------
  // LOAD SAVED TOKEN
  // ---------------------------------------------------------------

  Future<void> initialize() async {
    final prefs =
        await SharedPreferences.getInstance();

    _token = prefs.getString(_tokenKey);
  }

  // ---------------------------------------------------------------
  // SAVE TOKEN
  // ---------------------------------------------------------------

  Future<void> setToken(String token) async {
    _token = token;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );
  }

  // ---------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------

  Future<void> clearToken() async {
    _token = null;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
  }

  // ---------------------------------------------------------------
  // HEADERS
  // ---------------------------------------------------------------

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null)
        'Authorization': 'Bearer $_token',
    };
  }

  // ---------------------------------------------------------------
  // SIGNUP
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    final data = _handleResponse(response);

    if (data['token'] != null) {
      await setToken(
        data['token'].toString(),
      );
    }

    return data;
  }

  // ---------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _handleResponse(response);

    if (data['token'] != null) {
      await setToken(
        data['token'].toString(),
      );
    }

    return data;
  }

  // ---------------------------------------------------------------
  // CURRENT USER
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  // ---------------------------------------------------------------
  // CREATE REPORT
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> createReport({
    required String binId,
    required String location,
    required String issueType,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: _headers,
      body: jsonEncode({
        'binId': binId,
        'location': location,
        'issueType': issueType,
        'description': description,
      }),
    );

    return _handleResponse(response);
  }

  // ---------------------------------------------------------------
  // GET MY REPORTS
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> getMyReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  // ---------------------------------------------------------------
  // GET ONE REPORT
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> getReport(
    String reportId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  // ---------------------------------------------------------------
  // RESPONSE HANDLER
  // ---------------------------------------------------------------

  Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      data['message']?.toString() ??
          'Request failed with status ${response.statusCode}',
    );
  }
}