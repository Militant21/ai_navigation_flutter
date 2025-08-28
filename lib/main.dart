import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app.dart';
import 'background_services.dart'; // <- ezekből hívunk

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Értesítések + háttérszolgáltatás inicializálása
  await initLocalNotifications();
  await startBackgroundService();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      child: const AiNavApp(),
    ),
  );
}
