import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'profile_page.dart';
import 'event_upload_dashboard.dart';
import 'organizer_ticket_scanner_page.dart';

class OrganizerMainNavigation extends StatefulWidget {
  const OrganizerMainNavigation({super.key});

  @override
  State<OrganizerMainNavigation> createState() => _OrganizerMainNavigationState();
}

class _OrganizerMainNavigationState extends State<OrganizerMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    EventUploadDashboard(),
    OrganizerTicketScannerPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload_outlined),
            label: 'Create Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
