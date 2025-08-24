// lib/services/tiles_provider.dart
// PMTiles -> VectorTileLayer. HELYES API: konstruktor, NINCS fromFile, NINCS await a provideren.

import 'dart:io';

import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// PMTiles fájlból vektor csemperéteg készítése.
/// [pmtileFile] - a .pmtiles fájl
/// [theme]       - vtr.Theme (createDayTheme/createNightTheme eredménye)
Future<VectorTileLayer> pmtilesLayer(File pmtileFile, vtr.Theme theme) async {
  if (!await pmtileFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtileFile.path}');
  }

  // Helyes provider példányosítás (konstruktor, nem fromFile)
  final prov = await PmTilesVectorTileProvider.fromSource(
  pmtileFile.path,
  maximumZoom: 14,
);
// A Protomaps témák a 'protomaps' forrásnévre számítanak.
  return VectorTileLayer(
    theme: theme,
    tileProviders: TileProviders({'protomaps': prov}),
  );
}

