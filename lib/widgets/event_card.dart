import 'package:flutter/material.dart';
import 'dart:io';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onBookmark,
  });

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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 200,
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
                                      size: 60,
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
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ))
                        : Container(
                            color: _getCategoryColor(event.category),
                            child: Icon(
                              _getCategoryIcon(event.category),
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                // Category Tag
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Bookmark Icon
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onBookmark,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        event.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with Icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (event.iconEmoji != null)
                        Text(
                          event.iconEmoji!,
                          style: const TextStyle(fontSize: 20),
                        )
                      else
                        Icon(
                          _getCategoryIcon(event.category),
                          size: 20,
                          color: _getCategoryColor(event.category),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Date & Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.formattedDateTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Attendees and Price
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatNumber(event.attendees)} attending',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        event.price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

