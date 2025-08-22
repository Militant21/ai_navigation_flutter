import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class NavForeground {
  static Future<void> start() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'ai_nav_channel',
        channelName: 'AI Navigation',
        channelDescription: 'Futó navigáció',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        isSticky: true,
        iconData: const NotificationIconData(resourceName: 'ic_launcher'),
      ),
      iosNotificationOptions: const IOSNotificationOptions(showNotification: true),
      foregroundTaskOptions: const ForegroundTaskOptions(interval: 15000),
    );
    await FlutterForegroundTask.startService(
      notificationTitle: 'AI Navigation',
      notificationText: 'Navigáció folyamatban…',
    );
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}