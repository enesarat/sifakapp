import 'package:awesome_notifications/awesome_notifications.dart';
import '../../application/notifications/notification_scheduler.dart';

class AwesomeNotificationsScheduler implements NotificationScheduler {
  static const String _channelKey = 'med_reminders';

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: 'Medication Reminders',
          channelDescription: 'Medication reminder channel',
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          enableVibration: true,
          playSound: true,
        ),
      ],
      debug: false,
    );
  }

  @override
  Future<void> requestPermissions() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payloadJson,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title,
        body: body,
        payload: payloadJson == null ? null : {'data': payloadJson},
        category: NotificationCategory.Reminder,
      ),
    );
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
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title,
        body: body,
        payload: payloadJson == null ? null : {'data': payloadJson},
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        preciseAlarm: true,
      ),
    );
  }

  @override
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    String? payloadJson,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title,
        body: body,
        payload: payloadJson == null ? null : {'data': payloadJson},
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        weekday: weekday,
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        preciseAlarm: true,
      ),
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
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title,
        body: body,
        payload: payloadJson == null ? null : {'data': payloadJson},
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        year: atLocal.year,
        month: atLocal.month,
        day: atLocal.day,
        hour: atLocal.hour,
        minute: atLocal.minute,
        second: atLocal.second,
        millisecond: 0,
        repeats: false,
        preciseAlarm: true,
      ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  @override
  Future<void> cancelBatch(Iterable<int> ids) async {
    for (final id in ids) {
      await AwesomeNotifications().cancel(id);
    }
  }

  @override
  Future<List<PendingNotification>> listPending() async {
    final list = await AwesomeNotifications().listScheduledNotifications();
    return list
        .map((n) => PendingNotification(
              id: n.content?.id ?? 0,
              title: n.content?.title,
              body: n.content?.body,
              payloadJson: n.content?.payload?['data'],
            ))
        .toList();
  }
}
