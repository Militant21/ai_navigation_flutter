import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/pois_db.dart';

class Region {
  final File pmtiles;
  final PoisDB? pois;
  Region(this.pmtiles, this.pois);
}

class RegionLocator {
  RegionLocator._();
  static final instance = RegionLocator._();

  Future<Region?> loadFirstRegion() async {
    Directory? dir;
    final primary = Directory('/storage/emulated/0/maps');
    if (await primary.exists()) {
      dir = primary;
    } else {
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final d = Directory('${ext.path}/regions');
        if (await d.exists()) dir = d;
      }
      if (dir == null) {
        final docs = await getApplicationDocumentsDirectory();
        final d = Directory('${docs.path}/regions');
        if (await d.exists()) dir = d;
      }
    }
    if (dir == null) return null;

    await for (final e in dir.list()) {
      if (e is File && e.path.toLowerCase().endsWith('.pmtiles')) {
        final pm = e;
        final pf = File(e.path.replaceAll(RegExp(r'\.pmtiles$', caseSensitive:false), '.sqlite'));
        PoisDB? db;
        if (await pf.exists()) db = await PoisDB.open(pf.path);
        return Region(pm, db);
      }
    }
    return null;
  }
}
