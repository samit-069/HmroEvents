import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';
import '../models/event.dart';

class EventApiService {
  static Future<List<Event>> getEvents({String? category, String? search, String? userId, bool? bookmarked}) async {
    try {
      final query = <String, String>{};
      if (category != null && category != 'All Events') query['category'] = category;
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (userId != null) query['userId'] = userId;
      if (bookmarked != null) query['bookmarked'] = bookmarked.toString();
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.events)).replace(queryParameters: query);
      final res = await http.get(uri, headers: await AuthService.getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          final list = (data['data']['events'] as List).map((e) => _eventFromJson(e)).toList();
          return list;
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateEvent({
    required String id,
    String? title,
    String? category,
    DateTime? dateTime,
    String? location,
    int? attendees,
    String? price,
    String? imageUrl,
    String? iconEmoji,
    String? organizer,
    String? description,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.eventById(id)));
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (category != null) body['category'] = category;
      if (dateTime != null) body['dateTime'] = dateTime.toIso8601String();
      if (location != null) body['location'] = location;
      if (attendees != null) body['attendees'] = attendees;
      if (price != null) body['price'] = price;
      if (imageUrl != null) body['imageUrl'] = imageUrl;
      if (iconEmoji != null) body['iconEmoji'] = iconEmoji;
      if (organizer != null) body['organizer'] = organizer;
      if (description != null) body['description'] = description;

      final res = await http.put(
        uri,
        headers: await AuthService.getHeaders(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Event updated successfully',
          'event': _eventFromJson(data['data']['event']),
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update event',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteEvent(String id) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.eventById(id)));
      final res = await http.delete(uri, headers: await AuthService.getHeaders());
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Event deleted successfully',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete event',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Event?> getEventById(String id) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.eventById(id)));
      final res = await http.get(uri, headers: await AuthService.getHeaders());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          return _eventFromJson(data['data']['event']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createEvent({
    required String title,
    required String category,
    required DateTime dateTime,
    required String location,
    required int attendees,
    required String price,
    String imageUrl = '',
    String iconEmoji = '',
    String organizer = '',
    String description = '',
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.events));
      final res = await http.post(
        uri,
        headers: await AuthService.getHeaders(),
        body: jsonEncode({
          'title': title,
          'category': category,
          'dateTime': dateTime.toIso8601String(),
          'location': location,
          'attendees': attendees,
          'price': price,
          'imageUrl': imageUrl,
          'iconEmoji': iconEmoji,
          'organizer': organizer,
          'description': description,
        }),
      );
      final data = jsonDecode(res.body);
      if ((res.statusCode == 201 || res.statusCode == 200) && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Event created successfully',
          'event': _eventFromJson(data['data']['event']),
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to create event',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Event _eventFromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : DateTime.now(),
      location: json['location'] ?? '',
      attendees: json['attendees'] ?? 0,
      price: json['price'] ?? 'Free Entry',
      imageUrl: json['imageUrl'] ?? '',
      iconEmoji: json['iconEmoji'] ?? '',
      organizer: json['organizer'] ?? '',
      description: json['description'] ?? '',
      isBookmarked: json['isBookmarked'] ?? false,
      isUserCreated: json['isUserCreated'] ?? false,
    );
  }

  static Future<Map<String, dynamic>> toggleBookmark(String eventId) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.bookmarkEvent(eventId)));
      final res = await http.post(uri, headers: await AuthService.getHeaders());
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final ev = data['data']?['event'];
        return {
          'success': true,
          'message': data['message'] ?? 'Bookmark updated',
          'isBookmarked': ev != null ? (ev['isBookmarked'] ?? false) : null,
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update bookmark',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
