class Event {
  final String id;
  final String title;
  final String category;
  final DateTime dateTime;
  final String location;
  final int attendees;
  final String price;
  final String imageUrl;
  final String? iconEmoji;
  final String? organizer;
  final String? description;
  final bool isBookmarked;
  final bool isUserCreated;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.location,
    required this.attendees,
    required this.price,
    required this.imageUrl,
    this.iconEmoji,
    this.organizer,
    this.description,
    this.isBookmarked = false,
    this.isUserCreated = false,
  });

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDateTime => '$formattedDate • $formattedTime';

  Event copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? dateTime,
    String? location,
    int? attendees,
    String? price,
    String? imageUrl,
    String? iconEmoji,
    String? organizer,
    String? description,
    bool? isBookmarked,
    bool? isUserCreated,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      organizer: organizer ?? this.organizer,
      description: description ?? this.description,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isUserCreated: isUserCreated ?? this.isUserCreated,
    );
  }
}
