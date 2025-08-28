import 'dart:io';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

/// Alap (világos) téma a 5.x API-hoz.
vtr.Theme defaultMapTheme() => vtr.createDayTheme();

/// PMTiles fájlból VectorTileLayer készítése.
/// [pmtileFile] a .pmtiles fájl.
/// [theme] opcionális; ha nincs megadva, defaultMapTheme() lép életbe.
Future<VectorTileLayer> pmtilesLayer(File pmtileFile, [vtr.Theme? theme]) async {
  if (!pmtileFile.existsSync()) {
    throw StateError('PMTiles file nem található: ${pmtileFile.path}');
  }

  // Helyes provider példányosítás (konstruktor, nem fromFile)
  final prov = await PmTilesVectorTileProvider.fromSource(pmtileFile.path);

  // A Protomaps témák a 'protomaps' forrásnévre számítanak.
  return VectorTileLayer(
    theme: theme ?? defaultMapTheme(),
    tileProviders: TileProviders({'protomaps': prov}),
  );
}
