// lib/theme/map_themes.dart
//
// EGYEDI, ASZINKRON téma-betöltés a vector_tile_renderer-hez.
// A ProtomapsThemes (light/dark) nyers definícióját vesszük,
// és ThemeReader-rel vtr.Theme objektummá alakítjuk.
// IDE tudsz egyediséget bevinni: a 'themeData' Map módosítható,
// pl. színek, vastagságok, láthatóság, stb.

import 'package:vector_map_tiles/vector_map_tiles.dart';            // ProtomapsThemes.* definíció
import 'package:vector_tile_renderer/vector_tile_renderer.dart';    // Theme + ThemeReader

/// Nappali, egyedi téma (async)
Future<Theme> createDayTheme() async {
  final themeData = ProtomapsThemes.light();

  // ----- Egyedi módosítások helye (példa) -----
  // Példa: (ha ismered a struktúrát) themeData['layers']... = ...
  // --------------------------------------------

  return await ThemeReader(themeData: themeData).read();
}

/// Éjszakai, egyedi téma (async)
Future<Theme> createNightTheme() async {
  final themeData = ProtomapsThemes.dark();

  // ----- Egyedi módosítások helye (példa) -----
  // Példa: themeData['layers']... = ...
  // --------------------------------------------

  return await ThemeReader(themeData: themeData).read();
}
