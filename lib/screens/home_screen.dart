import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';

import '../services/tiles_provider.dart';
import '../services/storage.dart';
import '../services/tts.dart';
import '../services/routing_engine.dart';
import '../services/pois_db.dart';

import '../models/route_models.dart';
import '../models/truck.dart';

import '../theme/classic_day.dart';
import '../theme/classic_night.dart';

import '../widgets/waypoint_list.dart';
import '../widgets/profile_picker.dart';
import '../widgets/poi_toggles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  // a vektor-tile renderer témája – ezt adja a VectorTileLayer
  vtr.Theme? _theme;

  File? _pmtiles;
  File? _poisFile;
  PoisDB? _pois;

  final mapCtrl = MapController();

  List<Coord> wps = const [Coord(19.040, 47.497), Coord(19.260, 47.530)];
  TruckProfile truck = TruckProfile();
  ProfileKind profile = ProfileKind.motorway;

  bool showCameras = false, showParks = true, showFuel = true, showServices = false;
  String style = 'day';
  String zoom = 'mid';

  RouteResult? rr;
  List<Polyline> lines = [];
  List<Marker> poiMarkers = [];

  @override
  void initState() {
    super.initState();
    _loadState();
    _initTheme();
    _loadRegionIfAny();
  }

  Future<void> _loadState() async {
    final s = await KV.get<Map>('state');
    final set = await KV.get<Map>('settings');
    if (!mounted) return;
    setState(() {
      style = s?['style'] ?? 'day';
      zoom = s?['zoom'] ?? 'mid';
      showCameras = set?['speedCameras'] ?? false;
      showParks = s?['parks'] ?? true;
      showFuel = s?['fuel'] ?? true;
      showServices = s?['svc'] ?? false;
      wps = (s?['wps'] as List?)?.map((e) => Coord((e[0] as num) * 1.0, (e[1] as num) * 1.0)).toList() ?? wps;
    });
  }

  Future<void> _saveState() async {
    await KV.set('state', {
      'style': style,
      'zoom': zoom,
      'parks': showParks,
      'fuel': showFuel,
      'svc': showServices,
      'wps': wps.map((w) => [w.lon, w.lat]).toList()
    });
  }

  void _initTheme() {
    // vtr.Theme típus!
    setState(() => _theme = style == 'day' ? classicDayTheme() : classicNightTheme());
  }

  Future<void> _loadRegionIfAny() async {
    final doc = await getApplicationDocumentsDirectory();
    final regionsDir = Directory('${doc.path}/regions');
    if (!await regionsDir.exists()) return;

    for (final e in await regionsDir.list().toList()) {
      final p = File('${e.path}/tiles.pmtiles');
      final pois = File('${e.path}/pois.sqlite');
      if (await p.exists()) {
        setState(() => _pmtiles = p);
      }
      if (await pois.exists()) {
        _poisFile = pois;
        _pois = await PoisDB.open(pois.path);
      }
      if (_pmtiles != null) break;
    }

    if (mounted) _refreshPoisFromView();
  }

  Future<void> _route() async {
    try {
      final r = await RoutingEngine.route(
        wps,
        truck,
        RouteOptions(
          profile,
          context.locale.languageCode == 'hu'
              ? 'hu-HU'
              : context.locale.languageCode == 'de'
                  ? 'de-DE'
                  : 'en-US',
        ),
      );
      if (!mounted) return;
      setState(() {
        rr = r;
        lines = [
          Polyline(
            points: r.line.map((e) => LatLng(e[1], e[0])).toList(),
            strokeWidth: 5,
            color: Colors.orange,
          )
        ];
      });
      _scheduleCues(r);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Routing error: $e')));
    }
  }

  void _scheduleCues(RouteResult r) {
    if (r.mans.isEmpty) return;
    final next = r.mans.first;
    final isMw = (next.roadClass ?? '').contains('motorway') || (next.roadClass ?? '').contains('trunk');
    speak(isMw ? 'Autópálya lehajtó 3 km múlva' : 'Lehajtó 2 km múlva', 'hu-HU');
    speak(isMw ? 'Lehajtó 500 méter múlva' : 'Lehajtó 300 méter múlva', 'hu-HU');
  }

  // --- POI frissítés ---

  // NINCS paraméter → nem lesz MapPosition/MapCamera típushiba
  void _onMapMoved() {
    _refreshPoisFromView();
  }

  Future<void> _refreshPoisFromView() async {
    if (_pois == null) return;
    final center = mapCtrl.camera.center;
    final zoomVal = mapCtrl.camera.zoom;

    final span = math.max(0.02, 2.0 / math.pow(2.0, (zoomVal - 8)));
    final west = center.longitude - span;
    final east = center.longitude + span;
    final south = center.latitude - span;
    final north = center.latitude + span;

    final markers = <Marker>[];

    if (showParks) {
      final rows = await _pois!.inBBox(table: 'truck_parks', west: west, south: south, east: east, north: north, limit: 300);
      markers.addAll(rows.map((r) => _mk(r, Icons.local_parking)));
    }
    if (showFuel) {
      final rows = await _pois!.inBBox(table: 'truck_fuel', west: west, south: south, east: east, north: north, limit: 300);
      markers.addAll(rows.map((r) => _mk(r, Icons.local_gas_station)));
    }
    if (showServices) {
      final rows = await _pois!.inBBox(table: 'services', west: west, south: south, east: east, north: north, limit: 300);
      markers.addAll(rows.map((r) => _mk(r, Icons.build)));
    }
    if (showCameras) {
      final rows = await _pois!.inBBox(table: 'cameras', west: west, south: south, east: east, north: north, limit: 300);
      markers.addAll(rows.map((r) => _mk(r, Icons.camera_alt)));
    }

    if (!mounted) return;
    setState(() => poiMarkers = markers);
  }

  Marker _mk(Map<String, Object?> r, IconData icon) => Marker(
        point: LatLng((r['lat'] as num).toDouble(), (r['lon'] as num).toDouble()),
        width: 36,
        height: 36,
        child: Tooltip(
          message: (r['name'] as String?) ?? (r['brand'] as String?) ?? '',
          child: Icon(icon, size: 22, color: style == 'day' ? Colors.blueGrey : Colors.white),
        ),
      );

  // --- UI ---

  @override
  Widget build(BuildContext ctx) {
    final layerFut = _pmtiles != null && _theme != null ? pmtilesLayer(_pmtiles!, _theme!) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Navigation'),
        actions: [
          IconButton(
            tooltip: tr('download_region'),
            icon: const Icon(Icons.cloud_download),
            onPressed: () => Navigator.pushNamed(context, '/catalog').then((_) => _loadRegionIfAny()),
          ),
          IconButton(
            tooltip: tr('settings'),
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings').then((_) => _loadState()),
          ),
        ],
      ),
      body: _pmtiles == null
          ? _noRegion(ctx)
          : FutureBuilder<Widget>(
              future: layerFut,
              builder: (c, s) {
                if (!s.hasData) return const Center(child: CircularProgressIndicator());
                return Stack(children: [
                  FlutterMap(
                    mapController: mapCtrl,
                    options: MapOptions(
                      center: LatLng(47.497, 19.040),
                      zoom: zoom == 'near' ? 15 : zoom == 'mid' ? 13 : 11,
                      onMapEvent: (evt) {
                        if (evt is MapEventMoveEnd || evt is MapEventRotateEnd || evt is MapEventZoomEnd) {
                          _onMapMoved();
                        }
                      },
                      onLongPress: (tapPos, point) {
                        setState(() => wps = [...wps, Coord(point.longitude, point.latitude)]);
                        _saveState();
                      },
                    ),
                    children: [
                      s.data!, // VectorTileLayer
                      PolylineLayer(polylines: lines),
                      MarkerLayer(markers: poiMarkers),
                      MarkerLayer(
                        markers: wps
                            .map((w) => Marker(
                                  point: LatLng(w.lat, w.lon),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.place, color: Colors.red),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  _panel(ctx),
                ]);
              },
            ),
    );
  }

  Widget _noRegion(BuildContext c) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(tr('no_regions')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => Navigator.pushNamed(c, '/catalog'), child: Text(tr('download_region')))
        ]),
      );

  Widget _panel(BuildContext c) {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Card(
        color: Colors.white.withOpacity(.95),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ProfilePicker(value: profile, onChanged: (k) => setState(() => profile = k)),
              const SizedBox(height: 6),
              WaypointList(
                wps: wps,
                onChanged: (a) {
                  setState(() => wps = a);
                  _saveState();
                },
              ),
              const SizedBox(height: 6),
              PoiToggles(
                parks: showParks,
                fuel: showFuel,
                services: showServices,
                onParks: (v) {
                  setState(() => showParks = v);
                  _saveState();
                  _refreshPoisFromView();
                },
                onFuel: (v) {
                  setState(() => showFuel = v);
                  _saveState();
                  _refreshPoisFromView();
                },
                onServices: (v) {
                  setState(() => showServices = v);
                  _saveState();
                  _refreshPoisFromView();
                },
              ),
              const SizedBox(height: 6),
              Row(children: [
                DropdownButton(
                  value: style,
                  items: const [
                    DropdownMenuItem(value: 'day', child: Text('Nappal')),
                    DropdownMenuItem(value: 'night', child: Text('Éjjel')),
                  ],
                  onChanged: (v) {
                    setState(() => style = v as String);
                    _initTheme();
                    _saveState();
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton(
                  value: zoom,
                  items: const [
                    DropdownMenuItem(value: 'near', child: Text('Közeli')),
                    DropdownMenuItem(value: 'mid', child: Text('Közepes')),
                    DropdownMenuItem(value: 'far', child: Text('Távoli')),
                  ],
                  onChanged: (v) {
                    setState(() => zoom = v as String);
                    _saveState();
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _route, child: const Text('Útvonal')),
              ]),
              const SizedBox(height: 6),
              if (rr != null)
                Text(
                  ' ${(rr!.distanceKm).toStringAsFixed(1)} km • ${rr!.durationMin.toStringAsFixed(0)} min • ETA ${rr!.eta.toLocal().toString().substring(11, 16)} ',
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
