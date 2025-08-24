import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../application/notifications/notification_scheduler.dart';

class FlutterLocalNotificationsScheduler implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin;

  const FlutterLocalNotificationsScheduler(this._plugin);

  AndroidNotificationDetails get _androidDetails => const AndroidNotificationDetails(
        'med_reminders',
        'Medication Reminders',
        channelDescription: 'İlaç saatleri için bildirim kanalı',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.reminder,
      );

  DarwinNotificationDetails get _iosDetails => const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      );

  NotificationDetails get _details => NotificationDetails(
        android: _androidDetails,
        iOS: _iosDetails,
      );

  @override
  Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    // Android 13+ (SDK 33) bildirim izni
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
    // Android <13 için ayrı bir runtime izin yok; manifest yeterli.
  } else if (Platform.isIOS || Platform.isMacOS) {
    // Darwin/iOS izinleri
    // await _plugin
    //     .resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>()
    //     ?.requestPermissions(alert: true, sound: true, badge: false);

    // Eğer pakette Darwin yoksa:
    await _plugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, sound: true, badge: false);
  }
}

  @override
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payloadJson,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payloadJson,
    );
  }

  @override
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday, // 1..7
    required int hour,
    required int minute,
    String? payloadJson,
  }) async {
    final next = _nextInstanceOfWeekdayAndTime(weekday, hour, minute);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      next,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payloadJson,
    );
  }

  @override
  Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime atLocal,
    String? payloadJson,
  }) async {
    final when = tz.TZDateTime(tz.local, atLocal.year, atLocal.month, atLocal.day, atLocal.hour, atLocal.minute, atLocal.second);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) {
      return; // geçmişe kurma; istersen throw/skip
    }
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payloadJson,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  @override
  Future<void> cancelBatch(Iterable<int> ids) async {
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
      scheduled = tz.TZDateTime(tz.local, scheduled.year, scheduled.month, scheduled.day, hour, minute);
    }
    return scheduled;
  }
}
