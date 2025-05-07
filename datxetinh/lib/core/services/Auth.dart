import 'dart:convert';
import 'dart:developer' as developer;
import 'package:datxetinh/core/Constants.dart';
import '/core/services/Api.dart';

class AuthService {
  AuthService(Api read);

  static Future<Map<String, dynamic>> register(
      String email, String password, String role) async {
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    try {
      const url = Constants.registerEndpoint; // Pass only endpoint
      developer.log('Endpoint before Api.post: $url');
      final response = await Api.post(url, {
        'email': email,
        'password': password,
        'role': role,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await Api.write('auth_token', data['token']);
          await Api.write('user_id', data['userId']);
          return {
            'userId': data['userId'].toString(),
            'token': data['token'] as String,
          };
        } else {
          throw Exception(data['message'] ?? 'Registration failed');
        }
      } else {
        developer.log('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Registration failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Registration error in AuthService: $e');
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    try {
      const url = Constants.loginEndpoint; // Pass only endpoint
      developer.log('Endpoint before Api.post: $url');
      final response = await Api.post(url, {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await Api.write('auth_token', data['token']);
          await Api.write('user_id', data['userId']);
          return {
            'userId': data['userId'].toString(),
            'token': data['token'] as String,
          };
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        developer.log('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Login failed: HTTP ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Login error in AuthService: $e');
      throw Exception('Login failed: $e');
    }
  }

  static Future<void> logout() async {
    await Api.delete('auth_token');
    await Api.delete('user_id');
    await Api.delete('websocket');
  }

  Future<String?> getToken() async {
    return await Api.read('auth_token');
  }

  Future<String?> getUserId() async {
    return await Api.read('user_id');
  }
}
