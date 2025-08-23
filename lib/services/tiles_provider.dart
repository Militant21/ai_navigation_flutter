import 'dart:io';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

Future<VectorTileLayer> pmtilesLayer(File pmtilesFile, vtr.Theme theme) async {
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  // <-- I T T  A  L É N Y E G
  final prov = await PmTilesVectorTileProvider.fromFile(
    pmtilesFile.path,
    maximumZoom: 14,
  );

  return VectorTileLayer(
    theme: theme,
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
