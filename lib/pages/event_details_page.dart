import 'package:flutter/material.dart';
import 'dart:io';
import '../models/event.dart';
import '../services/event_api_service.dart';
import '../models/event_store.dart';
import '../widgets/event_edit_dialog.dart';
import '../services/auth_service.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool _isBookmarked = false;
  late Event _event;
  bool _loading = true;
  bool _isOrganizer = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _isBookmarked = _event.isBookmarked;
    _loadLatest();
    _loadRole();
  }

  Future<void> _loadLatest() async {
    final latest = await EventApiService.getEventById(widget.event.id);
    if (!mounted) return;
    setState(() {
      _event = latest ?? _event;
      _loading = false;
    });
  }

  Future<void> _loadRole() async {
    final res = await AuthService.getCurrentUser();
    if (!mounted) return;
    if (res['success'] == true && res['user'] != null) {
      setState(() {
        _isOrganizer = (res['user']['role'] ?? '') == 'organizer';
      });
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Icons.music_note;
      case 'conference':
        return Icons.business;
      case 'sports':
        return Icons.sports_basketball;
      case 'food & drink':
        return Icons.restaurant;
      case 'art & culture':
        return Icons.palette;
      case 'workshop':
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return Colors.purple;
      case 'conference':
        return Colors.blue;
      case 'sports':
        return Colors.orange;
      case 'food & drink':
        return Colors.brown;
      case 'art & culture':
        return Colors.pink;
      case 'workshop':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image Section
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: event.imageUrl.isNotEmpty
                          ? (event.imageUrl.startsWith('http')
                              ? Image.network(
                                  event.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: _getCategoryColor(event.category),
                                      child: Icon(
                                        _getCategoryIcon(event.category),
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(event.imageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: _getCategoryColor(event.category),
                                      child: Icon(
                                        _getCategoryIcon(event.category),
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ))
                          : Container(
                              color: _getCategoryColor(event.category),
                              child: Icon(
                                _getCategoryIcon(event.category),
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    // Back Button
                    Positioned(
                      top: 50,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    // Bookmark Button
                    Positioned(
                      top: 50,
                      right: 20,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isBookmarked = !_isBookmarked;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    // Category Tag
                    Positioned(
                      bottom: 16,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Event Title and Organizer
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(event.category),
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.organizer ?? 'City Events Ltd',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Key Event Details Cards
                      _buildDetailCard(
                        icon: Icons.calendar_today,
                        label: 'Date & Time',
                        value: '${_getDayName(event.dateTime)}, ${event.formattedDate}',
                        subValue: event.formattedTime,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: event.location,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailCard(
                        icon: Icons.people,
                        label: 'Attendees',
                        value: '${_formatNumber(event.attendees)} people attending',
                      ),
                      const SizedBox(height: 32),
                      // About Event Section
                      const Text(
                        'About Event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description ??
                            'Join us for an unforgettable experience featuring curated programming, live acts, and community storytelling.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Organized by Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(event.category),
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Organized by',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.organizer ?? 'City Events Ltd',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                // Navigate to organizer profile
                              },
                              child: const Text(
                                'View Organizer Profile',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Action Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Organizer actions: Edit / Delete
                    if (_isOrganizer)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _editEvent(),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _deleteEvent(),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (!_isOrganizer) ...[
                      const SizedBox(height: 12),
                      // Get Tickets Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _showGetTicketsDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Get Tickets • ${event.price}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Share and Add to Calendar Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _shareEvent();
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _addToCalendar();
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Add to Calendar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (subValue != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subValue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGetTicketsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Tickets'),
        content: Text('Ticket purchasing for "${widget.event.title}" will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${widget.event.title}"...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adding "${widget.event.title}" to calendar...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editEvent() {
    showDialog(
      context: context,
      builder: (context) => EventEditDialog(
        event: _event,
        onSave: (updated) async {
          final resp = await EventApiService.updateEvent(
            id: updated.id,
            title: updated.title,
            category: updated.category,
            dateTime: updated.dateTime,
            location: updated.location,
            attendees: updated.attendees,
            price: updated.price,
            imageUrl: updated.imageUrl,
            iconEmoji: updated.iconEmoji,
            organizer: updated.organizer ?? '',
            description: updated.description ?? '',
          );
          if (!mounted) return;
          if (resp['success'] == true) {
            await EventStore.instance.refreshEvents();
            // If API returned updated event, use it; else use the updated model
            setState(() => _event = resp['event'] as Event? ?? updated);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(resp['message'] ?? 'Event updated'), backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(resp['message'] ?? 'Failed to update event'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${_event.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final resp = await EventApiService.deleteEvent(_event.id);
              if (!mounted) return;
              if (resp['success'] == true) {
                await EventStore.instance.refreshEvents();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(resp['message'] ?? 'Event deleted'), backgroundColor: Colors.red),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(resp['message'] ?? 'Failed to delete event'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
