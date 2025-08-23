// lib/theme/classic_night.dart

import 'package:flutter/material.dart';                              // Color, stb.
import 'package:vector_tile_renderer/vector_tile_renderer.dart'
    as vtr;                                                          // Theme, Layers, ColorStyle
import 'package:vector_map_tiles/themes/protomaps.dart';             // ProtomapsThemes.dark()

vtr.Theme classicNightTheme() {
  // Alap sötét protomaps téma
  final base = ProtomapsThemes.dark();

  // Módosítások: háttér és pár réteg színezése
  return base.copyWith(
    background: const vtr.BackgroundLayer(color: Color(0xFF141414)),
    layers: base.layers.map((l) {
      // Autópályák (motorway) kiemelése
      if (l is vtr.LineLayer &&
          l.sourceLayer == 'roads' &&
          ((l.filter?.toString().contains('motorway')) ?? false)) {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(const Color(0xFFFF9A2A)),
          ),
        );
      }

      // Vízfelületek sötétítése
      if (l is vtr.FillLayer && l.sourceLayer == 'water') {
        return l.copyWith(
          paint: l.paint.copyWith(
            color: vtr.ColorStyle(const Color(0xFF0A2A43)),
          ),
        );
      }

      return l; // minden más változatlan
    }).toList(),
  );
}
