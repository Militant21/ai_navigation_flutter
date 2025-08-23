// lib/services/tiles_provider.dart
import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

Future<VectorTileLayer> pmtilesLayer(File pmtilesFile, vtr.Theme theme) async {
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  // Helyes API az 1.1.0-hoz: async gyári metódus
  final prov = await PmTilesVectorTileProvider.fromFile(
    pmtilesFile.path,
    maximumZoom: 14,
  );

  return VectorTileLayer(
    theme: theme,
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
