import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class UserApiService {
  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.userById(userId)));
      final res = await http.put(
        uri,
        headers: await AuthService.getHeaders(),
        body: jsonEncode(updates),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated',
          'user': data['data']?['user'] ?? data['data'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update profile',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
