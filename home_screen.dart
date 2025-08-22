import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';

import '../services/tiles_provider.dart';
import '../services/storage.dart';
import '../services/tts.dart';
import '../services/routing_engine.dart';
import '../models/route_models.dart';
import '../models/truck.dart';
import '../theme/classic_day.dart';
import '../theme/classic_night.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  Theme? _theme; // map theme
  File? _pmtiles; File? _mbtiles;
  final mapCtrl = MapController();
  List<Coord> wps = const [Coord(19.040, 47.497), Coord(19.260, 47.530)];
  TruckProfile truck = TruckProfile();
  ProfileKind profile = ProfileKind.motorway;

  bool showCameras = false, showParks = true, showFuel = true, showServices = false;
  String style = 'day'; String zoom = 'mid';

  RouteResult? rr; List<Polyline> lines = [];

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
    if (mounted) {
      setState(() {
        style = s?['style'] ?? 'day';
        zoom = s?['zoom'] ?? 'mid';
        showCameras = set?['speedCameras'] ?? false; // settingsből
        showParks = s?['parks'] ?? true;
        showFuel = s?['fuel'] ?? true;
        showServices = s?['svc'] ?? false;
        wps = (s?['wps'] as List?)?.map((e) => Coord((e[0] as num)*1.0, (e[1] as num)*1.0)).toList() ?? wps;
      });
    }
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
    setState(() => _theme = style == 'day' ? classicDayTheme() : classicNightTheme());
  }

  Future<void> _loadRegionIfAny() async {
    final doc = await getApplicationDocumentsDirectory();
    final regionsDir = Directory('${doc.path}/regions');
    if (!await regionsDir.exists()) return;
    final subs = await regionsDir.list().toList();
    for (final e in subs) {
      final p = File('${e.path}/tiles.pmtiles');
      if (await p.exists()) {
        setState(() => _pmtiles = p);
        break;
      }
    }
  }

  Future<void> _route() async {
    try {
      final r = await RoutingEngine.route(
        wps,
        truck,
        RouteOptions(profile, context.locale.languageCode == 'hu' ? 'hu-HU' : context.locale.languageCode == 'de' ? 'de-DE' : 'en-US'),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Routing error: $e')));
      }
    }
  }

  void _scheduleCues(RouteResult r) {
    if (r.mans.isEmpty) return;
    final next = r.mans.first;
    final isMw = (next.roadClass ?? '').contains('motorway') || (next.roadClass ?? '').contains('trunk');
    final d1 = isMw ? 3000.0 : 2000.0; final d2 = isMw ? 500.0 : 300.0;
    speak(isMw ? 'Autópálya lehajtó ${d1 ~/ 1000} km múlva' : 'Lehajtó ${d1 ~/ 1000} km múlva', 'hu-HU');
    speak(isMw ? 'Lehajtó 500 méter múlva' : 'Lehajtó 300 méter múlva', 'hu-HU');
  }

  @override
  Widget build(BuildContext ctx) {
    final layerFut = _pmtiles != null ? pmtilesLayer(_pmtiles!, _theme!) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Navigation'),
        actions: [
          IconButton(
            tooltip: tr('download_region'),
            icon: const Icon(Icons.cloud_download),
            onPressed: () => Navigator.pushNamed(context, '/catalog'),
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
          : FutureBuilder(
              future: layerFut,
              builder: (c, s) {
                if (!s.hasData) return const Center(child: CircularProgressIndicator());
                return Stack(children: [
                  FlutterMap(
                    mapController: mapCtrl,
                    options: MapOptions(
                      center: LatLng(47.497, 19.040),
                      zoom: zoom == 'near' ? 15 : zoom == 'mid' ? 13 : 11,
                      onLongPress: (tapPosition, point) {
                        setState(() => wps = [...wps, Coord(point.longitude, point.latitude)]);
                        _saveState();
                      },
                    ),
                    children: [
                      s.data as Widget,
                      PolylineLayer(polylines: lines),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(tr('style.day') + '/' + tr('style.night')),
              const SizedBox(width: 6),
              DropdownButton(
                value: style,
                items: [
                  DropdownMenuItem(value: 'day', child: Text(tr('style.day'))),
                  DropdownMenuItem(value: 'night', child: Text(tr('style.night'))),
                ],
                onChanged: (v) {
                  setState(() => style = v as String);
                  _initTheme();
                  _saveState();
                },
              ),
              const SizedBox(width: 12),
              Text(tr('zoom.mid')),
              const SizedBox(width: 6),
              DropdownButton(
                value: zoom,
                items: [
                  DropdownMenuItem(value: 'near', child: Text(tr('zoom.near'))),
                  DropdownMenuItem(value: 'mid', child: Text(tr('zoom.mid'))),
                  DropdownMenuItem(value: 'far', child: Text(tr('zoom.far'))),
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
    );
  }
}