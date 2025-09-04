import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationController {
  LocationController._();
  static final instance = LocationController._();

  final ValueNotifier<Position?> position = ValueNotifier<Position?>(null);
  bool followMe = true;
  StreamSubscription<Position>? _sub;

  Future<void> start() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;

    try {
      position.value = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    } catch (_) {}

    _sub?.cancel();
    _sub = Geolocator.getPositionStream().listen((p) => position.value = p);
  }

  void stop() => _sub?.cancel();

  void centerOnMap(MapController mapCtrl) {
    final p = position.value;
    if (p == null) return;
    mapCtrl.move(LatLng(p.latitude, p.longitude), mapCtrl.camera.zoom);
  }
}
