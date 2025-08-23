import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

vtr.Theme classicNightTheme() {
  final base = vmt.ProtomapsThemes.dark();

  return base.copyWith(
    background: const vtr.BackgroundLayer(color: vtr.Color(0xFF141414)),
    layers: base.layers.map((l) {
      if (l is vtr.LineLayer &&
          l.sourceLayer == 'roads' &&
          (l.filter?.toString().contains('motorway') ?? false)) {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: const vtr.ColorStyle(vtr.Color(0xFFFF9A2A)),
          ),
        );
      }

      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: const vtr.ColorStyle(vtr.Color(0xFF0A2A43)),
          ),
        );
      }

      return l;
    }).toList(),
  );
}
