import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'event_upload_dashboard.dart';

class OrganizerMainNavigation extends StatefulWidget {
  const OrganizerMainNavigation({super.key});

  @override
  State<OrganizerMainNavigation> createState() => _OrganizerMainNavigationState();
}

class _OrganizerMainNavigationState extends State<OrganizerMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ProfilePage(),
    EventUploadDashboard(),
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
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload_outlined),
            label: 'Create Event',
          ),
        ],
      ),
    );
  }
}
