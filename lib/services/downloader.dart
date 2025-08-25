import 'package:flutter/material.dart';
import 'dart:convert'; // <-- kell a jsonDecode/jsonEncode-hoz
import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionPaths {
  final Directory root;
  final File pmtiles;
  final File mbtiles;
  final File pois;
  final File valhalla;
  RegionPaths(this.root, this.pmtiles, this.mbtiles, this.pois, this.valhalla);
}

Future<RegionPaths> regionPaths(String regionId) async {
  final dir = await getApplicationDocumentsDirectory();
  final root = Directory('${dir.path}/regions/$regionId');
  await root.create(recursive: true);
  return RegionPaths(
    root,
    File('${root.path}/tiles.pmtiles'),
    File('${root.path}/tiles.mbtiles'),
    File('${root.path}/pois.sqlite'),
    File('${root.path}/valhalla_tiles.tar'),
  );
}

Future<void> downloadFile(String url, File to, {void Function(double p)? onProgress}) async {
  final task = DownloadTask(
    url: url,
    filename: to.path.split('/').last,
    directory: to.parent.path,
    updates: Updates.statusAndProgress,
  );
  await FileDownloader().download(
    task,
    onProgress: (p) => onProgress?.call(p),
    onStatus: (s) {},
  );
}

/// ------- Telepítési nyilvántartás (verzió szerint) -------

const _kInstalled = 'installed_regions'; // JSON map { regionId: { "version": "...", "time": 123456 } }

Future<Map<String, dynamic>> _loadInstalled() async {
  final sp = await SharedPreferences.getInstance();
  final s = sp.getString(_kInstalled);
  if (s == null || s.isEmpty) return {};
  try {
    return Map<String, dynamic>.from(jsonDecode(s));
  } catch (_) {
    return {};
  }
}

Future<void> _saveInstalled(Map<String, dynamic> m) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(_kInstalled, jsonEncode(m));
}

Future<String?> installedVersion(String regionId) async {
  final m = await _loadInstalled();
  final e = m[regionId];
  if (e is Map && e['version'] is String) return e['version'] as String;
  return null;
}

Future<void> markInstalled(String regionId, String? version) async {
  final m = await _loadInstalled();
  m[regionId] = {
    'version': version ?? '',
    'time': DateTime.now().millisecondsSinceEpoch,
  };
  await _saveInstalled(m);
}
