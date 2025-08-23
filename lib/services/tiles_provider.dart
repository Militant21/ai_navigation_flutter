import 'dart:io';

import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// PMTiles-ből VectorTileLayer készítése a FlutterMap-hez.
/// - [pmtilesFile]: a .pmtiles fájl
/// - [theme]: a vektor renderelő témája (vtr.Theme)
Future<VectorTileLayer> pmtilesLayer(File pmtilesFile, vtr.Theme theme) async {
  // Biztonsági ellenőrzés: legyen meg a fájl
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  // NINCS fromFile ebben a verzióban — a sima konstruktor kell!
  final prov = PmTilesVectorTileProvider(
    pmtilesFile.path,
    maximumZoom: 14,
  );

  // A ProtomapsThemes a "protomaps" kulcsot várja.
  return VectorTileLayer(
    theme: theme,
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
