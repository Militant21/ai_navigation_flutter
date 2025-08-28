import 'dart:io';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Gyors téma helper – a 5.x rendererben van `createDayTheme()`.
vtr.Theme defaultMapTheme() => vtr.createDayTheme();

/// PMTiles fájlból VectorTileLayer készítése.
Future<VectorTileLayer> pmtilesLayer(
  File pmtilesFile, {
  vtr.Theme? theme,
}) async {
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  final prov = await PmTilesVectorTileProvider.fromSource(pmtilesFile.path);

  return VectorTileLayer(
    theme: theme ?? defaultMapTheme(),
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
