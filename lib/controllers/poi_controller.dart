import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/pois_db.dart';

class PoiController {
  final PoisDB? db;
  PoiController(this.db);

  // ===== Alap POI a térképnél (marad a régi viselkedés) =====
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

    final z = cam.zoom;
    final lim = z < 9 ? 120 : z < 11 ? 200 : z < 13 ? 300 : 500;

    final out = <Marker>[];
    IconData _ico(String k) =>
        k == 'park' ? Icons.local_parking : k == 'fuel' ? Icons.local_gas_station : k == 'svc' ? Icons.build : Icons.camera_alt;

    Future<void> add(String table, String key) async {
      final rows = await db!.inBBox(table: table, west: w, south: s, east: e, north: n, limit: lim);
      out.addAll(rows.map((r) => _mkMarker(
            LatLng((r['lat'] as num).toDouble(), (r['lon'] as num).toDouble()),
            _ico(key),
            style,
            (r['name'] as String?) ?? (r['brand'] as String?) ?? '',
          )));
    }

    if (parks) await add('truck_parks', 'park');
    if (fuel) await add('truck_fuel', 'fuel');
    if (services) await add('services', 'svc');
    if (cameras) await add('cameras', 'cam');

    return out;
  }

  // ===== ÚJ: "találat" modell, úton előre mutatva =====
  class ParkingHit {
    final LatLng point;
    final String title;
    final double routeKmFromMe;      // útvonal mentén, tőlem előre (km)
    final double routeKmFromStart;   // útvonal mentén a starttól (km)
    ParkingHit(this.point, this.title, this.routeKmFromMe, this.routeKmFromStart);
  }

  // Úton, előre (csak haladási irány), kis oldaleltérés engedve
  Future<List<ParkingHit>> upcomingOnRoute({
    required List<LatLng> route,
    required LatLng? me,
    required double lateralToleranceMeters, // pl. 60 m
    required double aheadKmLimit,           // pl. 150 km a nagy listához
  }) async {
    if (db == null || route.length < 2) return const <ParkingHit>[];

    // Kumulált szelvényezés a gyors projekcióhoz
    final _Seg sdata = _prepRoute(route);
    final double sMe = me == null ? 0.0 : _projectOnRouteMeters(me, sdata).$1;

    // Egyetlen nagy bbox a teljes útvonalra + kis ráhagyás
    final bb = _routeBBox(route);
    final midLat = (bb.s + bb.n) / 2;
    final padLat = lateralToleranceMeters / 111320.0;
    final padLon = lateralToleranceMeters / (111320.0 * math.cos(midLat * math.pi / 180.0));

    final rows = await db!.inBBox(
      table: 'truck_parks',
      west: bb.w - padLon,
      south: bb.s - padLat,
      east: bb.e + padLon,
      north: bb.n + padLat,
      limit: 8000,
    );

    final hits = <ParkingHit>[];
    for (final r in rows) {
      final p = LatLng((r['lat'] as num).toDouble(), (r['lon'] as num).toDouble());
      final (sP, lateral) = _projectOnRouteMeters(p, sdata);
      if (lateral <= lateralToleranceMeters) {
        final ahead = (sP - sMe) / 1000.0; // km-ben
        if (ahead >= 0 && ahead <= aheadKmLimit) {
          final name = (r['name'] as String?) ?? (r['brand'] as String?) ?? 'Parkoló';
          hits.add(ParkingHit(p, name, ahead, sP / 1000.0));
        }
      }
    }

    hits.sort((a, b) => a.routeKmFromMe.compareTo(b.routeKmFromMe));
    return hits;
  }

  // Cél vagy felhasználó közelében, sugárban
  Future<List<ParkingHit>> parksNearHits({
    required LatLng center,
    required double radiusMeters,    // 21000
    required String titlePrefix,     // "tőlem" / "céltól" kezeléséhez csak cím kell, a UI dönt
  }) async {
    if (db == null) return const <ParkingHit>[];

    final degLat = radiusMeters / 111320.0;
    final degLon = radiusMeters / (111320.0 * math.cos(center.latitude * math.pi / 180.0));

    final w = center.longitude - degLon, e = center.longitude + degLon;
    final s = center.latitude - degLat, n = center.latitude + degLat;

    final rows = await db!.inBBox(table: 'truck_parks', west: w, south: s, east: e, north: n, limit: 4000);

    final out = <ParkingHit>[];
    for (final r in rows) {
      final p = LatLng((r['lat'] as num).toDouble(), (r['lon'] as num).toDouble());
      final d = _hav(center, p);
      if (d <= radiusMeters) {
        final name = (r['name'] as String?) ?? (r['brand'] as String?) ?? 'Parkoló';
        // routeKmFromMe mezőbe most is a km-t rakjuk (de ez „sugár” szerinti)
        out.add(ParkingHit(p, name, d / 1000.0, 0));
      }
    }
    out.sort((a, b) => a.routeKmFromMe.compareTo(b.routeKmFromMe));
    return out;
  }

  // ===== Segédek =====

  Marker _mkMarker(LatLng p, IconData icon, String style, String tip) => Marker(
        point: p,
        width: 36,
        height: 36,
        child: Tooltip(message: tip, child: Icon(icon, size: 22, color: style == 'day' ? Colors.blueGrey : Colors.white)),
      );

  double _hav(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final s1 = math.sin(dLat / 2), s2 = math.sin(dLon / 2);
    final h = s1 * s1 + math.cos(a.latitude * math.pi / 180.0) * math.cos(b.latitude * math.pi / 180.0) * s2 * s2;
    return 2 * R * math.asin(math.min(1.0, math.sqrt(h)));
  }

  ({double w, double s, double e, double n}) _routeBBox(List<LatLng> line) {
    double minLat = 90, maxLat = -90, minLon = 180, maxLon = -180;
    for (final p in line) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }
    return (w: minLon, s: minLat, e: maxLon, n: maxLat);
  }

  // Equirect projekció a polylinere (gyors), vissza: (ívhossz méterben, laterális távolság méterben)
  (double, double) _projectOnRouteMeters(LatLng p, _Seg s) {
    final ax = p.longitude * s.kx, ay = p.latitude * s.ky;
    double bestDist2 = double.infinity;
    double bestS = 0.0;

    for (var i = 0; i < s.x.length - 1; i++) {
      final x1 = s.x[i], y1 = s.y[i], x2 = s.x[i + 1], y2 = s.y[i + 1];
      final vx = x2 - x1, vy = y2 - y1;
      final wx = ax - x1, wy = ay - y1;
      final c1 = vx * wx + vy * wy;
      final c2 = vx * vx + vy * vy;
      final t = c2 <= 0 ? 0.0 : (c1 / c2).clamp(0.0, 1.0);
      final projx = x1 + t * vx, projy = y1 + t * vy;
      final dx = ax - projx, dy = ay - projy;
      final dist2 = dx * dx + dy * dy;
      if (dist2 < bestDist2) {
        bestDist2 = dist2;
        final segLen = math.sqrt(c2);
        bestS = s.cum[i] + segLen * t;
      }
    }
    return (bestS, math.sqrt(bestDist2));
  }

  _Seg _prepRoute(List<LatLng> route) {
    final lat0 = route.first.latitude * math.pi / 180.0;
    final kx = 111320.0 * math.cos(lat0);
    const ky = 111320.0;
    final x = <double>[], y = <double>[], cum = <double>[];
    double acc = 0.0;
    for (final p in route) {
      x.add(p.longitude * kx);
      y.add(p.latitude * ky);
    }
    cum.add(0.0);
    for (var i = 0; i < x.length - 1; i++) {
      final dx = x[i + 1] - x[i], dy = y[i + 1] - y[i];
      acc += math.sqrt(dx * dx + dy * dy);
      cum.add(acc);
    }
    return _Seg(x, y, cum, kx, ky);
  }
}

class _Seg {
  final List<double> x, y, cum;
  final double kx, ky;
  _Seg(this.x, this.y, this.cum, this.kx, this.ky);
}
