// lib/background_service.dart
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service/android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/widgets.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const init = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(init);

  // Android csatorna – egyszer elég
  const androidChannel = AndroidNotificationChannel(
    'bg_channel',
    'Background Service',
    description: 'Persistent notification for background tasks',
    importance: Importance.low,
  );
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(androidChannel);
}

Future<void> initBackgroundService() async {
  await FlutterBackgroundService.initialize(_onStart);
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  // Kötelező V2: biztosítsuk, hogy a pluginek be legyenek regisztrálva
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    // Állandó értesítés – foreground módban
    service.setAsForegroundService();

    await flutterLocalNotificationsPlugin.show(
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
  }

  // Engedélyek (egyszerű minta – UI-ban is kérheted)
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    perm = await Geolocator.requestPermission();
  }

  // Stop parancs kezelése
  service.on('stop').listen((_) async {
    await flutterLocalNotificationsPlugin.cancel(1000);
    if (service is AndroidServiceInstance) {
      await service.setAsBackgroundService();
    }
    await service.stopSelf();
  });

  // Példa: 30 másodpercenként helylekérés + értesítés frissítés
  Timer.periodic(const Duration(seconds: 30), (_) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await flutterLocalNotificationsPlugin.show(
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

      // TODO: itt mentheted / küldheted a helyadatot ahová kell

    } catch (_) {
      // nyeld le – itt lehet retry/log
    }
  });
}
