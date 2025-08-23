import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Világos (day) téma – Protomaps alap + pár szín felülírás
vmt.Theme classicDayTheme() {
  final base = vmt.ProtomapsThemes.light();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color.rgb(255, 255, 255)),
    layers: base.layers.map((l) {
      // utak
      if (l is vtr.LineLayer && l.sourceLayer == 'roads') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(vtr.Color.rgb(136, 136, 136)), // #888888
          ),
        );
      }
      // víz
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(vtr.Color.rgb(184, 223, 251)), // #B8DFFB
          ),
        );
      }
      return l;
    }).toList(),
  );
}
