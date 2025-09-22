import 'dart:io';
import 'package:flutter/services.dart';
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

      // OS tarafından uygulama bildirimleri kapalı olabilir (kanal/uygulama seviyesi)
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      try {
        final enabled = await android?.areNotificationsEnabled() ?? true;
        if (!enabled) {
          // Kullanıcıyı ayarlara yönlendirmek istersen:
          // await openAppSettings();
        }

        // Exact alarm yeteneği hakkında bilgi logla (varsa)
        try {
          final dynamic dyn = android;
          if (dyn != null && dyn.canScheduleExactAlarms is Function) {
            final bool canExact = await dyn.canScheduleExactAlarms();
          }
        } catch (_) {}
      } catch (_) {}

      // Exact alarm izni (Android 12+) OS ayarlarından verilir.
      // Planlama sırasında izin yoksa inexact moda düşmek için aşağıda kontrol var.
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS/macOS izinleri (geniş uyumluluk için IOSFlutterLocalNotificationsPlugin)
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

    await _zonedScheduleWithFallback(
      id: id,
      title: title,
      body: body,
      when: scheduled,
      payloadJson: payloadJson,
      matchComponents: DateTimeComponents.time,
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
    await _zonedScheduleWithFallback(
      id: id,
      title: title,
      body: body,
      when: next,
      payloadJson: payloadJson,
      matchComponents: DateTimeComponents.dayOfWeekAndTime,
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
    await _zonedScheduleWithFallback(
      id: id,
      title: title,
      body: body,
      when: when,
      payloadJson: payloadJson,
    );
  }

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payloadJson,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      _details,
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

  @override
  Future<List<PendingNotification>> listPending() async {
    final reqs = await _plugin.pendingNotificationRequests();
    return reqs
        .map((r) => PendingNotification(
              id: r.id,
              title: r.title,
              body: r.body,
              payloadJson: r.payload,
            ))
        .toList();
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

  Future<void> _zonedScheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    String? payloadJson,
    DateTimeComponents? matchComponents,
  }) async {
    try {
      var scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        try {
          final dynamic dyn = android;
          if (dyn != null && dyn.canScheduleExactAlarms is Function) {
            final bool canExact = await dyn.canScheduleExactAlarms();
            if (!canExact) {
              scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
            }
          }
        } catch (_) {}
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponents,
        payload: payloadJson,
      );
    } on PlatformException catch (e) {
      final code = e.code.toString().toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      if (code.contains('exact') || msg.contains('exact')) {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          when,
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchComponents,
          payload: payloadJson,
        );
      } else {
        rethrow;
      }
    }
} 
}
