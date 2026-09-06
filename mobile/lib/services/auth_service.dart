import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  AuthService({
    this.baseUrl = 'https://eminem-gdp-signing-validation.trycloudflare.com' ,
  });

  // ==========================================
  // SIGNUP
  // ==========================================

  Future<Map<String, dynamic>> signup(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server: $e',
      };
    }
  }

  // ==========================================
  // VERIFY OTP
  // ==========================================

  Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'otp': otp.trim(),
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server: $e',
      };
    }
  }

  // ==========================================
  // RESEND OTP
  // ==========================================

  Future<Map<String, dynamic>> resendOtp(
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server: $e',
      };
    }
  }

  // ==========================================
  // RESPONSE HANDLER
  // ==========================================

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'success': false,
        'message': 'Invalid response from server',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Server returned an invalid response '
            '(HTTP ${response.statusCode})',
      };
    }
  }
}
