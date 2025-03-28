import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

class AuthRemoteRepository {
  final logger = Logger();

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          // 안드로이드는 10.0.2.2:8000 이라고 해야 함
        'http://10.0.2.2:8000/auth/signup',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    logger.i('Response body: ${response.body}');
      logger.i('Status code: ${response.statusCode}');
    } catch (e) {
      logger.e('Error: $e');
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse(
          // 안드로이드는 10.0.2.2:8000 이라고 해야 함
          'http://10.0.2.2:8000/auth/login',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      logger.i('Response body: ${response.body}');
      logger.i('Status code: ${response.statusCode}');

    } catch (e) {
      logger.e('Error: $e');
    }
  }
}
