import 'dart:io';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Semleges alap téma (5.x renderer)
vtr.Theme defaultMapTheme() => vtr.createDefaultTheme();

/// PMTiles fájlból VectorTileLayer készítése.
Future<VectorTileLayer> pmtilesLayer(
  File pmtilesFile, {
  vtr.Theme? theme,
}) async {
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  // Helyes provider példányosítás (konstruktor)
  final prov = await PmTilesVectorTileProvider.fromSource(pmtilesFile.path);

  // A Protomaps témák a 'protomaps' forrásnévre számítanak.
  return VectorTileLayer(
    theme: theme ?? defaultMapTheme(),
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
