class ApiConfig {
  // Update this to your PC's IP so the phone can reach the backend
  // Example: http://192.168.1.50:5000/api
  static const String baseUrl = 'http://192.168.110.161:5000/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // User endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static String blockUser(String id) => '/users/$id/block';
  static const String organizers = '/users/organizers';
  static const String blockedUsers = '/users/blocked';

  // Event endpoints
  static const String events = '/events';
  static String eventById(String id) => '/events/$id';
  static String bookmarkEvent(String id) => '/events/$id/bookmark';
  static String eventsByUser(String userId) => '/events/user/$userId';

  // Helper
  static String getUrl(String endpoint) => '$baseUrl$endpoint';
}
