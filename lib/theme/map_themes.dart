import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Nappali téma JSON-ból
Future<vtr.Theme> createDayTheme() async {
  final raw = await rootBundle.loadString('assets/map/style_light.json');
  final data = jsonDecode(raw);
  return vtr.ThemeReader().read(data);
}

/// Éjszakai téma JSON-ból
Future<vtr.Theme> createNightTheme() async {
  final raw = await rootBundle.loadString('assets/map/style_dark.json');
  final data = jsonDecode(raw);
  return vtr.ThemeReader().read(data);
}
