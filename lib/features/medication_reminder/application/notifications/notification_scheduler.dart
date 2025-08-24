abstract class NotificationScheduler {
  Future<void> requestPermissions();

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payloadJson,
  });

  /// weekday: ISO-8601 (1=Mon..7=Sun)
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    String? payloadJson,
  });

  Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime atLocal, // local wall-clock
    String? payloadJson,
  });

  Future<void> cancel(int id);
  Future<void> cancelBatch(Iterable<int> ids);
}
