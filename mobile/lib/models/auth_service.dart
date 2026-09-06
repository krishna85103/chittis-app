import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({
    required this.baseUrl,
  });

  Future<Map<String, dynamic>> signup(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> resendOtp(
    String email,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/api/auth/resend-otp?email=${Uri.encodeComponent(email)}',
      ),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {
      'success': false,
      'message': 'Invalid server response',
    };
  }
}
