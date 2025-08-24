import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

Future<Theme> createDayTheme() async {
  final raw = await rootBundle.loadString('assets/map/style_light.json');
  final data = jsonDecode(raw);
  return ThemeReader().read(data);
}

Future<Theme> createNightTheme() async {
  final raw = await rootBundle.loadString('assets/map/style_dark.json');
  final data = jsonDecode(raw);
  return ThemeReader().read(data);
}
