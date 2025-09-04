import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Saját szolgáltatások
import '../services/tiles_provider.dart';
import '../services/storage.dart';
import '../services/tts.dart';
import '../services/routing_engine.dart';
import '../services/pois_db.dart';

// Modellek
import '../models/route_models.dart';
import '../models/truck.dart';

// Térkép témák
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import '../theme/map_themes.dart';

// Widgetek
import '../widgets/waypoint_list.dart';
import '../widgets/profile_picker.dart';
import '../widgets/poi_toggles.dart';
import '../widgets/no_map_fallback.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  // Térkép állapot
  vtr.Theme? _theme;
  File? _pmtiles;
  File? _poisFile;
  PoisDB? _pois;
  
  // Kamera állapot mentéshez
  LatLng? _lastCenter;
  double? _lastZoom;
  double? _lastRotation;
  
  final mapCtrl = MapController();

  // Útvonaltervezés állapota
  List<Coord> wps = const [Coord(19.040, 47.497), Coord(19.260, 47.530)];
  TruckProfile truck = TruckProfile();
  ProfileKind profile = ProfileKind.motorway;
  String style = 'day';
  String zoom = 'mid';
  RouteResult? rr;
  List<Polyline> lines = [];
  List<Marker> poiMarkers = [];

  // POI láthatóság
  bool showCameras = false;
  bool showParks = true;
  bool showFuel = true;
  bool showServices = true;

  // Saját helyzet követés
  Position? _myPos;
  StreamSubscription<Position>? _posSub;
  bool _followMe = true;
  static const truckGreen = Color(0xFF1B6A58);
  
  // ## Életciklus metódusok
  
  @override
  void initState() {
    super.initState();
    // Indításkor engedélyt kérünk, majd betöltjük az adatokat
    _requestPermissionsAndLoad();
  }
  
  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  // ## Adatkezelés és Logika

  void _requestPermissionsAndLoad() async {
    // Tárhely engedély kérése
    var storageStatus = await Permission.storage.status;
    if (storageStatus.isDenied) {
      storageStatus = await Permission.storage.request();
    }

    if (storageStatus.isGranted) {
      // Ha megkaptuk az engedélyt, betöltünk mindent
      _loadState();
      _initTheme();
      _loadRegionFromMapsFolder();
      _initLocationV14();
    } else {
      // Kezelheted, ha a user nem ad engedélyt
      print("Nincs engedély a tárhely olvasásához!");
    }
  }

  Future<void> _loadRegionFromMapsFolder() async {
    final Directory? extDir = await getExternalStorageDirectory();
    if (extDir == null) {
      print("Hiba: Nem sikerült elérni a külső tárhelyet.");
      return;
    }

    // A 'Download' mappa melletti 'maps' mappát keressük
    final mapsPath = '${extDir.path}/../maps';
    final dir = Directory(mapsPath);
    
    if (!await dir.exists()) {
      print("A 'maps' mappa nem létezik itt: $mapsPath");
      return;
    }

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.pmtiles')) {
        final pmtilesFile = entity;
        final poisPath = pmtilesFile.path.replaceAll('.pmtiles', '.sqlite');
        final poisFile = File(poisPath);

        print("Talált térkép: ${pmtilesFile.path}");
        
        if (mounted) {
          setState(() {
            _pmtiles = pmtilesFile;
          });

          if (await poisFile.exists()) {
            print("Talált POI adatbázis: ${poisFile.path}");
            _poisFile = poisFile;
            _pois = await PoisDB.open(poisFile.path);
          } else {
            _poisFile = null;
            _pois = null;
          }
          
          _refreshPoisFromView();
          return; // Kilépünk, miután az elsőt betöltöttük
        }
      }
    }
    print("Nem található .pmtiles fájl a 'maps' mappában.");
  }

  Future<void> _loadState() async {
    final s = await KV.get<Map>('state');
    if (!mounted || s == null) return;
    setState(() {
      style = s['style'] ?? 'day';
      zoom = s['zoom'] ?? 'mid';
      showCameras = s['speedCameras'] ?? true;
      showParks = s['parks'] ?? true;
      showFuel = s['fuel'] ?? true;
      showServices = s['svc'] ?? true;
      wps = (s['wps'] as List?)?.map((e) => Coord(e[0] as num, e[1] as num)).toList() ?? wps;
    });
  }

  Future<void> _saveState() async {
    await KV.set('state', {
      'style': style,
      'zoom': zoom,
      'speedCameras': showCameras,
      'parks': showParks,
      'fuel': showFuel,
      'svc': showServices,
      'wps': wps.map((w) => [w.lon, w.lat]).toList()
    });
  }
  
  Future<void> _initTheme() async {
    final t = style == 'day' ? await createDayTheme() : await createNightTheme();
    if (!mounted) return;
    setState(() => _theme = t);
  }

  Future<void> _initLocationV14() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) return;

    try {
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (!mounted) return;
      setState(() => _myPos = p);
      if (_followMe) mapCtrl.move(LatLng(p.latitude, p.longitude), mapCtrl.camera.zoom);
    } catch (_) {}

    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream().listen((p) {
      if (mounted) {
        setState(() => _myPos = p);
        if (_followMe) mapCtrl.move(LatLng(p.latitude, p.longitude), mapCtrl.camera.zoom);
      }
    });
  }

  Future<void> _route() async {
    try {
      final lang = context.locale.languageCode == 'hu' ? 'hu-HU' : 'en-US';
      final r = await RoutingEngine.route(wps, truck, RouteOptions(profile, lang));
      if (!mounted) return;
      setState(() {
        rr = r;
        lines = [Polyline(points: r.line.map((e) => LatLng(e[1], e[0])).toList(), strokeWidth: 5, color: Colors.orange)];
      });
      scheduleCues(r);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Routing error: $e')));
    }
  }

  void scheduleCues(RouteResult r) {
    if (r.mans.isEmpty) return;
    final next = r.mans.first;
    final isMw = (next.roadClass ?? '').contains('motorway');
    final d1 = isMw ? 3000.0 : 2000.0;
    speak(isMw ? 'Autópálya lehajtó ${(d1 / 1000).toStringAsFixed(0)} km múlva' : 'Lehajtó ${(d1 / 1000).toStringAsFixed(0)} km múlva', 'hu-HU');
  }

  Future<void> _refreshPoisFromView() async {
    if (_pois == null) return;
    final center = mapCtrl.camera.center;
    final zoomVal = mapCtrl.camera.zoom;
    final span = math.max(0.02, 2.0 / math.pow(2.0, zoomVal - 8));
    final west = center.longitude - span;
    final east = center.longitude + span;
    final south = center.latitude - span;
    final north = center.latitude + span;
    List<Marker> markers = [];
    
    if (showParks) {
      final rows = await _pois!.inBBox(table: 'truck_parks', west: west, south: south, east: east, north: north, limit: 300);
      markers.addAll(rows.map((r) => _mk(r, Icons.local_parking)));
    }
    // ... (többi POI betöltése)
    
    if (!mounted) return;
    setState(() => poiMarkers = markers);
  }

  Marker _mk(Map<String, Object?> r, IconData icon) => Marker(
      point: LatLng((r['lat'] as num).toDouble(), (r['lon'] as num).toDouble()),
      width: 36, height: 36,
      child: Tooltip(
        message: '${r['name'] as String? ?? ''}\n${r['brand'] as String? ?? ''}',
        child: Icon(icon, size: 22, color: style == 'day' ? Colors.blueGrey : Colors.white),
      ),
  );

  // ## UI (Build metódus és segéd-widgetek)

  @override
  Widget build(BuildContext context) {
    if (_pmtiles == null || _theme == null) {
      return Scaffold(body: noRegion(context));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Navigation'),
        actions: [
          IconButton(
            tooltip: tr('download_region'),
            icon: const Icon(Icons.cloud_download),
            onPressed: () => Navigator.pushNamed(context, '/catalog').then((_) => _loadRegionFromMapsFolder()),
          ),
          IconButton(
            tooltip: tr('settings'),
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings').then((_) => _loadState()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: truckGreen,
        onPressed: () {
          setState(() => _followMe = true);
          if (_myPos != null) {
            mapCtrl.move(LatLng(_myPos!.latitude, _myPos!.longitude), mapCtrl.camera.zoom);
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapCtrl,
            options: MapOptions(
              initialCenter: LatLng(47.497, 19.040),
              initialZoom: zoom == 'near' ? 15 : zoom == 'mid' ? 13 : 11,
              onMapEvent: (evt) {
                if (evt.source != MapEventSource.multiFingerEnd && evt.source != MapEventSource.dragEnd) return;
                setState(() => _followMe = false); // User mozgatta a térképet
                _refreshPoisFromView();
              },
              onLongPress: (tapPos, point) {
                setState(() => wps = [...wps, Coord(point.longitude, point.latitude)]);
                _saveState();
              },
            ),
            children: [
              pmtilesLayer(_pmtiles!, _theme!),
              PolylineLayer(polylines: lines),
              
              if (_myPos != null)
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(_myPos!.latitude, _myPos!.longitude), width: 38, height: 38,
                    child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: truckGreen.withOpacity(0.20), border: Border.all(color: truckGreen.withOpacity(0.6), width: 2))),
                  ),
                  Marker(
                    point: LatLng(_myPos!.latitude, _myPos!.longitude), width: 14, height: 14,
                    child: Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: truckGreen)),
                  ),
                ]),
              
              MarkerLayer(markers: poiMarkers),
            ],
          ),
          _panel(context),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context) => Positioned(
    top: 10, left: 10, right: 10,
    child: Card(
      color: Colors.white.withOpacity(.95),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfilePicker(value: profile, onChanged: (p) => setState(() => profile = p)),
              const SizedBox(height: 6),
              WaypointList(wps: wps, onChanged: (a) { setState(() => wps = a); _saveState(); }),
              const SizedBox(height: 6),
              PoiToggles(
                parks: showParks, fuel: showFuel, services: showServices,
                onParks: (v) { setState(() => showParks = v); _saveState(); _refreshPoisFromView(); },
                onFuel: (v) { setState(() => showFuel = v); _saveState(); _refreshPoisFromView(); },
                onServices: (v) { setState(() => showServices = v); _saveState(); _refreshPoisFromView(); },
              ),
              const SizedBox(height: 6),
              Row(children: [
                DropdownButton(value: style, items: [ DropdownMenuItem(value: 'day', child: Text(tr('day'))), DropdownMenuItem(value: 'night', child: Text(tr('night')))], onChanged: (v) { setState(() => style = v as String); _initTheme(); _saveState(); }),
                const SizedBox(width: 12),
                DropdownButton(value: zoom, items: [DropdownMenuItem(value: 'near', child: Text(tr('near'))), DropdownMenuItem(value: 'mid', child: Text(tr('mid'))), DropdownMenuItem(value: 'far', child: Text(tr('far')))], onChanged: (v) { setState(() => zoom = v as String); _saveState(); }),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _route, child: Text(tr('route'))),
              ]),
              const SizedBox(height: 6),
              if (rr != null) Text('${(rr!.distanceKm).toStringAsFixed(1)} km · ${rr!.durationMin.toStringAsFixed(0)} min · ETA ${rr!.eta.toLocal().toString().substring(11, 16)}'),
            ],
          ),
        ),
      ),
    ),
  );
}
