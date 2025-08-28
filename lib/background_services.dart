// lib/background_services.dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Közös noti-plugin (egy példány)
final FlutterLocalNotificationsPlugin _flnp = FlutterLocalNotificationsPlugin();

/// Lokális értesítések inicializálása + Android csatorna létrehozása
Future<void> initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const init = InitializationSettings(android: androidInit);
  await _flnp.initialize(init);

  const channel = AndroidNotificationChannel(
    'bg_channel',
    'Background Service',
    description: 'Persistent notification for background tasks',
    importance: Importance.low,
  );

  final android =
      _flnp.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(channel);
}

/// BACKGROUND entrypoint – kötelező a @pragma
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Ne használjunk DartPluginRegistrant-et – újabb Flutter alatt nincs rá szükség
  WidgetsFlutterBinding.ensureInitialized();

  // Foreground mód Androidon (állandó értesítés)
  if (service is AndroidServiceInstance) {
    await service.setAsForegroundService();

    await _flnp.show(
      1000,
      'AI Nav fut',
      'Háttérszolgáltatás aktív',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bg_channel',
          'Background Service',
          ongoing: true,
          priority: Priority.low,
          importance: Importance.low,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // Stop parancs kezelése (ha majd a UI-ból küldöd)
  service.on('stopService').listen((_) async {
    if (service is AndroidServiceInstance) {
      await service.setAsBackgroundService();
    }
    await service.stopSelf();
  });

  // Engedélykérés minta (UI-ból érdemes kezelni élesben)
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    perm = await Geolocator.requestPermission();
  }

  // Időzített példa: 30 mp-enként pozíció lekérdezés + értesítés frissítés
  Timer.periodic(const Duration(seconds: 30), (_) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _flnp.show(
        1000,
        'Háttér fut',
        'Lat: ${pos.latitude.toStringAsFixed(5)}, '
        'Lon: ${pos.longitude.toStringAsFixed(5)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'bg_channel',
            'Background Service',
            ongoing: true,
            priority: Priority.low,
            importance: Importance.low,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );

      // TODO: itt küldheted a pozíciót szerverre / DB-be
    } catch (_) {
      // TODO: retry / log ha kell
    }
  });
}

/// Szolgáltatás konfigurálása + indítása (Android+iOS)
Future<void> startBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'bg_channel',
      initialNotificationTitle: 'AI Nav',
      initialNotificationContent: 'Szolgáltatás indul…',
      foregroundServiceNotificationId: 999,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (_) async => true,
    ),
  );

  await service.startService();
}

/// Opcionális: leállítás (pl. UI gombhoz)
Future<void> stopBackgroundService() async {
  final service = FlutterBackgroundService();
  service.invoke('stopService');
}
