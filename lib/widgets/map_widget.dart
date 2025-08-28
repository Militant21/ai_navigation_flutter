// Egy önálló térkép widget, ami .pmtiles-ből rajzol, EGYEDI (async) témával.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../theme/map_themes.dart';          // createDayTheme / createNightTheme
import '../services/tiles_provider.dart';   // pmtilesLayer()

class MyMapWidget extends StatefulWidget {
  /// A PMTiles fájl, amit meg kell jeleníteni
  final File pmtilesFile;

  /// true = éjszakai, false = nappali téma
  final bool night;

  /// Kezdő nézet (opcionális)
  final LatLng initialCenter;
  final double initialZoom;

  const MyMapWidget({
    super.key,
    required this.pmtilesFile,
    this.night = false,
    this.initialCenter = const LatLng(47.4979, 19.0402), // Budapest
    this.initialZoom = 10,
  });

  @override
  State<MyMapWidget> createState() => _MyMapWidgetState();
}

class _MyMapWidgetState extends State<MyMapWidget> {
  Future<VectorTileLayer?>? _layerFuture;

  @override
  void initState() {
    super.initState();
    _layerFuture = _loadLayer();
  }

  /// Betölti az EGYEDI (async) témát és a PMTiles réteget.
  /// Hiba esetén null-t ad, amit a FutureBuilder lekezel.
  Future<VectorTileLayer?> _loadLayer() async {
    try {
      final vtr.Theme theme = widget.night
          ? await createNightTheme()
          : await createDayTheme();

      return await pmtilesLayer(widget.pmtilesFile, theme: theme);
    } catch (e) {
      // fejlesztői log
      debugPrint('Térképréteg betöltési hiba: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VectorTileLayer?>(
      future: _layerFuture,
      builder: (context, snap) {
        // 1) Betöltés alatt
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2) Hiba vagy nincs réteg
        if (snap.hasError || !snap.hasData || snap.data == null) {
          return Center(
            child: Text(
              'Hiba történt 😕\nA térképréteg nem tölthető be.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        // 3) Minden oké — kirakjuk a térképet
        final layer = snap.data!;
        return FlutterMap(
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
          ),
          children: [
            layer, // a vektor csempe-réteg
          ],
        );
      },
    );
  }
}
