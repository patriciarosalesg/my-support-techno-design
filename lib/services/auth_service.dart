import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl =
      'https://fixit-backend-production-0499.up.railway.app';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
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

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final accessToken = data['accessToken'];
      final userId = data['user']?['id'];
      final fullName = data['user']?['fullName'];
      final userEmail = data['user']?['email'];

      if (accessToken != null) {
        await _storage.write(
          key: 'accessToken',
          value: accessToken,
        );
      }

      if (userId != null) {
        await _storage.write(
          key: 'userId',
          value: userId.toString(),
        );
      }

      if (fullName != null) {
        await _storage.write(
          key: 'fullName',
          value: fullName,
        );
      }

      if (userEmail != null) {
        await _storage.write(
          key: 'userEmail',
          value: userEmail,
        );
      }

      return data;
    }

    throw Exception(
      data['message'] ?? 'No se pudo iniciar sesión.',
    );
  }

  Future<String?> obtenerToken() async {
    return await _storage.read(
      key: 'accessToken',
    );
  }

  Future<String?> obtenerIdUsuario() async {
    return await _storage.read(
      key: 'userId',
    );
  }

  Future<String?> obtenerNombreUsuario() async {
    return await _storage.read(
      key: 'fullName',
    );
  }

  Future<String?> obtenerCorreoUsuario() async {
    return await _storage.read(
      key: 'userEmail',
    );
  }

  Future<void> cerrarSesion() async {
    await _storage.delete(
      key: 'accessToken',
    );

    await _storage.delete(
      key: 'userId',
    );

    await _storage.delete(
      key: 'fullName',
    );

    await _storage.delete(
      key: 'userEmail',
    );
  }
}