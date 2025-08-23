import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

vmt.Theme classicDayTheme() {
  final base = vmt.ProtomapsThemes.light();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color(0xFFFFFFFF)),
    layers: base.layers.map((l) {
      if (l is vtr.LineLayer && l.sourceLayer == 'roads') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: const vtr.ColorStyle(vtr.Color(0xFF888888)),
          ),
        );
      }
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: const vtr.ColorStyle(vtr.Color(0xFF89CFF0)),
          ),
        );
      }
      return l;
    }).toList(),
  );
}
