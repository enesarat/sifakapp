import 'dart:convert';
import '../notifications/notification_scheduler.dart';
import '../../domain/entities/medication_plan.dart';

class ScheduleFromPlan {
  final NotificationScheduler scheduler;
  ScheduleFromPlan(this.scheduler);

  Future<void> schedule(MedicationPlan plan) async {
    if (!plan.isEnabled) return;

    switch (plan.pattern) {
      case RepeatPattern.daily:
        for (final s in plan.dailySlots) {
          final payload = jsonEncode({
            'type': 'take_dose',
            'medId': plan.medicationId,
            'hour': s.time.hour,
            'minute': s.time.minute,
          });
          await scheduler.scheduleDaily(
            id: s.notificationId,
            title: 'İlaç zamanı',
            body: 'Planlanan doz: ${s.time.hhmm}',
            hour: s.time.hour,
            minute: s.time.minute,
            payloadJson: payload,
          );
        }
        break;

      case RepeatPattern.weekly:
        for (final s in plan.weeklySlots) {
          final payload = jsonEncode({
            'type': 'take_dose',
            'medId': plan.medicationId,
            'weekday': s.weekday,
            'hour': s.time.hour,
            'minute': s.time.minute,
          });
          await scheduler.scheduleWeekly(
            id: s.notificationId,
            title: 'İlaç zamanı',
            body: 'Planlanan doz: ${s.time.hhmm}',
            weekday: s.weekday,
            hour: s.time.hour,
            minute: s.time.minute,
            payloadJson: payload,
          );
        }
        break;

      case RepeatPattern.none:
        for (final o in plan.oneOffs) {
          final payload = jsonEncode({
            'type': 'take_dose',
            'medId': plan.medicationId,
            'at': o.scheduledAt.toIso8601String(),
          });
          await scheduler.scheduleOneOff(
            id: o.notificationId,
            title: 'İlaç zamanı',
            body: 'Planlanan doz',
            atLocal: o.scheduledAt,
            payloadJson: payload,
          );
        }
        break;
    }
  }

  Future<void> cancelAll(MedicationPlan plan) async {
    final ids = <int>[
      ...plan.dailySlots.map((e) => e.notificationId),
      ...plan.weeklySlots.map((e) => e.notificationId),
      ...plan.oneOffs.map((e) => e.notificationId),
    ];
    await scheduler.cancelBatch(ids);
  }
}
