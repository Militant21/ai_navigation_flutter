import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

/// Egyedi, aszinkron betölthető map-témák.
/// A ProtomapsThemes (light/dark) definícióját vesszük a vector_map_tiles-ből,
/// majd ThemeReader-rel vtr.Theme objektummá alakítjuk.

/// Nappali, világos téma (async beolvasással).
Future<Theme> createDayTheme() async {
  final themeData = ProtomapsThemes.light(); // definíció a vmt csomagból
  return await ThemeReader(themeData: themeData).read();
}

/// Éjszakai, sötét téma (async beolvasással).
Future<Theme> createNightTheme() async {
  final themeData = ProtomapsThemes.dark(); // definíció a vmt csomagból
  return await ThemeReader(themeData: themeData).read();
}
