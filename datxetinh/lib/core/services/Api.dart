import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '/../../core/Constants.dart';
import '/../../core/Models.dart';

class Api {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static WebSocketChannel? _webSocketChannel;
  static const int _timeout = Constants.apiTimeoutSeconds * 1000;

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> data) async {
    String baseUrl;
    if (endpoint.startsWith('/api/auth/')) {
      baseUrl = Constants.authBaseUrl; // Use authBaseUrl for auth endpoints
    } else {
      baseUrl = Constants.apiBaseUrl; // Use apiBaseUrl for other endpoints
    }
    final url = '$baseUrl$endpoint';
    developer.log('Sending POST to $url with data: $data');
    try {
      final response = await http
          .post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      )
          .timeout(Duration(milliseconds: _timeout), onTimeout: () {
        developer.log('Request to $url timed out');
        throw TimeoutException('Request timed out after $_timeout ms');
      });
      developer.log(
          'Received response from $url: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Error in POST request to $url: $e');
      throw e;
    }
  }

  Api() {
    connectWebSocket();
  }

  void connectWebSocket() {
    try {
      _webSocketChannel =
          WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/ws/trips'));
      _webSocketChannel!.stream.listen(
        (message) {
          developer.log('WebSocket received: $message');
          // Xử lý dữ liệu WebSocket nếu cần (VD: cập nhật chuyến đi)
          final data = jsonDecode(message);
          if (data['trips'] != null) {
            developer.log('Received trip updates: ${data['trips']}');
          }
        },
        onError: (error) {
          developer.log('WebSocket error: $error');
        },
        onDone: () {
          developer.log('WebSocket closed');
        },
      );
      _webSocketChannel!.sink.add('Request trip updates');
    } catch (e) {
      developer.log('WebSocket connection error: $e');
    }
  }

  void disconnectWebSocket() {
    _webSocketChannel?.sink.close();
    _webSocketChannel = null;
  }

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Constants.apiBaseUrl}${Constants.loginEndpoint}'),
            headers: await _getHeaders(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(
            key: Constants.jwtTokenKey, value: responseData['token']);
        await _storage.write(
            key: Constants.userIdKey, value: responseData['userId']);
        return {
          'userId': responseData['userId'],
          'token': responseData['token']
        };
      } else {
        throw Exception(responseData['error'] ?? Constants.loginFailed);
      }
    } catch (e) {
      throw Exception('${Constants.loginFailed}: $e');
    }
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String role) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Constants.apiBaseUrl}${Constants.registerEndpoint}'),
            headers: await _getHeaders(),
            body: jsonEncode(
                {'email': email, 'password': password, 'role': role}),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _storage.write(
            key: Constants.jwtTokenKey, value: responseData['token']);
        await _storage.write(
            key: Constants.userIdKey, value: responseData['userId']);
        return {
          'userId': responseData['userId'],
          'token': responseData['token']
        };
      } else {
        throw Exception(responseData['error'] ?? Constants.registrationFailed);
      }
    } catch (e) {
      throw Exception('${Constants.registrationFailed}: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: Constants.jwtTokenKey);
      await _storage.delete(key: Constants.userIdKey);
      disconnectWebSocket();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: Constants.jwtTokenKey);
    } catch (e) {
      throw Exception('Failed to get token: $e');
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: Constants.userIdKey);
    } catch (e) {
      throw Exception('Failed to get user ID: $e');
    }
  }

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Future<List<dynamic>> searchTrips({
    required String source,
    required String destination,
    required String date,
    required int passengers,
    double? maxBudget,
    String? preferredBusType,
    String? operatorType,
    int maxResults = 5,
    required String? token,
  }) async {
    final body = {
      'source': source,
      'destination': destination,
      'date': date,
      'passengers': passengers,
      'max_budget': maxBudget,
      'preferred_bus_type': preferredBusType,
      'operator_type': operatorType,
      'max_results': maxResults,
    };
    print('API search trips request: $body');
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}${Constants.searchTripsEndpoint}'),
      headers: headers,
      body: jsonEncode(body),
    );
    print(
        'API search trips response: statusCode=${response.statusCode}, body=${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search trips: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getTripById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${Constants.apiBaseUrl}/api/trips/$id'),
            headers: await _getHeaders(),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? Constants.genericError);
      }
    } catch (e) {
      throw Exception('Get trip failed: $e');
    }
  }

  Future<List<Trip>> getTrips() async {
    try {
      final response = await http
          .get(
            Uri.parse('${Constants.apiBaseUrl}${Constants.tripsEndpoint}'),
            headers: await _getHeaders(),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = responseData;
        return data.map((json) => Trip.fromJson(json)).toList();
      } else {
        throw Exception(responseData['error'] ?? Constants.genericError);
      }
    } catch (e) {
      throw Exception('Get trips failed: $e');
    }
  }

  Future<Map<String, dynamic>> bookTrip(String tripId, List<int> seats) async {
    try {
      final userId = await getUserId();
      final response = await http
          .post(
            Uri.parse('${Constants.apiBaseUrl}${Constants.bookingsEndpoint}'),
            headers: await _getHeaders(),
            body: jsonEncode(
                {'userId': userId, 'tripId': tripId, 'seats': seats}),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? Constants.bookingFailed);
      }
    } catch (e) {
      throw Exception('${Constants.bookingFailed}: $e');
    }
  }

  Future<List<Ticket>> getUserTickets(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
                '${Constants.apiBaseUrl}${Constants.bookingsEndpoint}/user/$userId'),
            headers: await _getHeaders(),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = responseData;
        return data.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw Exception(responseData['error'] ?? Constants.genericError);
      }
    } catch (e) {
      throw Exception('Get user tickets failed: $e');
    }
  }

  Future<void> cancelTicket(String ticketId) async {
    try {
      final response = await http
          .delete(
            Uri.parse(
                '${Constants.apiBaseUrl}${Constants.bookingsEndpoint}/$ticketId'),
            headers: await _getHeaders(),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      if (response.statusCode != 200) {
        throw Exception(
            jsonDecode(response.body)['error'] ?? Constants.genericError);
      }
    } catch (e) {
      throw Exception('Cancel ticket failed: $e');
    }
  }

  Future<Map<String, dynamic>> getLocations() async {
    try {
      final response = await http
          .get(
            Uri.parse('${Constants.apiBaseUrl}/api/locations'),
            headers: await _getHeaders(),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['error'] ?? 'Failed to fetch locations');
      }
    } catch (e) {
      throw Exception('Get locations failed: $e');
    }
  }

  Future<List<dynamic>> recommendTrips({
    required String source,
    required String destination,
    required String date,
    required int passengers,
    double? maxBudget,
    String? preferredBusType,
    String? operatorType,
    int maxResults = 10,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Constants.apiBaseUrl}/api/trips/recommend'),
            headers: await _getHeaders(),
            body: jsonEncode({
              'source': source,
              'destination': destination,
              'date': date,
              'passengers': passengers,
              'maxBudget': maxBudget,
              'preferredBusType': preferredBusType,
              'operatorType': operatorType,
              'maxResults': maxResults,
            }),
          )
          .timeout(Duration(seconds: Constants.apiTimeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
            responseData['error'] ?? 'Failed to fetch recommendations');
      }
    } catch (e) {
      throw Exception('Recommend trips failed: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: Constants.jwtTokenKey);
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
