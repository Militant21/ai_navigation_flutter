import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../services/storage.dart';
import '../services/tts.dart';
import '../services/routing_engine.dart';
import '../services/pois_db.dart';
import '../models/route_models.dart';
import '../models/truck.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import '../theme/map_themes.dart';

// ÚJ komponens
import '../map_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  // --- állapot ---
  final mapCtrl = MapController();
  vtr.Theme? _theme;
  File? _pmtiles;
  PoisDB? _pois;
  File? _poisFile;

  Position? _myPos;
  StreamSubscription<Position>? _posSub;
  bool _followMe = true;
  static const truckGreen = Color(0xFF1B6A58);

  // UI
  List<Coord> wps = const [Coord(19.040, 47.497), Coord(19.260, 47.530)];
  TruckProfile truck = TruckProfile();
  ProfileKind profile = ProfileKind.motorway;
  bool showCameras=false, showParks=true, showFuel=true, showServices=false;
  String style='day'; String zoom='mid';
  RouteResult? rr;
  List<Polyline> lines=[]; List<Marker> poiMarkers=[];

  @override
  void initState(){
    super.initState();
    _restoreState();
    _initTheme();
    _ensureStorageAndLoadRegion();
    _initLocation();
  }

  @override
  void dispose(){ _posSub?.cancel(); super.dispose(); }

  // ---- engedély + régió ----
  Future<void> _ensureStorageAndLoadRegion() async {
    if (Platform.isAndroid){
      var s = await Permission.manageExternalStorage.status;
      if (s.isDenied) s = await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }
    await _loadRegion();
  }

  Future<void> _loadRegion() async {
    // 1) /storage/emulated/0/maps
    Directory? dir;
    final primary = Directory('/storage/emulated/0/maps');
    if (await primary.exists()) dir = primary;
    // 2) <app>/files/regions
    if (dir == null) {
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final d = Directory('${ext.path}/regions');
        if (await d.exists()) dir = d;
      }
    }
    // 3) <docs>/regions
    if (dir == null) {
      final docs = await getApplicationDocumentsDirectory();
      final d = Directory('${docs.path}/regions');
      if (await d.exists()) dir = d;
    }
    if (dir == null) return;

    await for (final e in dir.list()){
      if (e is File && e.path.toLowerCase().endsWith('.pmtiles')) {
        final pm = e;
        final pf = File(e.path.replaceAll(RegExp(r'\.pmtiles$', caseSensitive:false), '.sqlite'));
        setState(()=>_pmtiles = pm);
        if (await pf.exists()){
          _poisFile = pf;
          _pois = await PoisDB.open(pf.path);
        } else {
          _pois = null; _poisFile = null;
        }
        await _refreshPois();
        return;
      }
    }
  }

  // ---- location, „Google Maps-szerű” követéssel ----
  Future<void> _initLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;

    try{
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      if (!mounted) return; setState(()=>_myPos = p);
      if (_followMe) mapCtrl.move(LatLng(p.latitude, p.longitude), mapCtrl.camera.zoom);
    }catch(_){}

    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream().listen((p){
      if (!mounted) return; setState(()=>_myPos = p);
      if (_followMe) mapCtrl.move(LatLng(p.latitude, p.longitude), mapCtrl.camera.zoom);
    });
  }

  // ---- állapot ----
  Future<void> _restoreState() async {
    final s = await KV.get<Map>('state');
    final set = await KV.get<Map>('settings');
    if (!mounted) return;
    setState((){
      style = s?['style'] ?? 'day';
      zoom  = s?['zoom']  ?? 'mid';
      showCameras = set?['speedCameras'] ?? false;
      showParks   = s?['parks'] ?? true;
      showFuel    = s?['fuel']  ?? true;
      showServices= s?['svc']   ?? false;
      wps = (s?['wps'] as List?)?.map((e)=>Coord((e[0] as num).toDouble(), (e[1] as num).toDouble())).toList() ?? wps;
    });
  }

  Future<void> _saveState() async {
    await KV.set('state',{
      'style':style, 'zoom':zoom,
      'parks':showParks, 'fuel':showFuel, 'svc':showServices,
      'wps': wps.map((w)=>[w.lon, w.lat]).toList(),
    });
  }

  Future<void> _initTheme() async {
    final t = style=='day' ? await createDayTheme() : await createNightTheme();
    if (!mounted) return; setState(()=>_theme = t);
  }

  // ---- útvonal ----
  Future<void> _route() async {
    try{
      final lang = switch(context.locale.languageCode){ 'hu'=>'hu-HU','de'=>'de-DE', _=>'en-US'};
      final r = await RoutingEngine.route(wps, truck, RouteOptions(profile, lang));
      if (!mounted) return;
      setState((){
        rr = r;
        lines = [Polyline(points: r.line.map((e)=>LatLng(e[1],e[0])).toList(), strokeWidth: 5, color: Colors.orange)];
      });
      speak('Útvonal frissítve', 'hu-HU');
    }catch(e){
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Routing error: $e')));
    }
  }

  // ---- POI ----
  Future<void> _refreshPois() async {
    if (_pois == null) return;
    final cam = mapCtrl.camera;
    final span = math.max(0.02, 2.0 / math.pow(2.0, (cam.zoom - 8)));
    final w = cam.center.longitude - span, e = cam.center.longitude + span;
    final s = cam.center.latitude - span,  n = cam.center.latitude + span;
    final m = <Marker>[];

    Future<void> add(String table, IconData icon) async {
      final rows = await _pois!.inBBox(table: table, west: w, south: s, east: e, north: n, limit: 300);
      m.addAll(rows.map((r)=>Marker(
        point: LatLng((r['lat'] as num).toDouble(), (r['lon'] as num).toDouble()),
        width:36, height:36,
        child: Tooltip(message:(r['name'] as String?) ?? (r['brand'] as String?) ?? '',
          child: Icon(icon, size:22, color: style=='day'?Colors.blueGrey:Colors.white)),
      )));
    }
    if (showParks)    await add('truck_parks', Icons.local_parking);
    if (showFuel)     await add('truck_fuel',  Icons.local_gas_station);
    if (showServices) await add('services',    Icons.build);
    if (showCameras)  await add('cameras',     Icons.camera_alt);

    if (!mounted) return; setState(()=>poiMarkers = m);
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Navigation'),
        actions: [
          IconButton(tooltip: tr('download_region'), icon: const Icon(Icons.cloud_download),
            onPressed: ()=>Navigator.pushNamed(context, '/catalog').then((_) => _loadRegion())),
          IconButton(tooltip: tr('settings'), icon: const Icon(Icons.settings),
            onPressed: ()=>Navigator.pushNamed(context, '/settings').then((_) => _restoreState())),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: truckGreen,
        onPressed: () {
          setState(()=>_followMe = true);
          if (_myPos != null) {
            mapCtrl.move(LatLng(_myPos!.latitude, _myPos!.longitude), mapCtrl.camera.zoom);
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      body: (_pmtiles == null || _theme == null)
        ? _noRegion(context)
        : Stack(children:[
            MapWidget(
              mapCtrl: mapCtrl,
              pmtiles: _pmtiles,
              theme: _theme,
              myLocation: _myPos==null ? null : LatLng(_myPos!.latitude, _myPos!.longitude),
              myColor: truckGreen,
              lines: lines,
              poiMarkers: poiMarkers,
              wps: wps,
              onCameraMoved: _refreshPois,
              onUserGesture: () { if (_followMe) setState(()=>_followMe=false); },
              onLongPress: (p) {
                setState(()=> wps=[...wps, Coord(p.longitude, p.latitude)]);
                _saveState();
              },
              zoomPreset: zoom,
              initialCenter: const LatLng(47.497, 19.040),
            ),
            _panel(context),
          ]),
    );
  }

  Widget _noRegion(BuildContext c) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children:[
      Text(tr('no_regions')),
      const SizedBox(height: 8),
      ElevatedButton(onPressed: ()=>Navigator.pushNamed(c,'/catalog'), child: Text(tr('download_region'))),
    ]),
  );

  Widget _panel(BuildContext c) => Positioned(
    top:10, left:10, right:10,
    child: Card(color: Colors.white.withOpacity(.95),
      child: Padding(padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            ProfilePicker(value: profile, onChanged:(k)=>setState(()=>profile=k)),
            const SizedBox(height:6),
            WaypointList(wps:wps, onChanged:(a){ setState(()=>wps=a); _saveState(); }),
            const SizedBox(height:6),
            Row(children:[
              DropdownButton(value: style, items: const [
                DropdownMenuItem(value:'day', child: Text('Nappal')),
                DropdownMenuItem(value:'night', child: Text('Éjjel')),
              ], onChanged:(v){ setState(()=>style=v as String); _initTheme(); _saveState(); }),
              const SizedBox(width:12),
              DropdownButton(value: zoom, items: const [
                DropdownMenuItem(value:'near', child: Text('Közeli')),
                DropdownMenuItem(value:'mid',  child: Text('Közepes')),
                DropdownMenuItem(value:'far',  child: Text('Távoli')),
              ], onChanged:(v){ setState(()=>zoom=v as String); _saveState(); }),
              const SizedBox(width:12),
              ElevatedButton(onPressed:_route, child: const Text('Útvonal')),
            ]),
            const SizedBox(height:6),
            SwitchListTile(title: const Text('Parkolók'), value: showParks, onChanged:(v){ setState(()=>showParks=v); _saveState(); _refreshPois(); }),
            SwitchListTile(title: const Text('Kutak'),     value: showFuel,  onChanged:(v){ setState(()=>showFuel=v);  _saveState(); _refreshPois(); }),
            SwitchListTile(title: const Text('Szervizek'), value: showServices, onChanged:(v){ setState(()=>showServices=v); _saveState(); _refreshPois(); }),
            SwitchListTile(title: const Text('Kamerák'),   value: showCameras, onChanged:(v){ setState(()=>showCameras=v); _saveState(); _refreshPois(); }),
            if (rr!=null) Text('${(rr!.distanceKm).toStringAsFixed(1)} km • ${rr!.durationMin.toStringAsFixed(0)} min • ETA ${rr!.eta.toLocal().toString().substring(11,16)}'),
          ]),
        ),
      ),
    ),
  );
}
