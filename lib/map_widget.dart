import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import 'services/tiles_provider.dart';
import 'models/route_models.dart';

class MapWidget extends StatefulWidget {
  final MapController mapCtrl;
  final File? pmtiles;
  final vtr.Theme? theme;

  final LatLng? myLocation;       // zöld pont
  final Color myColor;

  final List<Polyline> lines;
  final List<Marker> poiMarkers;
  final List<Coord> wps;

  final VoidCallback onCameraMoved;          // debounced frissítés
  final VoidCallback onUserGesture;          // user mozgatás
  final void Function(LatLng p) onLongPress; // új waypoint

  final String zoomPreset; // 'near'|'mid'|'far'
  final LatLng initialCenter;

  const MapWidget({
    super.key,
    required this.mapCtrl,
    required this.pmtiles,
    required this.theme,
    required this.myLocation,
    required this.myColor,
    required this.lines,
    required this.poiMarkers,
    required this.wps,
    required this.onCameraMoved,
    required this.onUserGesture,
    required this.onLongPress,
    required this.zoomPreset,
    required this.initialCenter,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? _lastCenter;
  double? _lastZoom;
  double? _lastRotation;

  Future<Widget?>? _layerFut;   // pmtiles réteg cache
  Timer? _moveDebounce;         // POI-debounce

  @override
  void initState() {
    super.initState();
    _rebuildLayer();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pmtiles?.path != widget.pmtiles?.path || oldWidget.theme != widget.theme) {
      _rebuildLayer();
    }
  }

  void _rebuildLayer() {
    _layerFut = (widget.pmtiles == null || widget.theme == null)
        ? Future.value(null)
        : pmtilesLayer(widget.pmtiles!, theme: widget.theme!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pmtiles == null || widget.theme == null) {
      return const Center(child: Text('No region'));
    }

    final initZoom = widget.zoomPreset == 'near' ? 15.0 : widget.zoomPreset == 'mid' ? 13.0 : 11.0;

    return FutureBuilder<Widget?>(
      future: _layerFut,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final tileLayer = snapshot.data!;

        return FlutterMap(
          mapController: widget.mapCtrl,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: initZoom,
            onMapEvent: (evt) {
              // Verziófüggetlen user-gesture detektálás
              if (evt.source != MapEventSource.mapController) {
                widget.onUserGesture();
              }

              // Kamera-változás figyelése
              final cam = widget.mapCtrl.camera;
              const epsZoom = 0.001;
              const epsRot  = 0.1;
              bool changed = false;
              if (_lastCenter == null) {
                changed = true;
              } else {
                final movedLat = _lastCenter!.latitude  != cam.center.latitude;
                final movedLon = _lastCenter!.longitude != cam.center.longitude;
                final zoomChanged = ((_lastZoom ?? -999) - cam.zoom).abs() > epsZoom;
                final rotChanged  = ((_lastRotation ?? -999) - cam.rotation).abs() > epsRot;
                changed = movedLat || movedLon || zoomChanged || rotChanged;
              }
              _lastCenter = cam.center;
              _lastZoom = cam.zoom;
              _lastRotation = cam.rotation;

              if (changed) {
                _moveDebounce?.cancel();
                _moveDebounce = Timer(const Duration(milliseconds: 120), widget.onCameraMoved);
              }
            },
            onLongPress: (_, p) => widget.onLongPress(p),
          ),
          children: [
            tileLayer,                                // vektor csempék
            PolylineLayer(polylines: widget.lines),   // útvonal
            if (widget.myLocation != null)
              MarkerLayer(markers: _myLocationMarkers(widget.myLocation!, widget.myColor)),
            MarkerLayer(markers: widget.poiMarkers),  // POI-k
            MarkerLayer(                              // waypontok
              markers: widget.wps
                  .map((w) => Marker(
                        point: LatLng(w.lat, w.lon),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.place, color: Colors.red),
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  List<Marker> _myLocationMarkers(LatLng p, Color color) => [
        Marker(
          point: p,
          width: 38,
          height: 38,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(.20),
              border: Border.all(color: color.withOpacity(.6), width: 2),
            ),
          ),
        ),
        Marker(
          point: p,
          width: 14,
          height: 14,
          child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        ),
      ];
}
