import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/catalog.dart';

Future<Catalog> fetchCatalog(String url) async {
  final r = await http.get(Uri.parse(url));
  if (r.statusCode != 200) {
    throw Exception('Catalog HTTP ${r.statusCode}');
  }

  final j = jsonDecode(r.body) as Map<String, dynamic>;
  final List<dynamic> rawRegions = (j['regions'] as List?) ?? const [];

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v);
    return null;
  }

  final regions = rawRegions.map((x) {
    final m = x as Map<String, dynamic>;
    return Region(
      id: (m['id'] ?? '').toString(),          // kötelező, nem-null
      name: (m['name'] ?? '').toString(),
      country: (m['country'] ?? '').toString(),
      version: (m['version'])?.toString(),
      pmtiles: (m['pmtiles'])?.toString(),
      mbtiles: (m['mbtiles'])?.toString(),
      pois: (m['pois'])?.toString(),
      valhalla: (m['valhalla'])?.toString(),
      approxSizeMb: _toInt(m['approx_size_mb']),
    );
  }).toList();

  return Catalog((j['version'] ?? '0').toString(), regions);
}
