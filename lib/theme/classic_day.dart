import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

Theme classicDayTheme() {
  final base = ProtomapsThemes.light();
  return base.copyWith(
    layers: base.layers.map((l) {
      // kis szín-finomhangolás – autópálya narancsosabb, víz kékebb
      if (l is LineLayer && l.sourceLayer == 'roads' && (l.filter?.toString().contains('motorway') ?? false)) {
        return l.copyWith(paint: l.paint.copyWith(color: const ColorStyle(Color(0xFFE8922F))));
      }
      if (l is FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(paint: l.paint.copyWith(color: const ColorStyle(Color(0xFFA4C6FF))));
      }
      return l;
    }).toList(),
  );
}