import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app.dart';
import 'services/fg_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Foreground service init (értesítések + engedélyek)
  await initForegroundTask();

  // Indítsuk el már app startkor (később tehetjük kapcsolóra is a Settingsben)
  await startForegroundService();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      child: const AiNavApp(),
    ),
  );
}
