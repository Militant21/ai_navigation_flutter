import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/poi_controller.dart';

enum ParkingMode { onRoute, nearMe, nearDest }

class ParkingExplorerScreen extends StatefulWidget {
  final PoiController poi;
  final List<LatLng> routePoints;
  final LatLng? me;
  final LatLng? dest;

  const ParkingExplorerScreen({
    super.key,
    required this.poi,
    required this.routePoints,
    required this.me,
    required this.dest,
  });

  @override
  State<ParkingExplorerScreen> createState() => _ParkingExplorerScreenState();
}

class _ParkingExplorerScreenState extends State<ParkingExplorerScreen> {
  ParkingMode mode = ParkingMode.onRoute;
  List<PoiController.ParkingHit> hits = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    List<PoiController.ParkingHit> res = const [];
    switch (mode) {
      case ParkingMode.onRoute:
        res = await widget.poi.upcomingOnRoute(
          route: widget.routePoints,
          me: widget.me,
          lateralToleranceMeters: 60,
          aheadKmLimit: 150,
        );
        break;
      case ParkingMode.nearMe:
        if (widget.me != null) {
          res = await widget.poi.parksNearHits(center: widget.me!, radiusMeters: 21000, titlePrefix: 'tőlem');
        }
        break;
      case ParkingMode.nearDest:
        if (widget.dest != null) {
          res = await widget.poi.parksNearHits(center: widget.dest!, radiusMeters: 21000, titlePrefix: 'céltól');
        }
        break;
    }
    if (!mounted) return;
    setState(() => hits = res);
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (mode) {
      ParkingMode.onRoute => 'Parkolók előttem (150 km)',
      ParkingMode.nearMe => 'Parkolók körülöttem (21 km)',
      ParkingMode.nearDest => 'Parkolók a cél közelében (21 km)',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(spacing: 8, children: [
            ChoiceChip(
              label: const Text('Útvonalon'),
              selected: mode == ParkingMode.onRoute,
              onSelected: (_) => setState(() { mode = ParkingMode.onRoute; _refresh(); }),
            ),
            ChoiceChip(
              label: const Text('Körülöttem (21 km)'),
              selected: mode == ParkingMode.nearMe,
              onSelected: (_) => setState(() { mode = ParkingMode.nearMe; _refresh(); }),
            ),
            ChoiceChip(
              label: const Text('Cél közelében (21 km)'),
              selected: mode == ParkingMode.nearDest,
              onSelected: (_) => setState(() { mode = ParkingMode.nearDest; _refresh(); }),
            ),
          ]),
        ),
        Expanded(
          child: hits.isEmpty
              ? const Center(child: Text('Nincs találat.'))
              : ListView.separated(
                  itemCount: hits.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (c, i) {
                    final h = hits[i];
                    final distStr = mode == ParkingMode.nearDest
                        ? '${h.routeKmFromMe.toStringAsFixed(1)} km a céltól'
                        : '${h.routeKmFromMe.toStringAsFixed(1)} km tőlem';
                    final sub = mode == ParkingMode.onRoute ? 'Útvonal-szelvény: ${h.routeKmFromStart.toStringAsFixed(1)} km' : '';
                    return ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text(h.title),
                      subtitle: Text([distStr, sub].where((s) => s.isNotEmpty).join(' • ')),
                      onTap: () {
                        // itt később lehet „navigálj ide” funkciót adni
                      },
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
