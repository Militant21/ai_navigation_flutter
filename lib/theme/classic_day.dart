import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

vtr.Theme classicDayTheme() {
  final base = vmt.ProtomapsThemes.light();

  return base.copyWith(
    // háttér
    background: const vtr.BackgroundLayer(color: vtr.Color(0xFFFFFFFF)),
    // rétegek módosítása
    layers: base.layers.map((l) {
      // autópályák színezése
      if (l is vtr.LineLayer &&
          l.sourceLayer == 'roads' &&
          (l.filter?.toString().contains('motorway') ?? false)) {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: const vtr.ColorStyle(vtr.Color(0xFFFF9A2A)),
          ),
        );
      }

      // víz réteg
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: const vtr.ColorStyle(vtr.Color(0xFF00A2A3)),
          ),
        );
      }

      return l;
    }).toList(),
  );
}
