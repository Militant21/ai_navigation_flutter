import 'package:flutter/material.dart';
class Coord { final double lon; final double lat; const Coord(this.lon,this.lat); }
class Maneuver { final double dist; final String type; final String? roadClass; final String instruction; Maneuver(this.dist,this.type,this.roadClass,this.instruction); }
class RouteResult { final List<List<double>> line; final double distanceKm; final double durationMin; final DateTime eta; final List<Maneuver> mans; RouteResult({required this.line,required this.distanceKm,required this.durationMin,required this.eta,required this.mans}); }