// lib/services/tiles_provider.dart
//
// PMTiles → VectorTileLayer provider (csak PMTiles, MBTiles nélkül)

import 'dart:io';

import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Gyors téma helper — ha nincs külön téma, ad egy semleges világosat.
vtr.Theme defaultMapTheme() => vtr.createDefaultTheme();

/// PMTiles fájlból VectorTileLayer készítése.
/// [pmtileFile] a .pmtiles fájlod (pl. assets-ből kimásolva egy írásos mappába).
/// [theme] opcionális; ha nem adsz, `defaultMapTheme()` lesz.
Future<VectorTileLayer> pmtilesLayer(
  File pmtileFile, {
  vtr.Theme? theme,
}) async {
  if (!await pmtileFile.exists()) {
    throw StateError('PMTiles file nem található: ${pmtileFile.path}');
  }

  // Helyes provider példányosítás PMTiles-hez:
  final prov = await PmTilesVectorTileProvider.fromSource(pmtileFile.path);

  // A Protomaps témák a 'protomaps' forrásnévre számítanak.
  return VectorTileLayer(
    theme: theme ?? defaultMapTheme(),
    tileProviders: TileProviders({
      'protomaps': prov,
    }),
  );
}
