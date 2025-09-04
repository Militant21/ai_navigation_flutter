import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/pois_db.dart';

class PoiController {
  final PoisDB? db;
  PoiController(this.db);

  Future<List<Marker>> markersForView(
    MapCamera cam, {
    required bool parks,
    required bool fuel,
    required bool services,
    required bool cameras,
    required String style,
  }) async {
    if (db == null) return const <Marker>[];

    final span = math.max(0.02, 2.0 / math.pow(2.0, (cam.zoom - 8)));
    final w = cam.center.longitude - span, e = cam.center.longitude + span;
    final s = cam.center.latitude - span, n = cam.center.latitude + span;

    // Zoomfüggő limit: távolról kevesebb marker
    final z = cam.zoom;
    final lim = z < 9 ? 120 : z < 11 ? 200 : z < 13 ? 300 : 500;

    final out = <Marker>[];
    IconData _ico(String k) =>
        k == 'park' ? Icons.local_parking : k == 'fuel' ? Icons.local_gas_station : k == 'svc' ? Icons.build : Icons.camera_alt;

    Future<void> add(String table, String key) async {
      final rows = await db!.inBBox(table: table, west: w, south: s, east: e, north: n, limit: lim);
      out.addAll(rows.map((r) => Marker(
            point: LatLng((r['lat'] as num).toDouble(), (r['lon'] as num).toDouble()),
            width: 36,
            height: 36,
            child: Tooltip(
              message: (r['name'] as String?) ?? (r['brand'] as String?) ?? '',
              child: Icon(_ico(key), size: 22, color: style == 'day' ? Colors.blueGrey : Colors.white),
            ),
          )));
    }

    if (parks) await add('truck_parks', 'park');
    if (fuel) await add('truck_fuel', 'fuel');
    if (services) await add('services', 'svc');
    if (cameras) await add('cameras', 'cam');

    return out;
  }
}
