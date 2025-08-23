import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Nappali (világos) téma a Protomaps gyári definíciója alapján.
/// A vector_map_tiles csomagból kérjük le, de vtr.Theme-ként adjuk vissza.
vtr.Theme classicDayTheme() {
  return vmt.ProtomapsThemes.light();
}
