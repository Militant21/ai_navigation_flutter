import 'package:flutter/material.dart';
import 'screens/catalog.dart';
import 'screens/settings.dart';
import 'screens/no_map_fallback.dart';
import 'screens/home_screen.dart'; // a meglévő térképes képernyő
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AiNavApp extends StatefulWidget {
  const AiNavApp({super.key});

  @override
  State<AiNavApp> createState() => _AiNavAppState();
}

class _AiNavAppState extends State<AiNavApp> {
  bool? _hasMap;

  @override
  void initState() {
    super.initState();
    _checkForMaps();
  }

  Future<void> _checkForMaps() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().where((f) =>
      f.path.endsWith(".pmtiles") || f.path.endsWith(".mbtiles"));
    setState(() {
      _hasMap = files.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Navigation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _hasMap == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _hasMap!
              ? const HomeScreen()
              : const NoMapFallback(),
      routes: {
        '/home': (ctx) => const HomeScreen(),
        '/settings': (ctx) => const SettingsScreen(),
        '/catalog': (ctx) => const CatalogScreen(),
      },
    );
  }
}
