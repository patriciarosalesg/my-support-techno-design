import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
    'https://fixit-backend-production-f90c.up.railway.app';

  static Future<http.Response> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    return http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
  }
}