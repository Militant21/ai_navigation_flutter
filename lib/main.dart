import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app.dart';
import 'background_services.dart'; // <- az új V2-es háttérkód

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Értesítések + háttérszolgáltatás inicializálása (V2)
  await initLocalNotifications();
  await initBackgroundService();

  // Ha induláskor rögtön menjen a háttér:
  // (később ez kiemelhető Settings-be egy gombra)
  // ignore: unawaited_futures
  // FlutterBackgroundService().startService();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      child: const AiNavApp(),
    ),
  );
}
