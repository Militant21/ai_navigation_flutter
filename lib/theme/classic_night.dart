import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Sötét (night) téma – Protomaps alap + pár szín felülírás
vmt.Theme classicNightTheme() {
  final base = vmt.ProtomapsThemes.dark();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color.rgb(20, 20, 20)), // #141414
    layers: base.layers.map((l) {
      // utak
      if (l is vtr.LineLayer && l.sourceLayer == 'roads') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(vtr.Color.rgb(255, 154, 42)), // #FF9A2A
          ),
        );
      }
      // víz
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(vtr.Color.rgb(10, 42, 67)), // #0A2A43
          ),
        );
      }
      return l;
    }).toList(),
  );
}
