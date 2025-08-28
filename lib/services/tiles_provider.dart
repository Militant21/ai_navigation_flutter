import 'dart:io';

import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

// Semleges alap téma – ezen a verzión elérhető
vtr.Theme defaultMapTheme() => vtr.createDefaultTheme();

Future<VectorTileLayer> pmtilesLayer(File pmtileFile, [vtr.Theme? theme]) async {
  if (!pmtileFile.existsSync()) {
    throw StateError('PMTiles file nem található: ${pmtileFile.path}');
  }

  final prov = await PmTilesVectorTileProvider.fromSource(pmtileFile.path);

  return VectorTileLayer(
    theme: theme ?? defaultMapTheme(),
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
