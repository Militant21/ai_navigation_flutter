import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';

// Saját
import '../services/tiles_provider.dart';
import '../services/storage.dart';
import '../services/tts.dart';
import '../services/routing_engine.dart';
import '../models/route_models.dart';
import '../models/truck.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import '../theme/map_themes.dart';
import '../widgets/waypoint_list.dart';
import '../widgets/profile_picker.dart';
import '../widgets/poi_toggles.dart';

// ÚJ kontrollerek + marker
import '../controllers/location_controller.dart';
import '../controllers/region_locator.dart';
import '../controllers/poi_controller.dart';
import '../widgets/my_location_marker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState()=>_HomeState();
}

class _HomeState extends State<HomeScreen>{
  // Állapot
  vtr.Theme? _theme;
  File? _pmtiles;
  PoiController? _poiCtl;
  final mapCtrl = MapController();
  final loc = LocationController.instance;

  // UI állapot
  List<Coord> wps = const [Coord(19.040,47.497),Coord(19.260,47.530)];
  TruckProfile truck = TruckProfile();
  ProfileKind profile = ProfileKind.motorway;
  bool showCameras=false, showParks=true, showFuel=true, showServices=false;
  String style='day', zoom='mid';
  RouteResult? rr;
  List<Polyline> lines=[];
  List<Marker> poiMarkers=[];
  static const truckGreen = Color(0xFF1B6A58);

  @override
  void initState(){
    super.initState();
    _restoreState();
    _initTheme();
    _initLocation();
    _ensureStorageAndLoadRegion();
  }

  @override
  void dispose(){ loc.stop(); super.dispose(); }

  Future<void> _initLocation() async{
    await loc.start(); // stream indul
    loc.position.addListener(() {
      if (!mounted) return;
      if (loc.followMe && loc.position.value!=null){
        mapCtrl.move(
          LatLng(loc.position.value!.latitude, loc.position.value!.longitude),
          mapCtrl.camera.zoom);
      }
      setState((){}); // saját marker redraw
    });
  }

  Future<void> _ensureStorageAndLoadRegion() async{
    if (Platform.isAndroid){
      var s = await Permission.manageExternalStorage.status;
      if (s.isDenied) { s = await Permission.manageExternalStorage.request(); }
    }
    final region = await RegionLocator.instance.loadFirstRegion();
    if (!mounted) return;
    if (region!=null){
      setState((){ _pmtiles = region.pmtiles; _poiCtl = PoiController(region.pois); });
      await _refreshPois();
    }
  }

  Future<void> _restoreState() async{
    final s = await KV.get<Map>('state'); final set = await KV.get<Map>('settings');
    if (!mounted) return;
    setState((){
      style=s?['style']??'day'; zoom=s?['zoom']??'mid';
      showCameras=set?['speedCameras']??false; showParks=s?['parks']??true;
      showFuel=s?['fuel']??true; showServices=s?['svc']??false;
      wps=(s?['wps'] as List?)?.map((e)=>Coord((e[0] as num).toDouble(),(e[1] as num).toDouble())).toList()??wps;
    });
  }

  Future<void> _saveState() async{
    await KV.set('state',{
      'style':style,'zoom':zoom,'parks':showParks,'fuel':showFuel,'svc':showServices,
      'wps': wps.map((w)=>[w.lon,w.lat]).toList()
    });
  }

  Future<void> _initTheme() async{
    final t = style=='day' ? await createDayTheme() : await createNightTheme();
    if (!mounted) return; setState(()=>_theme=t);
  }

  Future<void> _refreshPois() async{
    if (_poiCtl==null) return;
    final markers = await _poiCtl!.markersForView(
      mapCtrl.camera,
      parks: showParks, fuel: showFuel, services: showServices, cameras: showCameras, style: style);
    if (!mounted) return; setState(()=>poiMarkers=markers);
  }

