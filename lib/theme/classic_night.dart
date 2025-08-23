import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

// A függvénynek Future<vtr.Theme>-et kell visszaadnia és async kell legyen
Future<vtr.Theme> classicNightTheme() async {
  // 1. Kérd el a téma definícióját a vmt csomagból
  final themeData = vmt.ProtomapsThemes.dark();
  
  // 2. A ThemeReader segítségével olvasd be a renderer számára
  return await vtr.ThemeReader(themeData: themeData).read();
}
