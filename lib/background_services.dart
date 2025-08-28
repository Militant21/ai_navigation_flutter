import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as fl_services;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _flnp =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  fl_services.DartPluginRegistrant.ensureInitialized();

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

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

Future<void> initializeService() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'bg_channel',
    'Background Service',
    description: 'AI Nav háttérszolgáltatás értesítései',
    importance: Importance.low,
  );

  await _flnp
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'bg_channel',
      initialNotificationTitle: 'AI Nav',
      initialNotificationContent: 'Háttérben fut…',
    ),
    iosConfiguration: IosConfiguration(),
  );
}
