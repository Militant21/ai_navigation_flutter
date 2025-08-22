import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/route_models.dart';
import '../models/truck.dart';

enum ProfileKind { short, motorway, eco }
class RouteOptions { final ProfileKind profile; final String lang; RouteOptions(this.profile,this.lang); }

class RoutingEngine {
  static const _ch = MethodChannel('ainav.routing');

  static Future<RouteResult> route(List<Coord> wps, TruckProfile truck, RouteOptions opts) async {
    try {
      final res = await _ch.invokeMethod('route', {
        'waypoints': wps.map((e)=>{'lon':e.lon,'lat':e.lat}).toList(),
        'truck': truck.toJson(),
        'opts': {'profile': opts.profile.name, 'lang': opts.lang}
      });
      final j = (res is String)? jsonDecode(res) : res;
      final line = (j['line'] as List).map<List<double>>((p)=>[(p[0] as num).toDouble(), (p[1] as num).toDouble()]).toList();
      final mans = (j['maneuvers'] as List).map<Maneuver>((m)=>Maneuver((m['dist'] as num).toDouble(), m['type'], m['road_class'], m['instruction'])).toList();
      return RouteResult(line: line, distanceKm: (j['distance_km'] as num).toDouble(), durationMin: (j['duration_min'] as num).toDouble(), eta: DateTime.parse(j['eta_iso']), mans: mans);
    } catch (e) {
      // Fallback: ha a natív motor nincs még beépítve, dobjunk érthető hibát
      throw Exception('Routing engine not available: $e');
    }
  }
}