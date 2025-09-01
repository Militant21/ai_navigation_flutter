import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // +++

import 'app.dart';
import 'background_services.dart';

Future<void> main() async {
  // +++ Splash megtartása az első frame-ig
  final wb = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: wb);

  await EasyLocalization.ensureInitialized();

  // értesítések + háttérszolgáltatás inicializálása
  await initLocalNotifications();
  await initBackgroundService();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en'),
      child: const AiNavApp(),
    ),
  );

  // +++ Első frame után vegyük le a natív splasht -> nincs fehér kép
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
