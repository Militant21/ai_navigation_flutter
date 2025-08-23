// lib/services/tiles_provider.dart
// MIT CSINÁL?: Egy .pmtiles fájlból készít egy VectorTileLayer-t, amit a FlutterMap-be
// tudsz betenni. A téma (day/night) a vector_tile_renderer Theme (vtr.Theme) lesz.

import 'dart:io';

import 'package:vector_map_tiles/vector_map_tiles.dart';                // <-- a vektor-layer widgethez
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart'; // <-- PMTiles provider (ÚJ API!)
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;  // <-- a téma típusa (vtr.Theme)

/// [pmtilesFile] = régió .pmtiles fájlja (pl. .../regions/HU/tiles.pmtiles)
/// [theme]       = a vektor renderer témája (pl. classicDayTheme / classicNightTheme)
Future<VectorTileLayer> pmtilesLayer(File pmtilesFile, vtr.Theme theme) async {
  // 1) Ellenőrizzük, hogy a fájl létezik-e — ha nincs, korán jelezzünk hibát.
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  // 2) PMTiles provider LÉTREHOZÁSA
  // FONTOS: ÚJ API! Nincs .fromFile — a konstruktort kell hívni a path-tal.
  // maximumZoom: meddig legyen részletes; 12–15 tipikus. (14 jó default.)
  final prov = PmTilesVectorTileProvider(
    pmtilesFile.path,
    maximumZoom: 14,
  );

  // 3) VectorTileLayer visszaadása
  // FIGYELEM: A TileProviders kulcsát ('protomaps') érdemes megtartani,
  // mert a ProtomapsThemes a "protomaps" forrásnévvel dolgozik.
  return VectorTileLayer(
    theme: theme,                          // <- vtr.Theme (classicDayTheme / Night)
    tileProviders: TileProviders({
      'protomaps': prov,                   // <- ugyanazzal a névvel regisztráljuk
    }),
  );
}
