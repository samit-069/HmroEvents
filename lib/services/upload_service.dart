import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'auth_service.dart';

class UploadService {
  static Future<Map<String, dynamic>> uploadImage(File file) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/upload/image'));
      final request = http.MultipartRequest('POST', uri);
      final token = AuthService.token;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('image', file.path));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      if (response.statusCode == 201 || response.statusCode == 200) {
        final url = body['data']?['url'];
        if (url is String && url.isNotEmpty) {
          return { 'success': true, 'url': url };
        }
      }
      return { 'success': false, 'message': body['message'] ?? 'Upload failed' };
    } catch (e) {
      return { 'success': false, 'message': e.toString() };
    }
  }
}
