import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AdminApiService {
  static Future<Map<String, dynamic>> getMetrics() async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/admin/metrics'));
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final d = data['data'] as Map<String, dynamic>;
        return {
          'success': true,
          'totalUsers': d['totalUsers'] ?? 0,
          'blockedUsers': d['blockedUsers'] ?? 0,
          'organizers': d['organizers'] ?? 0,
          'totalEvents': d['totalEvents'] ?? 0,
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load metrics'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/admin/users'));
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data']['users'] as List).cast<Map<String, dynamic>>();
        return list;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, dynamic>>> getOrganizers() async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/admin/users/organizers'));
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data']['users'] as List).cast<Map<String, dynamic>>();
        return list;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/admin/users/blocked'));
      final res = await http.get(uri);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data']['users'] as List).cast<Map<String, dynamic>>();
        return list;
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>> blockToggle(String userId) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/admin/users/$userId/block-toggle'));
      final res = await http.post(uri);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Failed to toggle block'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/admin/users/$userId'));
      final res = await http.put(uri, body: jsonEncode(updates), headers: {'Content-Type': 'application/json'});
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Failed to update user'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/admin/users/$userId'));
      final res = await http.delete(uri);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) return data;
      return {'success': false, 'message': data['message'] ?? 'Failed to delete user'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
