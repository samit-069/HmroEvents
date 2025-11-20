import 'package:flutter/material.dart';
import '../models/event.dart';

class EventEditDialog extends StatefulWidget {
  final Event event;
  final Function(Event) onSave;

  const EventEditDialog({
    super.key,
    required this.event,
    required this.onSave,
  });

  @override
  State<EventEditDialog> createState() => _EventEditDialogState();
}

class _EventEditDialogState extends State<EventEditDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _attendeesController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _organizerController;
  late final TextEditingController _descriptionController;

  late String _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
    _titleController = TextEditingController(text: widget.event.title);
    _locationController = TextEditingController(text: widget.event.location);
    _priceController = TextEditingController(text: widget.event.price);
    _attendeesController = TextEditingController(text: widget.event.attendees.toString());
    _imageUrlController = TextEditingController(text: widget.event.imageUrl);
    _organizerController = TextEditingController(text: widget.event.organizer ?? '');
    _descriptionController = TextEditingController(text: widget.event.description ?? '');
    _selectedCategory = widget.event.category;
    _selectedDate = widget.event.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.dateTime);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _attendeesController.dispose();
    _imageUrlController.dispose();
    _organizerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            AppBar(
              title: const Text('Edit Event'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Event Title',
                      icon: Icons.title,
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
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'Price',
                            icon: Icons.sell,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _attendeesController,
                            label: 'Attendees',
                            icon: Icons.people,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _imageUrlController,
                      label: 'Image URL',
                      icon: Icons.image,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _organizerController,
                      label: 'Organizer',
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
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
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
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
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
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
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _selectedDate != null
              ? 'Date: ${_formatDate(_selectedDate!)}'
              : 'Select Date',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(_selectedDate != null ? _formatDate(_selectedDate!) : ''),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _pickTime,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _selectedTime != null
              ? 'Time: ${_selectedTime!.format(context)}'
              : 'Select Time',
          prefixIcon: const Icon(Icons.schedule),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(_selectedTime != null ? _selectedTime!.format(context) : ''),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
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
      initialTime: _selectedTime ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _saveEvent() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
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

    final updatedEvent = widget.event.copyWith(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      dateTime: dateTime,
      location: _locationController.text.trim(),
      attendees: attendees,
      price: _priceController.text.trim().isEmpty ? 'Free Entry' : _priceController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      organizer: _organizerController.text.trim().isEmpty
          ? widget.event.organizer
          : _organizerController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? widget.event.description
          : _descriptionController.text.trim(),
    );

    widget.onSave(updatedEvent);
    Navigator.pop(context);
  }
}

