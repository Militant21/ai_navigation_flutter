import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'background_services.dart';
import 'app.dart'; // ha van külön gyökér widgeted, maradhat

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Értesítések + háttérszerviz indítás
  await initLocalNotifications();
  await startBackgroundService();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      child: const AiNavApp(), // vagy a saját root widget-ed
    ),
  );
}
