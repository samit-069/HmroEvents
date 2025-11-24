import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will receive notifications about important updates such as event reminders and ticket information.',
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined, color: Colors.blue),
              title: const Text('Test Notification'),
              subtitle: const Text('Tap to send a test notification'),
              onTap: () {
                NotificationService.instance.showSimpleNotification(
                  title: 'Evntus',
                  body: 'This is a test notification.',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
