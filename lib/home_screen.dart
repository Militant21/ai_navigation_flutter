// lib/home_screen.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';

// --- MAP / VTR ---
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import '../services/tiles_provider.dart';
import '../services/map_theme_controller.dart';
import '../theme/classic_day.dart';
import '../theme/classic_night.dart';

// --- APP SERVICES / MODELS / WIDGETS ---
import '../services/storage.dart';
import '../services/tts.dart';
import '../services/routing_engine.dart';
import '../services/pois_db.dart';
import '../models/route_models.dart';
import '../models/truck.dart';
import '../widgets/waypoint_list.dart';
import '../widgets/profile_picker.dart';
import '../widgets/poi_toggles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  // --- THEME ---
  late final MapThemeController _themeCtrl;
  vtr.Theme? _theme; // <- vektoros térképtéma (NEM a Flutter Material Theme!)

  // --- MAP TILES / POI ---
  File? _pmtiles;
  File? _poisFile;         // POI adatbázis fájl
  PoisDB? _pois;           // megnyitott db

  final mapCtrl = MapController();

  // --- STATE ---
  List<Coord> wps = const [Coord(19.040, 47.497), Coord(19.260, 47.530)];
  TruckProfile truck = TruckProfile();
  ProfileKind profile = ProfileKind.motorway;

  bool showCameras = false, showParks = true, showFuel = true, showServices = false;
  String style = 'day'; // <- a te UI-d szerinti day/night
  String zoom = 'mid';

  RouteResult? rr;
  List<Polyline> lines = [];
  List<Marker> poiMarkers = [];

  @override
  void initState() {
    super.initState();

    // 1) Téma vezérlő – alap: System (telefon sötét módját követi), de UI-ból továbbra is day/night-ot állítasz
    _themeCtrl = MapThemeController(
      initial: const MapThemeSettings(
        mode: MapThemeMode.system,
        followSystem: true,
        darkFrom: DayTime(20, 0), // ha majd schedule módot választasz
        darkTo: DayTime(6, 0),
      ),
    );

    // ha a rendszer/schedule miatt váltani kell, kérjünk újrarajzolást
    _themeCtrl.addListener(() {
      setState(() {
        _theme = _themeCtrl.currentTheme;
      });
    });

    _loadState();
    _initTheme();           // <- a te day/night állapotodból beállítjuk a vtr.Theme-et
    _loadRegionIfAny();
  }

  @override
  void dispose() {
    _themeCtrl.removeListener((){});
    super.dispose();
  }

  // ==========================
  // ÁLLAPOT MENTÉS / TÖLTÉS
  // ==========================
  Future<void> _loadState() async {
    final s = await KV.get<Map>('state');
    final set = await KV.get<Map>('settings');
    if (!mounted) return;
    setState(() {
      style = s?['style'] ?? 'day';
      zoom = s?['zoom'] ?? 'mid';
      showCameras = set?['speedCameras'] ?? false; // settingsből
      showParks = s?['parks'] ?? true;
      showFuel = s?['fuel'] ?? true;
      showServices = s?['svc'] ?? false;
      wps = (s?['wps'] as List?)
              ?.map((e) => Coord((e[0] as num) * 1.0, (e[1] as num) * 1.0))
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
      'wps': wps.map((w) => [w.lon, w.lat]).toList()
    });
  }

  // ==========================
  // TÉMA (day/night -> vtr.Theme)
  // ==========================
  void _initTheme() {
    // A te day/night értékedet tiszteletben tartjuk:
    if (style == 'day') {
      _themeCtrl.setMode(MapThemeMode.fixedLight);
      setState(() => _theme = classicDayTheme());
    } else {
      _themeCtrl.setMode(MapThemeMode.fixedDark);
      setState(() => _theme = classicNightTheme());
    }
  }

  // ==========================
  // PMTILES / POI BETÖLTÉS
  // ==========================
  Future<void> _loadRegionIfAny() async {
    final doc = await getApplicationDocumentsDirectory();
    final regionsDir = Directory('${doc.path}/regions');
    if (!await regionsDir.exists()) return;

    // egyszerű stratégia: első található régió
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

    // ha van POI adat, töltsük be az aktuális nézethez
    if (mounted) _refreshPoisFromView();
  }

  // ==========================
  // ROUTING
  // ==========================
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
    final d1 = isMw ? 3000.0 : 2000.0;
    final d2 = isMw ? 500.0 : 300.0;
    speak(isMw ? 'Autópálya lehajtó ${(d1/1000).toStringAsFixed(0)} km múlva' : 'Lehajtó ${(d1/1000).toStringAsFixed(0)} km múlva', 'hu-HU');
    speak(isMw ? 'Lehajtó 500 méter múlva' : 'Lehajtó 300 méter múlva', 'hu-HU');
  }

  // ==========================
  // POI FRISSÍTÉS
  // ==========================
  void _onMapMoved(MapPosition pos) {
    _refreshPoisFromView();
  }

  Future<void> _refreshPoisFromView() async {
    if (_pois == null) return;
    final center = mapCtrl.camera.center;
    final zoomVal = mapCtrl.camera.zoom;
    // dur
