import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

vtr.Theme classicDayTheme() {
  final base = vmt.ProtomapsThemes.light();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color.rgb(255, 255, 255)),
    layers: base.layers.map((l) {
      if (l is vtr.LineLayer && l.sourceLayer == 'roads') {
        return l.copyWith(
          paint: l.paint.copyWith(color: vtr.ColorStyle(vtr.Color.rgb(136,136,136))),
        );
      }
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(color: vtr.ColorStyle(vtr.Color.rgb(184,223,251))),
        );
      }
      return l;
    }).toList(),
  );
}

vtr.Theme classicNightTheme() {
  final base = vmt.ProtomapsThemes.dark();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color.rgb(20, 20, 20)),
    layers: base.layers.map((l) {
      if (l is vtr.LineLayer && l.sourceLayer == 'roads') {
        return l.copyWith(
          paint: l.paint.copyWith(color: vtr.ColorStyle(vtr.Color.rgb(255,154,42))),
        );
      }
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(color: vtr.ColorStyle(vtr.Color.rgb(10,42,67))),
        );
      }
      return l;
    }).toList(),
  );
}

Future<vtr.Theme> createDayTheme() async => classicDayTheme();
Future<vtr.Theme> createNightTheme() async => classicNightTheme();
