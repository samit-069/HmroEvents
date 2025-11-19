import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../models/event.dart';
import '../models/event_store.dart';
import '../widgets/event_card.dart';
import '../services/event_api_service.dart';
import '../services/upload_service.dart';
import 'event_details_page.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

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
  void initState() {
    super.initState();
    // Ensure stats and lists reflect live data from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventStore.refreshEvents();
    });
  }

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

  Future<void> _pickBannerImage() async {
    final XFile? picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageUrlController.text = picked.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = ValueListenableBuilder<List<Event>>(
      valueListenable: _eventStore.eventsNotifier,
      builder: (context, events, _) {
        final userEvents = events.where((event) => event.isUserCreated).toList();
        return RefreshIndicator(
          onRefresh: _eventStore.refreshEvents,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
            // Banner image picker
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Banner Image',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickBannerImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Choose from Gallery'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _imageUrlController.text.isEmpty
                              ? 'No file selected'
                              : _imageUrlController.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_imageUrlController.text.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: _imageUrlController.text.startsWith('http')
                            ? Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.broken_image)),
                                ),
                              )
                            : Image.file(
                                File(_imageUrlController.text),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.broken_image)),
                                ),
                              ),
                      ),
                    ),
                ],
              ),
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

  Future<void> _onSubmit() async {
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

    // Upload image if it's a local file path
    String imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      final up = await UploadService.uploadImage(File(imageUrl));
      if (up['success'] == true && up['url'] != null) {
        imageUrl = up['url'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(up['message'] ?? 'Failed to upload image'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    final resp = await EventApiService.createEvent(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      dateTime: dateTime,
      location: _locationController.text.trim(),
      attendees: attendees,
      price: _priceController.text.trim().isEmpty ? 'Free Entry' : _priceController.text.trim(),
      imageUrl: imageUrl,
      iconEmoji: '',
      organizer: organizerName,
      description: _descriptionController.text.trim().isEmpty
          ? 'Details coming soon. Stay tuned!'
          : _descriptionController.text.trim(),
    );

    if (resp['success'] == true) {
      await _eventStore.refreshEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Event published successfully'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Failed to publish event'), backgroundColor: Colors.red),
      );
      return;
    }

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


