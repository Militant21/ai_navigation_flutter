import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Világos téma
vtr.Theme lightMapTheme() {
  final base = vmt.Themes.lightTheme();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color(0xFFF8F8F8)),
  );
}

/// Sötét téma
vtr.Theme darkMapTheme() {
  final base = vmt.Themes.darkTheme();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color(0xFF141414)),
  );
}
