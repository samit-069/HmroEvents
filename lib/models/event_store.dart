import 'package:flutter/foundation.dart';

import 'event.dart';
import '../services/event_api_service.dart';

class EventStore {
  EventStore._internal() {
    _events = [];
    eventsNotifier = ValueNotifier<List<Event>>(List.unmodifiable(_events));
  }

  static final EventStore instance = EventStore._internal();

  late final ValueNotifier<List<Event>> eventsNotifier;
  late List<Event> _events;

  List<Event> get events => List.unmodifiable(_events);

  void addEvent(Event event) {
    _events = [event, ..._events];
    _notifyListeners();
  }

  void updateEvent(Event updated) {
    final index = _events.indexWhere((event) => event.id == updated.id);
    if (index == -1) return;
    _events[index] = updated;
    _notifyListeners();
  }

  Future<void> toggleBookmark(String eventId) async {
    await EventApiService.toggleBookmark(eventId);
    await refreshEvents();
  }

  void deleteEvent(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
    _notifyListeners();
  }

  List<Event> byCategory(String category) {
    if (category == 'All Events') {
      return List.unmodifiable(_events);
    }
    return _events.where((event) => event.category == category).toList();
  }

  List<Event> userCreatedEvents() {
    return _events.where((event) => event.isUserCreated).toList();
  }

  Future<void> refreshEvents() async {
    final list = await EventApiService.getEvents();
    _events = list;
    _notifyListeners();
  }

  Future<List<Event>> bookmarkedEvents() async {
    return await EventApiService.getEvents(bookmarked: true);
  }

  void _notifyListeners() {
    eventsNotifier.value = List.unmodifiable(_events);
  }

  List<Event> _seedEvents() {
    return [
      Event(
        id: '1',
        title: 'PCPS Dashain Fest 2025',
        category: 'Music',
        dateTime: DateTime(2025, 11, 15, 18, 0),
        location: 'Kupondole, Lalitpur',
        attendees: 2500,
        price: 'From Rs. 100',
        imageUrl: '',
        iconEmoji: '🎵',
        organizer: 'HamroEvents',
        description:
            'Celebrate Dashain with live music, cultural performances, and curated food stalls at PCPS.',
      ),
      Event(
        id: '2',
        title: 'Tech Innovation Conference',
        category: 'Conference',
        dateTime: DateTime(2025, 11, 8, 9, 0),
        location: 'Hotel Soaltee, Kathmandu',
        attendees: 850,
        price: 'From Rs. 80',
        imageUrl: '',
        organizer: 'Kathmandu Tech Council',
        description:
            'A full-day conference featuring 20+ speakers on AI, cloud, fintech, and digital transformation.',
      ),
      Event(
        id: '3',
        title: 'College Basketball Championship',
        category: 'Sports',
        dateTime: DateTime(2025, 11, 5, 19, 30),
        location: 'PCPS College, Kupondole',
        attendees: 5000,
        price: 'From Rs. 250',
        imageUrl: '',
        iconEmoji: '🏀',
        organizer: 'Nepal Student Sports Association',
        description:
            'Top college teams compete for the national title under the lights with live commentary.',
      ),
      Event(
        id: '4',
        title: 'International Food Festival',
        category: 'Food & Drink',
        dateTime: DateTime(2025, 11, 14, 11, 0),
        location: 'Bhrikutimandap, KTM',
        attendees: 3200,
        price: 'Free Entry',
        imageUrl: '',
        iconEmoji: '🍜',
        organizer: 'Global Chefs Collective',
        description:
            '40+ international chefs bring their signature dishes, live demos, and tasting sessions.',
      ),
      Event(
        id: '5',
        title: 'Modern Art Exhibition',
        category: 'Art & Culture',
        dateTime: DateTime(2025, 11, 1, 10, 0),
        location: 'Naxal, KTM',
        attendees: 450,
        price: 'From Rs. 75',
        imageUrl: '',
        iconEmoji: '🎨',
        organizer: 'Artists Hub Nepal',
        description:
            'A curated collection of modern Nepali art with live painting corners and collector meetups.',
      ),
      Event(
        id: '6',
        title: 'Digital Marketing Workshop',
        category: 'Workshop',
        dateTime: DateTime(2025, 11, 20, 14, 0),
        location: 'Learning Hub Room 301',
        attendees: 120,
        price: 'From Rs. 89',
        imageUrl: '',
        organizer: 'SkillBridge',
        description:
            'Hands-on workshop covering growth marketing, paid ads, and analytics dashboards.',
      ),
      Event(
        id: '7',
        title: 'Jazz Night Under the Stars',
        category: 'Music',
        dateTime: DateTime(2025, 11, 18, 20, 0),
        location: 'Maitidevi',
        attendees: 600,
        price: 'From Rs. 300',
        imageUrl: '',
        iconEmoji: '✈️',
        organizer: 'City Nights Collective',
        description:
            'An intimate rooftop jazz session with curated cocktails and acoustic storytelling.',
      ),
      Event(
        id: '8',
        title: 'Startup Pitch Competition',
        category: 'Conference',
        dateTime: DateTime(2025, 11, 10, 13, 0),
        location: 'Global College',
        attendees: 300,
        price: 'From Rs. 50',
        imageUrl: '',
        iconEmoji: '🚀',
        organizer: 'Venture Hub Nepal',
        description:
            'Top 12 startups pitch to investors with live feedback and mentorship lounge.',
      ),
    ];
  }
}


