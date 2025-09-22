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

  /// Test ve acil bildirimler için: hemen gösterir (zamanlamasız).
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payloadJson,
  });

  Future<void> cancel(int id);
  Future<void> cancelBatch(Iterable<int> ids);

  /// Debug/inspection: list currently scheduled local notifications
  Future<List<PendingNotification>> listPending();
}

class PendingNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payloadJson;

  const PendingNotification({
    required this.id,
    this.title,
    this.body,
    this.payloadJson,
  });
}
