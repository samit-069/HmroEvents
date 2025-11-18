import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/event_store.dart';
import '../widgets/event_card.dart';

class EventUploadDashboard extends StatefulWidget {
  final bool embedded;
  const EventUploadDashboard({super.key, this.embedded = false});

  @override
  State<EventUploadDashboard> createState() => _EventUploadDashboardState();
}

class _EventUploadDashboardState extends State<EventUploadDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController(text: 'Free Entry');
  final _imageUrlController = TextEditingController();
  final _attendeesController = TextEditingController(text: '100');
  final _organizerController = TextEditingController();
  final _descriptionController = TextEditingController();

  final EventStore _eventStore = EventStore.instance;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCategory = 'Music';

  final List<String> _categories = [
    'Music',
    'Conference',
    'Sports',
    'Food & Drink',
    'Art & Culture',
    'Workshop',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _attendeesController.dispose();
    _organizerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = ValueListenableBuilder<List<Event>>(
      valueListenable: _eventStore.eventsNotifier,
      builder: (context, events, _) {
        final userEvents = events.where((event) => event.isUserCreated).toList();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(events, userEvents),
              const SizedBox(height: 24),
              _buildUploadForm(),
              const SizedBox(height: 32),
              _buildRecentUploads(userEvents),
            ],
          ),
        );
      },
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Event Upload Dashboard'),
        centerTitle: true,
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _buildStatsRow(List<Event> allEvents, List<Event> userEvents) {
    final nextEventDate = userEvents.isNotEmpty
        ? userEvents.map((e) => e.dateTime).reduce((a, b) => a.isBefore(b) ? a : b)
        : null;
    return Row(
      children: [
        _StatCard(
          title: 'Total Events',
          value: '${allEvents.length}',
          icon: Icons.event_available,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _StatCard(
          title: 'Your Uploads',
          value: '${userEvents.length}',
          icon: Icons.upload_file,
          color: Colors.deepPurple,
        ),
        const SizedBox(width: 12),
        _StatCard(
          title: 'Next Live',
          value: nextEventDate != null ? _formatDate(nextEventDate) : 'N/A',
          icon: Icons.schedule,
          color: Colors.green,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildUploadForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create an Event',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              label: 'Event Title',
              icon: Icons.title,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 12),
                Expanded(child: _buildTimePicker()),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on_outlined,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Location is required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _priceController,
                    label: 'Ticket Price',
                    icon: Icons.sell_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _attendeesController,
                    label: 'Expected Attendees',
                    icon: Icons.people_outline,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _imageUrlController,
              label: 'Banner Image URL',
              icon: Icons.image_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _organizerController,
              label: 'Organizer Name',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Event Description',
              icon: Icons.description_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _onSubmit,
                icon: const Icon(Icons.cloud_upload),
                label: const Text(
                  'Publish Event',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: _categories
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: _selectedDate != null
                ? 'Date: ${_formatDate(_selectedDate!)}'
                : 'Select Date',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (_) => _selectedDate == null ? 'Select a date' : null,
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: _selectedTime != null
                ? 'Time: ${_selectedTime!.format(context)}'
                : 'Select Time',
            prefixIcon: const Icon(Icons.schedule_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (_) => _selectedTime == null ? 'Select a time' : null,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (_selectedDate == null || _selectedTime == null) {
      setState(() {}); // trigger validators
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final attendees = int.tryParse(_attendeesController.text.trim()) ?? 0;
    final organizerName = _organizerController.text.trim().isEmpty
        ? 'Independent Organizer'
        : _organizerController.text.trim();

    final newEvent = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory,
      dateTime: dateTime,
      location: _locationController.text.trim(),
      attendees: attendees,
      price: _priceController.text.trim().isEmpty ? 'Free Entry' : _priceController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      organizer: organizerName,
      description: _descriptionController.text.trim().isEmpty
          ? 'Details coming soon. Stay tuned!'
          : _descriptionController.text.trim(),
      isUserCreated: true,
    );

    _eventStore.addEvent(newEvent);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event published successfully'),
      ),
    );

    _formKey.currentState?.reset();
    _titleController.clear();
    _locationController.clear();
    _priceController.text = 'Free Entry';
    _imageUrlController.clear();
    _attendeesController.text = '100';
    _organizerController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedCategory = 'Music';
    });
  }

  Widget _buildRecentUploads(List<Event> userEvents) {
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
            Icon(Icons.dashboard_customize, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text(
              'No uploads yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Publish your first event to see it appear here.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Uploads',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...userEvents.take(3).map(
              (event) => EventCard(
                event: event,
                onBookmark: () => _eventStore.toggleBookmark(event.id),
              ),
            ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


