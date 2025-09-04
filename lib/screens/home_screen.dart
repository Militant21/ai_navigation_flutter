import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
// Saját szolgáltatások
import '../services/tiles_provider.dart';
import '../services/storage.dart';
import '../services/tts.dart';
import '../services/routing_engine.dart';
import '../services/pois_db.dart';
// Modelek
import '../models/route_models.dart';
import '../models/truck.dart';
// Map témák (vector_tile_renderer alapú Theme)
import '../theme/map_themes.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
// Widgetek
import '../widgets/waypoint_list.dart';
import '../widgets/profile_picker.dart';
import '../widgets/poi_toggles.dart';
import '../widgets/no_map_fallback.dart';

// POI pont-típus a .geojsonl-hez
class _PoiPoint {
  final double lon, lat;
  final String? name;
  final String kind; // 'truckpoi' | 'speedcam'
  const _PoiPoint(this.lon, this.lat, this.name, this.kind);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  // --- állapot ---
  vtr.Theme? _theme;               // vektor-csempe téma
  File? _pmtiles;                  // régió csempe-fájl
  File? _poisFile;                 // POI sqlite
  PoisDB? _pois;                   // megnyitott POI DB

  // GEOJSONL POI támogatás (ha nincs sqlite)
  final List<_PoiPoint> _poiCache = [];
  File? _poiTruckGeojsonl;         // ai_nav_maps/hu_truckpoi.geojsonl
  File? _poiSpeedcamsGeojsonl;     // ai_nav_maps/hu_speedcams.geojsonl

  // (a te állapotaid maradnak, csak példa – nálad már benne vannak)
  LatLng? _lastCenter;
  double? _lastZoom;
  double? _lastRotation;

  final mapCtrl = MapController();

  // ---------------- életciklus ----------------
  @override
  void initState() {
    super.initState();
    _loadState();
    _initTheme();
    _loadRegionIfAny();
  }