  Future<void> _route() async{
    try{
      final lang = switch(context.locale.languageCode){ 'hu'=>'hu-HU','de'=>'de-DE', _ => 'en-US'};
      final r = await RoutingEngine.route(wps, truck, RouteOptions(profile, lang));
      if (!mounted) return;
      setState((){
        rr=r;
        lines=[Polyline(points: r.line.map((e)=>LatLng(e[1],e[0])).toList(), strokeWidth:5, color:Colors.orange)];
      });
      // egyszerű TTS példa
      speak('Útvonal frissítve', 'hu-HU');
    }catch(e){ if(!mounted)return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Routing error: $e'))); }
  }

  @override
  Widget build(BuildContext context){
    final layerFut = (_pmtiles!=null && _theme!=null) ? pmtilesLayer(_pmtiles!, theme:_theme!) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Navigation'),
        actions: [
          IconButton(tooltip: tr('download_region'), icon: const Icon(Icons.cloud_download),
            onPressed: ()=>Navigator.pushNamed(context,'/catalog').then((_)=>_ensureStorageAndLoadRegion())),
          IconButton(tooltip: tr('settings'), icon: const Icon(Icons.settings),
            onPressed: ()=>Navigator.pushNamed(context,'/settings').then((_)=>_restoreState())),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: truckGreen,
        onPressed: (){ loc.followMe=true; loc.centerOnMap(mapCtrl); setState((){}); },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      body: (_pmtiles==null || _theme==null)
        ? _noRegion(context)
        : FutureBuilder(
          future: layerFut,
          builder: (c,s){
            if(!s.hasData) return const Center(child:CircularProgressIndicator());
            return Stack(children:[
              FlutterMap(
                mapController: mapCtrl,
                options: MapOptions(
                  center: LatLng(47.497, 19.040),
                  zoom: zoom=='near'?15: zoom=='mid'?13:11,
                  onMapEvent: (evt){
                    if (evt is MapEventTap || evt is MapEventLongPress) return;
                    // user mozgat → follow ki
                    if (evt.source==MapEventSource.dragStart || evt.source==MapEventSource.multiFingerStart){
                      if (loc.followMe) { loc.followMe=false; setState((){}); }
                    }
                    _refreshPois();
                  },
                  onLongPress: (tapPos, p){
                    setState(()=> wps=[...wps, Coord(p.longitude, p.latitude)]); _saveState();
                  },
                ),
                children: [
                  s.data as Widget,
                  PolylineLayer(polylines: lines),
                  // zöld saját hely
                  if (loc.position.value!=null)
                    MarkerLayer(markers: myLocationMarkers(
                      loc.position.value!.latitude, loc.position.value!.longitude, truckGreen)),
                  MarkerLayer(markers: poiMarkers),
                  MarkerLayer(markers: wps.map((w)=>Marker(
                    point: LatLng(w.lat,w.lon), width:40,height:40,
                    child: const Icon(Icons.place, color: Colors.red))).toList()),
                ],
              ),
              _panel(context),
            ]);
          }),
    );
  }

  Widget _noRegion(BuildContext c)=>Center(
    child: Column(mainAxisSize: MainAxisSize.min, children:[
      Text(tr('no_regions')),
      const SizedBox(height:8),
      ElevatedButton(onPressed:()=>Navigator.pushNamed(c,'/catalog'), child: Text(tr('download_region')))
    ]));

  Widget _panel(BuildContext c)=>Positioned(
    top:10,left:10,right:10,
    child: Card(color: Colors.white.withOpacity(.95),
      child: Padding(padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          ProfilePicker(value: profile, onChanged:(k)=>setState(()=>profile=k)),
          const SizedBox(height:6),
          WaypointList(wps:wps, onChanged:(a){ setState(()=>wps=a); _saveState(); }),
          const SizedBox(height:6),
          PoiToggles(
            parks:showParks, fuel:showFuel, services:showServices,
            onParks:(v){ setState(()=>showParks=v); _saveState(); _refreshPois(); },
            onFuel:(v){ setState(()=>showFuel=v); _saveState(); _refreshPois(); },
            onServices:(v){ setState(()=>showServices=v); _saveState(); _refreshPois(); },
          ),
          const SizedBox(height:6),
          Row(children:[
            DropdownButton(value:style, items:const [
              DropdownMenuItem(value:'day', child: Text('Nappal')),
              DropdownMenuItem(value:'night', child: Text('Éjjel')),
            ], onChanged:(v){ setState(()=>style=v as String); _initTheme(); _saveState(); }),
            const SizedBox(width:12),
            DropdownButton(value:zoom, items:const [
              DropdownMenuItem(value:'near', child: Text('Közeli')),
              DropdownMenuItem(value:'mid', child: Text('Közepes')),
              DropdownMenuItem(value:'far', child: Text('Távoli')),
            ], onChanged:(v){ setState(()=>zoom=v as String); _saveState(); }),
            const SizedBox(width:12),
            ElevatedButton(onPressed:_route, child: const Text('Útvonal')),
          ]),
          const SizedBox(height:6),
          if (rr!=null) Text('${(rr!.distanceKm).toStringAsFixed(1)} km • ${rr!.durationMin.toStringAsFixed(0)} min • ETA ${rr!.eta.toLocal().toString().substring(11,16)}'),
        ])))) );
}
