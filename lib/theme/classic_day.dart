import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Egyedi nappali téma a Protomaps light alapra építve.
vtr.Theme classicDayTheme() {
  final base = vmt.ProtomapsThemes.light();

  return base.copyWith(
    background: const vtr.BackgroundLayer(color: vtr.Color(0xFFFFFFFF)),
    layers: base.layers.map((l) {
      // Autópályák – narancssárga
      if (l is vtr.LineLayer &&
          l.sourceLayer == 'roads' &&
          ((l.filter?.toString().contains('motorway')) ?? false)) {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: const vtr.ColorStyle(vtr.Color(0xFFFF9A2A)),
          ),
        );
      }

      // Víz – világoskék
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: const vtr.ColorStyle(vtr.Color(0xFF80A2FF)),
          ),
        );
      }

      return l;
    }).toList(),
  );
}
