import 'dart:io';
import 'package:ai_navigation_flutter/theme/map_themes.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

Future<VectorTileLayer> pmtilesLayer(File pmtilesFile, vtr.Theme theme) async {
  final prov = await PmTilesVectorTileProvider.fromFile(
    pmtilesFile.path,
    maximumZoom: 14,
  );

  return VectorTileLayer(
    theme: theme,
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
