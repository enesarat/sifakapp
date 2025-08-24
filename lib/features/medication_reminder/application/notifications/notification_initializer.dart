// lib/features/medication_reminder/application/notifications/notification_initializer.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

typedef NotificationTapCallback = Future<void> Function(String? payload);

class NotificationInitializer {
  static Future<FlutterLocalNotificationsPlugin> initialize({
    NotificationTapCallback? onTap,
  }) async {
    // --- Timezone init ---
    tzdata.initializeTimeZones();

    String localTz = 'UTC';
    try {
      // Örn: "Europe/Istanbul"
      localTz = await FlutterTimezone.getLocalTimezone();
    } catch (_) {}
    try {
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // --- Plugin init ---
    final plugin = FlutterLocalNotificationsPlugin();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) async {
        await onTap?.call(resp.payload);
      },
      onDidReceiveBackgroundNotificationResponse: _notificationTapBg,
    );

    // --- Android 8+ kanal ---
    const channel = AndroidNotificationChannel(
      'med_reminders',
      'Medication Reminders',
      description: 'İlaç saatleri için bildirim kanalı',
      importance: Importance.max,
    );
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

    return plugin;
  }
}

// OPTIONAL: arka plan tık callback (Android 12L+)
@pragma('vm:entry-point')
Future<void> _notificationTapBg(NotificationResponse response) async {
  // payload işlemleri (minimum), app açıldığında detaylı yönlendirme
}
