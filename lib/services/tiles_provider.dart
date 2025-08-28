// PMTiles -> VectorTileLayer provider (csak PMTiles-hez)

// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// PMTiles fájlból vektor csemperéteg készítése.
/// [pmtilesFile] - a .pmtiles fájl (pl. assets-ből kimásolva egy írható mappába)
/// [theme]       - kötelező vtr.Theme (createDayTheme/createNightTheme eredménye)
Future<vmt.VectorTileLayer> pmtilesLayer(
  File pmtilesFile, {
  required vtr.Theme theme,
}) async {
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  // Helyes provider példányosítás PMTiles-hez
  final prov =
      await PmTilesVectorTileProvider.fromSource(pmtilesFile.path);

  // A Protomaps témák a 'protomaps' forrásnévre számítanak.
  return vmt.VectorTileLayer(
    theme: theme,
    tileProviders: vmt.TileProviders({'protomaps': prov}),
  );
}
