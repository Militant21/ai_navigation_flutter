import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/catalog.dart';

Future<Catalog> fetchCatalog(String url) async {
  final r = await http.get(Uri.parse(url));
  if (r.statusCode != 200) {
    throw Exception('Catalog HTTP ${r.statusCode}');
  }
  final j = jsonDecode(r.body) as Map<String, dynamic>;
  final regions = (j['regions'] as List).map((x) {
    return Region(
      id: x['id'],
      name: x['name'],
      country: x['country'] ?? '',
      version: x['version'],
      pmtiles: x['pmtiles'],
      mbtiles: x['mbtiles'],
      pois: x['pois'],
      valhalla: x['valhalla'],
      approxSizeMb: x['approx_size_mb'],
    );
  }).toList();
  return Catalog(j['version'] ?? '0', regions);
}