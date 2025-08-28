// lib/background_services.dart
import 'dart:async';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Közös noti-plugin
final FlutterLocalNotificationsPlugin _flnp = FlutterLocalNotificationsPlugin();

/// Lokális értesítések init + Android csatorna
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

  final android = _flnp
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await android?.createNotificationChannel(channel);
}

/// BACKGROUND entrypoint – kötelező a pragma!
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Szükséges, hogy a pluginok a background izolátban is elérhetők legyenek
  DartPluginRegistrant.ensureInitialized();

  // Foreground mód beállítása Androidon
  if (service is AndroidServiceInstance) {
    await service.setForegroundNotificationInfo(
      title: 'AI Nav fut',
      content: 'Háttérszolgáltatás aktív',
    );
  }

  // Stop parancs
  service.on('stopService').listen((_) async {
    if (service is AndroidServiceInstance) {
      await service.setAsBackgroundService();
    }
    await service.stopSelf();
  });

  // Egyszeri noti induláskor
  await _flnp.show(
    1000,
    'Háttér fut',
    'Helyadatok rögzítése…',
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

  // Engedélykérés minta (UI-ból érdemes kezelni)
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    perm = await Geolocator.requestPermission();
  }

  // Időzített példa: 30 mp-enként pozíció + noti frissítés
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

      // TODO: ide küldheted a pozíciót szerverre / adatbázisba

    } catch (_) {
      // TODO: retry / log, ha kell
    }
  });
}

/// Konfigurálás + indítás (Android+iOS)
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

/// Opcionális leállítás gombhoz
Future<void> stopBackgroundService() async {
  final service = FlutterBackgroundService();
  service.invoke('stopService');
}
