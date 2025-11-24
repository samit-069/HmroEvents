import 'package:flutter/material.dart';
import 'pages/loading_page.dart';
import 'services/notification_service.dart';
import 'services/push_notification_service.dart';
import 'localization/app_localizations.dart';

class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();
  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);
  void toggle() {
    mode.value = mode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  void setLocale(Locale newLocale) {
    if (AppLocalizations.supportedLocales.contains(newLocale)) {
      locale.value = newLocale;
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await PushNotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.instance.locale,
      builder: (context, appLocale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.instance.mode,
          builder: (context, mode, __) {
            return MaterialApp(
              title: 'Evntus',
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
                useMaterial3: true,
                brightness: Brightness.dark,
              ),
              locale: appLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: appLocalizationDelegates,
              home: const LoadingPage(),
            );
          },
        );
      },
    );
  }
}
