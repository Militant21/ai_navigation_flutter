import 'dart:io';

import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// .pmtiles fájlból vektor csemperéteg létrehozása a FlutterMap-hez.
/// - [pmtilesFile]: a régió tiles.pmtiles fájlja
/// - [theme]: vektor rendererlő téma (day/night)
Future<VectorTileLayer> pmtilesLayer(File pmtilesFile, vtr.Theme theme) async {
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  // HELYES API ehhez a verzióhoz: async gyári metódus (nem konstruktor!)
  final prov = await PmTilesVectorTileProvider.fromFile(
    pmtilesFile.path,
    maximumZoom: 14,
  );

  return VectorTileLayer(
    theme: theme,
    // A 'protomaps' kulcsnév maradjon; a ProtomapsThemes ezt várja forrásként
    tileProviders: TileProviders({'protomaps': prov}),
  );
}

