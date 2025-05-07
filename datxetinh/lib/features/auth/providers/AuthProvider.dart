  import 'package:flutter/material.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'dart:developer' as developer;
  import '/../../core/Constants.dart';
  import '/../../core/services/Auth.dart';

  class AuthProvider with ChangeNotifier {
    final _storage = const FlutterSecureStorage();
    bool _isAuthenticated = false;
    bool _isLoading = false;
    String? _token;
    String? _userId;

    bool get isAuthenticated => _isAuthenticated;
    bool get isLoading => _isLoading;
    String? get token => _token;
    String? get userId => _userId;

    AuthProvider(AuthService read) {
      _loadAuthState();
    }

    Future<void> _loadAuthState() async {
      _token = await _storage.read(key: Constants.authTokenKey);
      _userId = await _storage.read(key: Constants.userIdKey);

      if (_token != null) {
        try {
          final response = await http.get(
            Uri.parse('${Constants.authBaseUrl}/api/auth/verify'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
          );
          int statusCode = response.statusCode;
          developer.log('Verify token response: statusCode=$statusCode');
          if (statusCode == 200) {
            _isAuthenticated = true;
          } else {
            await _clearAuthState();
          }
        } catch (e) {
          developer.log('Token verification failed: $e');
          await _clearAuthState();
        }
      }
      notifyListeners();
    }

    Future<void> _clearAuthState() async {
      _token = null;
      _userId = null;
      _isAuthenticated = false;
      await _storage.delete(key: Constants.authTokenKey);
      await _storage.delete(key: Constants.userIdKey);
      notifyListeners();
    }

    Future<void> login(String email, String password) async {
      try {
        _isLoading = true;
        notifyListeners();

        final response = await http.post(
          Uri.parse('${Constants.authBaseUrl}${Constants.loginEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        int statusCode = response.statusCode;
        developer
            .log('Login response: statusCode=$statusCode, body=${response.body}');

        if (statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          if (data['success'] == true) {
            _token = data['token'] as String?;
            _userId = data['userId']?.toString();
            _isAuthenticated = true;

            await _storage.write(key: Constants.authTokenKey, value: _token);
            await _storage.write(key: Constants.userIdKey, value: _userId);
          } else {
            throw Exception(data['message'] ?? 'Đăng nhập thất bại');
          }
        } else {
          throw Exception(
              'Đăng nhập thất bại: Mã trạng thái $statusCode - ${response.body}');
        }
      } catch (e) {
        developer.log('Login error: $e');
        throw Exception('Đăng nhập thất bại: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }

    Future<void> register({
      required String email,
      required String password,
      required String role,
    }) async {
      try {
        _isLoading = true;
        notifyListeners();

        final data = await AuthService.register(email, password, role);
        _userId = data['userId']?.toString(); // Ensure userId is a String
        _token = data['token'] as String?;
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        _userId = null;
        _token = null;
        _isAuthenticated = false;
        notifyListeners();
        developer.log('Registration error: $e');
        throw Exception('Đăng ký thất bại: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }

    Future<void> logout() async {
      try {
        _isLoading = true;
        notifyListeners();

        await AuthService.logout();
        await _clearAuthState();
      } catch (e) {
        developer.log('Logout failed: $e');
        throw Exception('Đăng xuất thất bại: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
