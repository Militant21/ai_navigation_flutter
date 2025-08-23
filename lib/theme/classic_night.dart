// lib/theme/classic_night.dart
// Éjszakai (ideiglenesen gyári) Protomaps téma.
import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

vtr.Theme classicNightTheme() {
  return vmt.ProtomapsThemes.dark();
}
