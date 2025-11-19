import 'package:flutter/material.dart';

import 'event_upload_dashboard.dart';
import '../models/event_store.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import '../widgets/event_edit_dialog.dart';
import '../services/auth_service.dart';
import '../services/event_api_service.dart';
import 'event_details_page.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  static final EventStore _eventStore = EventStore.instance;
  String _organizerName = 'Organizer';
  String _organizerEmail = '';

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final res = await AuthService.getCurrentUser();
    if (!mounted) return;
    if (res['success'] == true && res['user'] != null) {
      final u = res['user'];
      final first = (u['firstName'] ?? '').toString();
      final last = (u['lastName'] ?? '').toString();
      final nameFromParts = (first + ' ' + last).trim();
      setState(() {
        _organizerName = (u['name'] ?? '').toString().isNotEmpty ? u['name'] : (nameFromParts.isNotEmpty ? nameFromParts : 'Organizer');
        _organizerEmail = (u['email'] ?? '').toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 16),
                const Text(
                  'Event Uploads',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create, manage, and track your upcoming events.',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                const EventUploadDashboard(embedded: true),
                const SizedBox(height: 24),
                _buildEventsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $_organizerName 👋',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ready to publish your next event?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_organizerEmail.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _organizerEmail,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.yellow.shade200,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Keep your banner image ratio 16:9 for best results.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Events',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review the events you\'ve published.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<Event>>(
          valueListenable: _eventStore.eventsNotifier,
          builder: (context, events, _) {
            final userEvents =
                events.where((event) => event.isUserCreated).toList();
            if (userEvents.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_available,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No events yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Publish an event to see it listed here.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userEvents.length,
              itemBuilder: (context, index) {
                final event = userEvents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      EventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailsPage(event: event),
                            ),
                          );
                        },
                        onBookmark: () => _eventStore.toggleBookmark(event.id),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showEditEventDialog(context, event),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                              style: TextButton.styleFrom(foregroundColor: Colors.blue),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _showDeleteEventDialog(context, event),
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Delete'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showEditEventDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => EventEditDialog(
        event: event,
        onSave: (updatedEvent) {
          EventApiService.updateEvent(
            id: updatedEvent.id,
            title: updatedEvent.title,
            category: updatedEvent.category,
            dateTime: updatedEvent.dateTime,
            location: updatedEvent.location,
            attendees: updatedEvent.attendees,
            price: updatedEvent.price,
            imageUrl: updatedEvent.imageUrl,
            iconEmoji: updatedEvent.iconEmoji,
            organizer: updatedEvent.organizer ?? '',
            description: updatedEvent.description ?? '',
          ).then((resp) async {
            if (resp['success'] == true) {
              await _eventStore.refreshEvents();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(resp['message'] ?? 'Event updated'), backgroundColor: Colors.green),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(resp['message'] ?? 'Failed to update event'), backgroundColor: Colors.red),
                );
              }
            }
          });
        },
      ),
    );
  }

  void _showDeleteEventDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              EventApiService.deleteEvent(event.id).then((resp) async {
                Navigator.pop(context);
                if (resp['success'] == true) {
                  await _eventStore.refreshEvents();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(resp['message'] ?? 'Event deleted'), backgroundColor: Colors.red),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(resp['message'] ?? 'Failed to delete event'), backgroundColor: Colors.red),
                    );
                  }
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


