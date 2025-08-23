import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import 'package:ai_navigation_flutter/theme/map_themes.dart'; 
// <- itt legyenek a light/dark theme gyárai, pl. lightMapTheme(), darkMapTheme()

/// Módok, ahogy a téma kiválasztható
enum MapThemeMode { system, schedule, fixedLight, fixedDark }

/// Egyszerű időpont (óra:perc)
class DayTime {
  final int hour;
  final int minute;
  const DayTime(this.hour, this.minute);

  /// percek 0..1439
  int get asMinutes => hour * 60 + minute;
}

/// Beállítások a váltáshoz
class MapThemeSettings {
  final MapThemeMode mode;
  final DayTime darkFrom; // ettől sötét
  final DayTime darkTo;   // eddig sötét
  final bool followSystem; // ha true és mode==system, akkor a telefon sötét módja dönt

  const MapThemeSettings({
    this.mode = MapThemeMode.system,
    this.darkFrom = const DayTime(20, 0), // 20:00
    this.darkTo   = const DayTime(6, 0),  // 06:00
    this.followSystem = true,
  });

  MapThemeSettings copyWith({
    MapThemeMode? mode,
    DayTime? darkFrom,
    DayTime? darkTo,
    bool? followSystem,
  }) =>
      MapThemeSettings(
        mode: mode ?? this.mode,
        darkFrom: darkFrom ?? this.darkFrom,
        darkTo: darkTo ?? this.darkTo,
        followSystem: followSystem ?? this.followSystem,
      );
}

/// A tényleges vezérlő, értesít ha váltani kell
class MapThemeController extends ChangeNotifier {
  MapThemeSettings _settings;
  Timer? _timer;

  MapThemeController({MapThemeSettings? initial})
      : _settings = initial ?? const MapThemeSettings() {
    _scheduleNextTick();
  }

  MapThemeSettings get settings => _settings;

  set settings(MapThemeSettings value) {
    _settings = value;
    _restartTimerAndNotify();
  }

  void setMode(MapThemeMode mode) {
    _settings = _settings.copyWith(mode: mode);
    _restartTimerAndNotify();
  }

  void setSchedule(DayTime from, DayTime to) {
    _settings = _settings.copyWith(darkFrom: from, darkTo: to);
    _restartTimerAndNotify();
  }

  /// Az aktuális vtr.Theme – ezt add át a pmtilesLayer-nek
  vtr.Theme get currentTheme =>
      _isDarkNow() ? darkMapTheme() : lightMapTheme();

  /// Megmondja, hogy most sötét-e (beállítások és idő alapján)
  bool _isDarkNow() {
    final now = DateTime.now();
    switch (_settings.mode) {
      case MapThemeMode.fixedLight:
        return false;
      case MapThemeMode.fixedDark:
        return true;
      case MapThemeMode.system:
        if (_settings.followSystem) {
          final brightness =
              SchedulerBinding.instance.platformDispatcher.platformBrightness;
          return brightness == Brightness.dark;
        }
        // ha followSystem=false, essen vissza a schedule logikára
        return _isInDarkRange(now);
      case MapThemeMode.schedule:
        return _isInDarkRange(now);
    }
  }

  bool _isInDarkRange(DateTime now) {
    final nowMin = now.hour * 60 + now.minute;
    final from = _settings.darkFrom.asMinutes;
    final to = _settings.darkTo.asMinutes;

    if (from == to) return false; // nincs sötét ablak
    if (from < to) {
      // pl. 20:00 -> 23:00 (nem ér át éjfélen)
      return nowMin >= from && nowMin < to;
    } else {
      // pl. 20:00 -> 06:00 (átér éjfélen)
      return nowMin >= from || nowMin < to;
    }
  }

  /// Következő váltás időpontját kiszámoljuk és odáig időzítünk
  void _scheduleNextTick() {
    _timer?.cancel();

    // perc elején újraszámolunk, plusz akkor is, amikor a következő határ közeleg
    final now = DateTime.now();
    final nextMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    var next = nextMinute;

    // ha ütemezést használunk, tegyük a következő határidőre az időzítőt
    if (_settings.mode == MapThemeMode.schedule || !_settings.followSystem) {
      final todayFrom =
          DateTime(now.year, now.month, now.day, _settings.darkFrom.hour, _settings.darkFrom.minute);
      final todayTo =
          DateTime(now.year, now.month, now.day, _settings.darkTo.hour, _settings.darkTo.minute);

      DateTime nextBoundary;
      if (now.isBefore(todayFrom)) {
        nextBoundary = todayFrom;
      } else if (now.isBefore(todayTo)) {
        nextBoundary = todayTo;
      } else {
        // holnapi from
        nextBoundary = todayFrom.add(const Duration(days: 1));
      }

      if (nextBoundary.isBefore(next)) {
        next = nextBoundary;
      }
    }

    final duration = next.difference(now);
    _timer = Timer(duration, () {
      notifyListeners();
      _scheduleNextTick();
    });
  }

  void _restartTimerAndNotify() {
    _scheduleNextTick();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
