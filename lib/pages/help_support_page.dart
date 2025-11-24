import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t('help_support')),
      ),
      body: Padding
(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('help_support'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              t('help_support_subtitle'),
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Email: support@evntus.app'),
            const SizedBox(height: 4),
            const Text('Phone: +977-9800000000'),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'FAQ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- How do I book a ticket? Open an event and tap "Get Tickets".'),
            const SizedBox(height: 4),
            const Text('- How do I create events? Switch to organizer and use the Create Event tab.'),
            const SizedBox(height: 4),
            const Text('- For any other questions, please email or call us.'),
          ],
        ),
      ),
    );
  }
}
