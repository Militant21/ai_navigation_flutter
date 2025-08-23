import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Gyűjtő: ugyanazokat a day/night témákat adja vissza,
/// ha ezt importálják a szolgáltatásaid.
vmt.Theme classicDayTheme() {
  final base = vmt.ProtomapsThemes.light();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color.rgb(255, 255, 255)),
    layers: base.layers.map((l) {
      if (l is vtr.LineLayer && l.sourceLayer == 'roads') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(vtr.Color.rgb(153, 153, 153)), // #999999
          ),
        );
      }
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(vtr.Color.rgb(191, 223, 251)), // #BFDFFB
          ),
        );
      }
      return l;
    }).toList(),
  );
}

vmt.Theme classicNightTheme() {
  final base = vmt.ProtomapsThemes.dark();
  return base.copyWith(
    background: vtr.BackgroundLayer(color: vtr.Color.rgb(20, 20, 20)),
    layers: base.layers.map((l) {
      if (l is vtr.LineLayer && l.sourceLayer == 'roads') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(vtr.Color.rgb(255, 154, 42)), // #FF9A2A
          ),
        );
      }
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
