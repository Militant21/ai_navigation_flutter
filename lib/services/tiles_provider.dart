import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';

Future<VectorTileLayer> pmtilesLayer(File pmtilesFile, Theme theme) async {
  final prov = await PmTilesVectorTileProvider.fromFile(pmtilesFile.path, maximumZoom: 14);
  return VectorTileLayer(theme: theme, tileProviders: TileProviders({'protomaps': prov}));
}