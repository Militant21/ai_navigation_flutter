// lib/services/tiles_provider.dart
//
// PMTiles -> VectorTileLayer provider (csak PMTiles, MBTiles nélkül)

import 'dart:io';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Alapértelmezett téma: nappali
vtr.Theme defaultMapTheme() => vtr.createDayTheme();

/// PMTiles fájlból VectorTileLayer készítése.
/// [pmtileFile] = a .pmtiles fájl (pl. assets-ből kimásolva egy írásos mappába).
/// [theme] opcionális; ha nem adsz, akkor `defaultMapTheme()` lesz.
Future<VectorTileLayer> pmtilesLayer(File pmtileFile, [vtr.Theme? theme]) async {
  if (!pmtileFile.existsSync()) {
    throw StateError('PMTiles file nem található: ${pmtileFile.path}');
  }

  // Helyes provider példányosítás PMTiles-hez
  final prov = await PmTilesVectorTileProvider.fromSource(pmtileFile.path);

  // Protomaps témák a 'protomaps' forrásnévre számítanak
  return VectorTileLayer(
    theme: theme ?? defaultMapTheme(),
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
