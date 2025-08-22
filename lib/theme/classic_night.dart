import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

Theme classicNightTheme() {
  final base = ProtomapsThemes.dark();
  return base.copyWith(
    background: const BackgroundLayer(color: Color(0xFF141414)),
    layers: base.layers.map((l) {
      if (l is LineLayer && l.sourceLayer == 'roads' && (l.filter?.toString().contains('motorway') ?? false)) {
        return l.copyWith(paint: l.paint.copyWith(color: const ColorStyle(Color(0xFFFF9A2A))));
      }
      if (l is FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(paint: l.paint.copyWith(color: const ColorStyle(Color(0xFF0A2A43))));
      }
      return l;
    }).toList(),
  );
}