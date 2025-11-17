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
  final bool isBookmarked;

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
    this.isBookmarked = false,
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
}

