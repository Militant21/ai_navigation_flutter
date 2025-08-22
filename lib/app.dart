import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/settings_screen.dart';

class AiNavApp extends StatelessWidget {
  const AiNavApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Navigation',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF1D70B8)),
      routes: {
        '/': (_) => const HomeScreen(),
        '/catalog': (_) => const CatalogScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}