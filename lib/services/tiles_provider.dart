// lib/services/tiles_provider.dart
//
// MIT CSINÁL EZ A FÁJL?
//   - Egy .pmtiles fájlból csempeszolgáltatót csinál
//   - Ebből létrehoz egy VectorTileLayer-t, amit a FlutterMap meg tud jeleníteni
//
// MIÉRT ÍGY?
//   - A 'vector_map_tiles_pmtiles' mostani verziójában NINCS fromFile(), csak konstruktor.
//   - A gyári Protomaps témák a 'protomaps' forrásnévre vannak hangolva.

import 'dart:io';

import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// pmtilesFile: a régió .pmtiles fájlja (pl. <app-docs>/regions/HU/tiles.pmtiles)
/// theme: a vector_tile_renderer témája (pl. classicDayTheme / classicNightTheme)
Future<VectorTileLayer> pmtilesLayer(File pmtilesFile, vtr.Theme theme) async {
  // 1) Védőkorlát: ha nincs fájl, inkább dobjunk érthető hibát.
  if (!await pmtilesFile.exists()) {
    throw StateError('PMTiles file not found: ${pmtilesFile.path}');
  }

  // 2) PMTiles provider a JELENLEGI API szerint (konstruktorként, NEM fromFile).
  final prov = PmTilesVectorTileProvider(
    pmtilesFile.path,
    maximumZoom: 14, // 12–15 között szokás, 14 jó kompromisszum
  );

  // 3) Csemperéteg: a ‘protomaps’ kulcsot tartsuk meg (a témák ezt várják).
  return VectorTileLayer(
    theme: theme,
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
