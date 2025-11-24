import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';
import 'api_config.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Requires proper Firebase configuration (google-services.json, firebase_options.dart, etc.)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final messaging = FirebaseMessaging.instance;

    if (Platform.isIOS || Platform.isMacOS) {
      await messaging.requestPermission();
    }

    final token = await messaging.getToken();
    if (token != null && (AuthService.token != null && AuthService.token!.isNotEmpty)) {
      await _sendTokenToBackend(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _sendTokenToBackend(newToken);
    });

    _initialized = true;
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl('/users/device-token'));
      await http.post(
        uri,
        headers: await AuthService.getHeaders(),
        body: jsonEncode({'deviceToken': token}),
      );
    } catch (_) {
      // ignore errors silently
    }
  }
}
