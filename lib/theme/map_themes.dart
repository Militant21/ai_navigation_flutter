// lib/map_themes.dart

import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
/// 'Felfedező' nappali stílus
///
/// Világos, tiszta és könnyen olvasható témát hoz létre,
/// amely ideális nappali fényviszonyok melletti használatra.
Future<vtr.Theme> createDayTheme() async {
  // A vector_map_tiles csomagból lekérjük a 'light' téma definícióját.
  final themeData = ProtomapsThemes.light();

  // A ThemeReader segítségével a definíciót a renderer számára
  // értelmezhető Theme objektummá alakítjuk.
  return await ThemeReader(themeData: themeData).read();
}

/// 'Neon Navigátor' éjszakai stílus
///
/// Sötét, kontrasztos és szemkímélő témát hoz létre,
/// amely kiemeli a fontos útvonalakat éjszakai navigációhoz.
Future<vtr.Theme> createNightTheme() async {
  // A vector_map_tiles csomagból lekérjük a 'dark' téma definícióját.
  final themeData = ProtomapsThemes.dark();

  // A ThemeReader segítségével a definíciót a renderer számára
  // értelmezhető Theme objektummá alakítjuk.
  return await ThemeReader(themeData: themeData).read();
}

