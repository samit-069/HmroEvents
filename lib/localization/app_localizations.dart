import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('ne'),
  ];

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'profile_title': 'Profile',
      'personal_info': 'Personal Information',
      'settings': 'Settings',
      'your_tickets': 'Your Tickets',
      'your_tickets_subtitle': 'View tickets you have booked',
      'notifications': 'Notifications',
      'notifications_subtitle': 'Manage your notifications',
      'privacy_security': 'Privacy & Security',
      'privacy_security_subtitle': 'Manage your privacy settings',
      'language': 'Language',
      'language_english': 'English',
      'language_nepali': 'Nepali',
      'help_support': 'Help & Support',
      'help_support_subtitle': 'Get help and contact support',
      'about': 'About',
      'about_subtitle': 'App version 1.0.0',
      'logout': 'Logout',
      'organizer_dashboard_title': 'Organizer Dashboard',
      'organizer_notify_title': 'Evntus Organizer',
      'organizer_notify_body': 'You will see event-related notifications here.',
      'organizer_event_uploads_title': 'Event Uploads',
      'organizer_event_uploads_subtitle': 'Create, manage, and track your upcoming events.',
      'organizer_welcome': 'Welcome back, {name} 👋',
      'organizer_ready_text': 'Ready to publish your next event?',
      'organizer_tip_banner': 'Tip: Keep your banner image ratio 16:9 for best results.',
      'organizer_your_events_title': 'Your Events',
      'organizer_your_events_subtitle': 'Review the events you\'ve published.',
      'organizer_no_events_title': 'No events yet',
      'organizer_no_events_subtitle': 'Publish an event to see it listed here.',
      'organizer_delete_event_title': 'Delete Event',
      'organizer_delete_event_message': 'Are you sure you want to delete "{title}"? This action cannot be undone.',
      'common_cancel': 'Cancel',
      'common_delete': 'Delete',
      'eventus_title': 'Event Us',
      'event_upload_create_title': 'Create an Event',
      'event_upload_total_events': 'Total Events',
      'event_upload_your_uploads': 'Your Uploads',
      'event_upload_next_live': 'Next Live',
      'event_upload_n_a': 'N/A',
      'event_upload_event_title': 'Event Title',
      'event_upload_title_required': 'Title is required',
      'event_upload_category': 'Category',
      'event_upload_location': 'Location',
      'event_upload_location_required': 'Location is required',
      'event_upload_ticket_price': 'Ticket Price',
      'event_upload_expected_attendees': 'Expected Attendees',
      'event_upload_required': 'Required',
      'event_upload_enter_number': 'Enter a number',
      'event_upload_banner_image': 'Banner Image',
      'event_upload_choose_gallery': 'Choose from Gallery',
      'event_upload_no_file': 'No file selected',
      'event_upload_organizer_name': 'Organizer Name',
      'event_upload_description': 'Event Description',
      'event_upload_publish': 'Publish Event',
      'event_upload_date_label': 'Select Date',
      'event_upload_date_with_value': 'Date: {value}',
      'event_upload_date_required': 'Select a date',
      'event_upload_time_label': 'Select Time',
      'event_upload_time_with_value': 'Time: {value}',
      'event_upload_time_required': 'Select a time',
      'event_upload_independent_organizer': 'Independent Organizer',
      'event_upload_failed_upload_image': 'Failed to upload image',
      'event_upload_details_coming': 'Details coming soon. Stay tuned!',
      'event_upload_published_notification_title': 'New Event Published',
      'event_upload_published_notification_body': 'Your event has been published successfully.',
      'event_upload_published_success': 'Event published successfully',
      'event_upload_published_failed': 'Failed to publish event',
      'event_upload_no_uploads_title': 'No uploads yet',
      'event_upload_no_uploads_subtitle': 'Publish your first event to see it appear here.',
      'event_upload_recent_uploads': 'Recent Uploads',
      'discover_title': 'Discover Events',
      'discover_location_hint': 'Change your location...',
      'discover_location_permission_denied': 'Location permission denied. Enable it in settings.',
      'discover_location_failed': 'Failed to get location: {error}',
      'discover_category_all': 'All Events',
      'discover_category_music': 'Music',
      'discover_category_conference': 'Conference',
      'discover_category_sports': 'Sports',
      'discover_category_food': 'Food & Drink',
      'discover_category_art': 'Art & Culture',
      'discover_category_workshop': 'Workshop',
      'discover_events_suffix': 'events',
    },
    'ne': {
      'profile_title': 'प्रोफाइल',
      'personal_info': 'व्यक्तिगत जानकारी',
      'settings': 'सेटिङ्स',
      'your_tickets': 'तपाईंका टिकटहरू',
      'your_tickets_subtitle': 'तपाईंले खरिद गरेका टिकटहरू हेर्नुहोस्',
      'notifications': 'सूचनाहरू',
      'notifications_subtitle': 'तपाईंका सूचनाहरू व्यवस्थापन गर्नुहोस्',
      'privacy_security': 'गोपनीयता र सुरक्षा',
      'privacy_security_subtitle': 'गोपनीयता सेटिङ्स व्यवस्थापन गर्नुहोस्',
      'language': 'भाषा',
      'language_english': 'अंग्रेजी',
      'language_nepali': 'नेपाली',
      'help_support': 'मद्दत र समर्थन',
      'help_support_subtitle': 'मद्दत पाउनुहोस् र समर्थनमा सम्पर्क गर्नुहोस्',
      'about': 'बारेमा',
      'about_subtitle': 'एप संस्करण 1.0.0',
      'logout': 'लगआउट',
      'organizer_dashboard_title': 'आयोजक ड्यासबोर्ड',
      'organizer_notify_title': 'इभन्टस आयोजक',
      'organizer_notify_body': 'यहाँ तपाईंले कार्यक्रमसम्बन्धी सूचनाहरू देख्नुहुनेछ。',
      'organizer_event_uploads_title': 'इभेन्ट अपलोड',
      'organizer_event_uploads_subtitle': 'आफ्ना आगामी कार्यक्रमहरू बनाउनुहोस्, व्यवस्थापन गर्नुहोस् र ट्र्याक गर्नुहोस्。',
      'organizer_welcome': 'फेरि स्वागत छ, {name} 👋',
      'organizer_ready_text': 'के तपाईं अर्को कार्यक्रम प्रकाशित गर्न तयार हुनुहुन्छ?',
      'organizer_tip_banner': 'सुझाव: उत्कृष्ट नतिजाका लागि ब्यानर इमेजको अनुपात १६:९ राख्नुहोस्。',
      'organizer_your_events_title': 'तपाईंका कार्यक्रमहरू',
      'organizer_your_events_subtitle': 'तपाईंले प्रकाशित गरेका कार्यक्रमहरूको समीक्षा गर्नुहोस्。',
      'organizer_no_events_title': 'अहिले कुनै कार्यक्रम छैन',
      'organizer_no_events_subtitle': 'सूचीमा देख्नका लागि नयाँ कार्यक्रम प्रकाशित गर्नुहोस्。',
      'organizer_delete_event_title': 'कार्यक्रम हटाउनुहोस्',
      'organizer_delete_event_message': 'के तपाईं साँच्चिकै "{title}" कार्यक्रम हटाउन चाहनुहुन्छ? यो क्रिया फर्काउन सकिँदैन。',
      'common_cancel': 'रद्द गर्नुहोस्',
      'common_delete': 'हटाउनुहोस्',
      'eventus_title': 'इभेन्ट अस',
      'event_upload_create_title': 'कार्यक्रम सिर्जना गर्नुहोस्',
      'event_upload_total_events': 'कुल कार्यक्रम',
      'event_upload_your_uploads': 'तपाईंका अपलोडहरू',
      'event_upload_next_live': 'आगामी लाइभ',
      'event_upload_n_a': 'N/A',
      'event_upload_event_title': 'कार्यक्रम शीर्षक',
      'event_upload_title_required': 'शीर्षक आवश्यक छ',
      'event_upload_category': 'कोटि',
      'event_upload_location': 'स्थान',
      'event_upload_location_required': 'स्थान आवश्यक छ',
      'event_upload_ticket_price': 'टिकट मूल्य',
      'event_upload_expected_attendees': 'अपेक्षित सहभागीहरू',
      'event_upload_required': 'आवश्यक',
      'event_upload_enter_number': 'संख्या लेख्नुहोस्',
      'event_upload_banner_image': 'ब्यानर इमेज',
      'event_upload_choose_gallery': 'ग्यालरीबाट छान्नुहोस्',
      'event_upload_no_file': 'कुनै फाइल छानिएको छैन',
      'event_upload_organizer_name': 'आयोजकको नाम',
      'event_upload_description': 'कार्यक्रम विवरण',
      'event_upload_publish': 'कार्यक्रम प्रकाशित गर्नुहोस्',
      'event_upload_date_label': 'मिति छान्नुहोस्',
      'event_upload_date_with_value': 'मिति: {value}',
      'event_upload_date_required': 'मिति छान्नुहोस्',
      'event_upload_time_label': 'समय छान्नुहोस्',
      'event_upload_time_with_value': 'समय: {value}',
      'event_upload_time_required': 'समय छान्नुहोस्',
      'event_upload_independent_organizer': 'स्वतन्त्र आयोजक',
      'event_upload_failed_upload_image': 'तस्वीर अपलोड गर्न असफल भयो',
      'event_upload_details_coming': 'विवरण चाँडै आउँदैछ। कृपया प्रतीक्षा गर्नुहोस्。',
      'event_upload_published_notification_title': 'नयाँ कार्यक्रम प्रकाशित भयो',
      'event_upload_published_notification_body': 'तपाईंको कार्यक्रम सफलतापूर्वक प्रकाशित भयो।',
      'event_upload_published_success': 'कार्यक्रम सफलतापूर्वक प्रकाशित भयो',
      'event_upload_published_failed': 'कार्यक्रम प्रकाशित गर्न असफल भयो',
      'event_upload_no_uploads_title': 'अहिलेसम्म कुनै अपलोड छैन',
      'event_upload_no_uploads_subtitle': 'पहिलो कार्यक्रम प्रकाशित गर्नुस् र यहाँ देख्नुहोस्。',
      'event_upload_recent_uploads': 'हालका अपलोडहरू',
      'discover_title': 'कार्यक्रमहरू खोज्नुहोस्',
      'discover_location_hint': 'आफ्नो स्थान परिवर्तन गर्नुहोस्...',
      'discover_location_permission_denied': 'स्थान अनुमति अस्वीकार भयो। सेटिङ्समा गएर सक्षम गर्नुहोस्।',
      'discover_location_failed': 'स्थान प्राप्त गर्न असफल भयो: {error}',
      'discover_category_all': 'सबै कार्यक्रम',
      'discover_category_music': 'संगीत',
      'discover_category_conference': 'समारोह',
      'discover_category_sports': 'राम्रो खेलकुद',
      'discover_category_food': 'खानपान',
      'discover_category_art': 'कला र संस्कृति',
      'discover_category_workshop': 'कार्यशाला',
      'discover_events_suffix': 'कार्यक्रम',
    },
  };

  String t(String key) {
    final lang = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return lang[key] ?? _localizedValues['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ne'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

const appLocalizationDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
