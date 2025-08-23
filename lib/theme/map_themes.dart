import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import 'classic_day.dart';
import 'classic_night.dart';

/// Egységes típusnév a térkép témához.
typedef MapTheme = vtr.Theme;

/// Nappali téma
vtr.Theme dayTheme() => classicDayTheme();

/// Éjszakai téma
vtr.Theme nightTheme() => classicNightTheme();
