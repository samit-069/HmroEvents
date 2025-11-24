import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class TicketApiService {
  static Future<bool> hasTicket(String eventId) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/tickets/has/$eventId'));
      final res = await http.get(uri, headers: await AuthService.getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          return (data['data']?['hasTicket'] ?? false) as bool;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getMyTickets() async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/tickets'));
      final res = await http.get(uri, headers: await AuthService.getHeaders());
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final list = (data['data']?['tickets'] as List? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return {
          'success': true,
          'tickets': list,
        };
      }
      return {
        'success': false,
        'tickets': <Map<String, dynamic>>[],
        'message': data['message'] ?? 'Failed to load tickets',
      };
    } catch (e) {
      return {
        'success': false,
        'tickets': <Map<String, dynamic>>[],
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> createTicket({
    required String eventId,
    required double amount,
    String? transactionId,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/tickets'));
      final res = await http.post(
        uri,
        headers: await AuthService.getHeaders(),
        body: jsonEncode({
          'eventId': eventId,
          'amount': amount,
          'transactionId': transactionId ?? '',
        }),
      );
      final data = jsonDecode(res.body);
      if ((res.statusCode == 201 || res.statusCode == 200) && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Ticket booked successfully',
          'ticket': data['data']?['ticket'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to save ticket',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