  // ----- állapot perzisztencia -----
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
      wps = (s?['wps'] as List?)
              ?.map((e) => Coord((e[0] as num).toDouble(), (e[1] as num).toDouble()))
              .toList() ??
          wps;
    });
  }

  Future<void> _saveState() async {
    await KV.set('state', {
      'style': style,
      'zoom': zoom,
      'parks': showParks,
      'fuel': showFuel,
      'svc': showServices,
      'wps': wps.map((w) => [w.lon, w.lat]).toList(),
    });
  }

  // ----- téma -----
  Future<void> _initTheme() async {
    final t = (style == 'day') ? await loadLightTheme() : await loadDarkTheme();
    if (!mounted) return;
    setState(() => _theme = t);
  }

  // ----- régió + POI betöltés -----
  Future<void> _loadRegionIfAny() async {
    // 1) Eredeti: app-dokumentumok /regions/.../tiles.pmtiles + pois.sqlite
    final doc = await getApplicationDocumentsDirectory();
    final regionsDir = Directory('${doc.path}/regions');
    if (await regionsDir.exists()) {
      for (final e in await regionsDir.list().toList()) {
        final p = File('${e.path}/tiles.pmtiles');
        final pois = File('${e.path}/pois.sqlite');
        if (await p.exists()) setState(() => _pmtiles = p);
        if (await pois.exists()) {
          _poisFile = pois;
          _pois = await PoisDB.open(pois.path);
        }
        if (_pmtiles != null) break;
      }
    }

    // 2) Bővítés: külső app-mappa (/Android/data/<pkg>/files/ai_nav_maps)
    // Ha eddig nem találtunk régiót, próbáljuk meg itt is.
    if (_pmtiles == null) {
      final ext = await getExternalStorageDirectory(); // .../Android/data/<pkg>/files
      if (ext != null) {
        final base = Directory('${ext.path}/ai_nav_maps');
        if (await base.exists()) {
          // első .pmtiles fájl kiválasztása
          final pm = base
              .listSync()
              .whereType<File>()
              .firstWhere((f) => f.path.toLowerCase().endsWith('.pmtiles'),
                  orElse: () => File(''));
          if (await pm.exists()) {
            setState(() => _pmtiles = pm);
          }
          // opcionális GEOJSONL rétegek
          final poi1 = File('${base.path}/hu_truckpoi.geojsonl');
          final poi2 = File('${base.path}/hu_speedcams.geojsonl');
          if (await poi1.exists()) _poiTruckGeojsonl = poi1;
          if (await poi2.exists()) _poiSpeedcamsGeojsonl = poi2;

          // Ha nincs sqlite, töltsük be a geojsonl-t cache-be
          if (_pois == null) {
            await _loadGeojsonlPois();
          }
        }
      }
    }

    if (mounted) _refreshPoisFromView();
  }

  // GEOJSONL beolvasó: soronként JSON (GeoJSON Feature vagy lon/lat)
  Future<void> _loadGeojsonlPois() async {
    _poiCache.clear();

    Future<void> readFile(File? f, String kind) async {
      if (f == null) return;
      if (!await f.exists()) return;
      final lines = await f.readAsLines();
      for (final ln in lines) {
        final s = ln.trim();
        if (s.isEmpty) continue;
        try {
          final m = jsonDecode(s) as Map<String, dynamic>;

          // 1) GeoJSON Feature (Point)
          if ((m['type'] == 'Feature') && m['geometry'] is Map) {
            final g = m['geometry'] as Map;
            if (g['type'] == 'Point' &&
                g['coordinates'] is List &&
                (g['coordinates'] as List).length >= 2) {
              final c = (g['coordinates'] as List);
              final lon = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              final name = (m['properties'] is Map)
                  ? (m['properties']['name']?.toString())
                  : null;
              _poiCache.add(_PoiPoint(lon, lat, name, kind));
              continue;
            }
          }

          // 2) Egyszerű {"lon":..,"lat":..,"name":..}
          final lon = (m['lon'] as num?)?.toDouble();
          final lat = (m['lat'] as num?)?.toDouble();
          if (lon != null && lat != null) {
            _poiCache.add(_PoiPoint(lon, lat, m['name']?.toString(), kind));
          }
        } catch (_) {
          // hibás sor: átugorjuk
        }
      }
    }

    await readFile(_poiTruckGeojsonl, 'truckpoi');
    await readFile(_poiSpeedcamsGeojsonl, 'speedcam');
  }

  // ----- POI frissítés (látható nézet alapján) -----
  Future<void> _refreshPoisFromView() async {
    final center = mapCtrl.camera.center;
    final zoomVal = mapCtrl.camera.zoom;
    final span = math.max(0.02, 2.0 / math.pow(2.0, (zoomVal - 8)));
    final west = center.longitude - span;
    final east = center.longitude + span;
    final south = center.latitude - span;
    final north = center.latitude + span;

    final markers = <Marker>[];

    if (_pois != null) {
      // EREDETI: sqlite-ból kérdezünk (meghagytam a táblaneveidet)
      if (showParks) {
        final rows = await _pois!.inBBox(
            table: 'truck_parks', west: west, south: south, east: east, north: north, limit: 300);
        markers.addAll(rows.map((r) => _mk(r, Icons.local_parking)));
      }
      if (showFuel) {
        final rows = await _pois!.inBBox(
            table: 'truck_fuel', west: west, south: south, east: east, north: north, limit: 300);
        markers.addAll(rows.map((r) => _mk(r, Icons.local_gas_station)));
      }
      if (showServices) {
        final rows = await _pois!.inBBox(
            table: 'services', west: west, south: south, east: east, north: north, limit: 300);
        markers.addAll(rows.map((r) => _mk(r, Icons.build)));
      }
      if (showCameras) {
        final rows = await _pois!.inBBox(
            table: 'cameras', west: west, south: south, east: east, north: north, limit: 300);
        markers.addAll(rows.map((r) => _mk(r, Icons.camera_alt)));
      }
    } else {
      // ÚJ: GeoJSONL cache-ből dolgozunk
      bool inBox(_PoiPoint p) =>
          p.lon >= west && p.lon <= east && p.lat >= south && p.lat <= north;

      IconData iconFor(_PoiPoint p) {
        if (p.kind == 'speedcam') return Icons.camera_alt;
        return Icons.place; // truckpoi default
      }

      for (final p in _poiCache) {
        if (!inBox(p)) continue;
        if (p.kind == 'speedcam' && !showCameras) continue;
        // (A parks/fuel/services kapcsolókat most nem bontjuk szét GeoJSONL-re – teszthez elég)
        markers.add(Marker(
          point: LatLng(p.lat, p.lon),
          width: 36,
          height: 36,
          child: Tooltip(
            message: p.name ?? '',
            child: Icon(iconFor(p),
                size: 22, color: style == 'day' ? Colors.blueGrey : Colors.white),
          ),
        ));
      }
    }

    if (!mounted) return;
    setState(() => poiMarkers = markers);
  }

  Marker _mk(Map<String, Object?> r, IconData icon) => Marker(
        point: LatLng((r['lat'] as num).toDouble(), (r['lon'] as num).toDouble()),
        width: 36,
        height: 36,
        child: Tooltip(
          message: (r['name']?.toString() ?? ''),
          child: Icon(icon, size: 22, color: style == 'day' ? Colors.blueGrey : Colors.white),
        ),
      );

  // ----- UI -----
  @override
  Widget build(BuildContext context) {
    final layerFut = (_pmtiles != null && _theme != null)
        ? pmtilesLayer(_pmtiles!, theme: _theme!)
        : null;

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
      body: (_pmtiles == null || _theme == null)
          ? _noRegion(context)
          : FutureBuilder(
              future: layerFut,
              builder: (c, s) {
                if (!s.hasData) return const Center(child: CircularProgressIndicator());
                return Stack(
                  children: [
                    FlutterMap(
                      mapController: mapCtrl,
                      options: MapOptions(
                        center: LatLng(47.497, 19.040),
                        zoom: zoom == 'near' ? 15 : zoom == 'mid' ? 13 : 11,
                        onMapEvent: (evt) {
                          // (a te meglévő onMapEvent logikád marad — itt csak szemléltetjük)
                          _refreshPoisFromView();
                        },
                      ),
                      children: [
                        s.data!,
                        if (poiMarkers.isNotEmpty)
                          MarkerLayer(markers: poiMarkers),
                      ],
                    ),
                    // ... (meglévő UI-jaid: waypoints, profile, toggles, stb.)
                  ],
                );
              },
            ),
      // ... (alsó paneljeid, gombjaid – eredeti kódod szerint)
    );
  }

  // fallback, ha nincs térkép
  Widget _noRegion(BuildContext ctx) => const NoMapFallback();
}
