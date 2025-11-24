import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  static String? _token;

  static Future<Map<String, String>> getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.login));
      final res = await http.post(
        uri,
        headers: await getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        _token = data['data']['token'];
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': data['data']['user'],
          'token': _token,
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Invalid credentials',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.me));
      final res = await http.get(uri, headers: await getHeaders());
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': data['data']['user'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch user',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static String? get token => _token;
  static void logout() {
    _token = null;
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String role = 'user',
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.register));
      final res = await http.post(
        uri,
        headers: await getHeaders(),
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone ?? '',
          'role': role,
        }),
      );
      final data = jsonDecode(res.body);
      if ((res.statusCode == 201 || res.statusCode == 200) && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registered successfully',
          'user': data['data']?['user'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
        'errors': data['errors'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/auth/change-password'));
      final res = await http.post(
        uri,
        headers: await getHeaders(),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password updated successfully',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update password',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
