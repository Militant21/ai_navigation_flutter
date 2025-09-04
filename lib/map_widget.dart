import 'dart:math' as math;
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

  final LatLng? myLocation;
  final Color myColor;

  final List<Polyline> lines;
  final List<Marker> poiMarkers;
  final List<Coord> wps;

  final VoidCallback onCameraMoved;           // amikor a kamera tényleg elmozdult
  final VoidCallback onUserGesture;           // user érintéssel indított mozgatás
  final void Function(LatLng p) onLongPress;  // új waypoint

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

  Future<Widget?> _layerFuture() async {
    if (widget.pmtiles == null || widget.theme == null) return null;
    return pmtilesLayer(widget.pmtiles!, theme: widget.theme!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pmtiles == null || widget.theme == null) {
      return const Center(child: Text('No region'));
    }
    return FutureBuilder(
      future: _layerFuture(),
      builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        final initZoom = widget.zoomPreset == 'near' ? 15.0 : widget.zoomPreset == 'mid' ? 13.0 : 11.0;
        return FlutterMap(
          mapController: widget.mapCtrl,
          options: MapOptions(
            center: widget.initialCenter,
            zoom: initZoom,
            onMapEvent: (evt) {
              // user érintésből induló mozgatás → szólunk a szülőnek (follow off)
              if (evt.source == MapEventSource.dragStart || evt.source == MapEventSource.multiFingerStart) {
                widget.onUserGesture();
              }
              // detektáljuk, tényleg változott-e a kamera
              final cam = widget.mapCtrl.camera;
              const epsZoom = 0.001;
              const epsRot = 0.1;
              bool changed = false;
              if (_lastCenter == null) {
                changed = true;
              } else {
                final movedLat = _lastCenter!.latitude != cam.center.latitude;
                final movedLon = _lastCenter!.longitude != cam.center.longitude;
                final zoomDiff = (_lastZoom ?? -999) - cam.zoom;
                final rotDiff = (_lastRotation ?? -999) - cam.rotation;
                changed = movedLat || movedLon || zoomDiff.abs() > epsZoom || rotDiff.abs() > epsRot;
              }
              _lastCenter = cam.center;
              _lastZoom = cam.zoom;
              _lastRotation = cam.rotation;
              if (changed) widget.onCameraMoved();
            },
            onLongPress: (tapPos, p) => widget.onLongPress(p),
          ),
          children: [
            s.data as Widget,                      // pmtiles vektor csempék
            PolylineLayer(polylines: widget.lines),
            if (widget.myLocation != null)         // zöld helyzetjelző (aura + pötty)
              MarkerLayer(markers: _myLocationMarkers(widget.myLocation!, widget.myColor)),
            MarkerLayer(markers: widget.poiMarkers),
            MarkerLayer(
              markers: widget.wps.map((w) => Marker(
                point: LatLng(w.lat, w.lon),
                width: 40, height: 40,
                child: const Icon(Icons.place, color: Colors.red),
              )).toList(),
            ),
          ],
        );
      },
    );
  }

  List<Marker> _myLocationMarkers(LatLng p, Color color) => [
    Marker(
      point: p, width: 38, height: 38,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(.20),
          border: Border.all(color: color.withOpacity(.6), width: 2),
        ),
      ),
    ),
    Marker(
      point: p, width: 14, height: 14,
      child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    ),
  ];
}
