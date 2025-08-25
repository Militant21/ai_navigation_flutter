import 'dart:io';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Előkészítés: értesítési csatorna + alap beállítás
Future<void> initForegroundTask() async {
  // Android 13+ POST_NOTIFICATIONS runtime engedélye
  if (Platform.isAndroid) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
  await FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'ai_nav_channel',
      channelName: 'AI Navigation',
      channelDescription: 'Background navigation & downloads',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      buttons: [ const NotificationButton(id: 'stop', text: 'Stop') ],
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher', // a launcher ikonból generál
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 15000, // 15s "heartbeat"
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

/// Indítás: megjelenik a status bar értesítés, a folyamat életben marad
Future<void> startForegroundService() async {
  await FlutterForegroundTask.startService(
    notificationTitle: 'AI Navigation',
    notificationText: 'Running in background…',
    callback: startCallback, // kötelező callback
  );
}

/// Leállítás
Future<void> stopForegroundService() async {
  await FlutterForegroundTask.stopService();
}

/// A plugin kötelező entry pontja háttér thread-hez
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_NavTaskHandler());
}

/// Itt fut a háttér "szívverés": pl. pozíció frissítés, letöltés monitorozás stb.
class _NavTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // TODO: ide jöhet élő helyzet lekérés, letöltés státusz, TTS előjelzések stb.
  }

  @override
  Future<void> onButtonPressed(String id) async {
    if (id == 'stop') {
      await FlutterForegroundTask.stopService();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {}
}
