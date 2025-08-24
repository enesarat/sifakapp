import 'package:flutter/material.dart'; // Medication TimeOfDay için
import '../../domain/entities/medication.dart' as domain;
import '../../domain/entities/medication_plan.dart' as domain;
import '../../domain/entities/local_time.dart';

import 'auto_time_util.dart';
import 'signature_util.dart';
import 'notification_id_factory.dart';

class PlanBuilder {
  /// Sadece repeating (daily/weekly) üretir.
  static domain.MedicationPlan buildRepeating(domain.Medication med) {
    final signature = buildMedicationSignature(med);
    final timesMinutes = _resolveTimesMinutes(med); // aynı mantık, buraya kopyalamayalım
    // Yukarıdaki fonksiyonu dışarı aldık; reuse:
    // Ama signature_util.dart içindeki _resolveTimesMinutes private.
    // Bu dosyada yeniden yazalım:
    // (Yinelenmesin dersen _resolveTimesMinutes'i export edilebilir yapabilirsin.)

    final times = med.timeScheduleMode == domain.ScheduleMode.manual && med.reminderTimes != null
        ? med.reminderTimes!.map((t) => t.hour * 60 + t.minute).toList()
        : autoDistributeTimes(med.dailyDosage);
    times.sort();

    if (med.isEveryDay) {
      final dailySlots = times
          .map((m) => domain.DailySlot(
                time: LocalTime.fromMinutes(m),
                notificationId: dailyId(medId: med.id, minutesSinceMidnight: m),
              ))
          .toList();

      return domain.MedicationPlan(
        medicationId: med.id,
        signature: signature,
        pattern: domain.RepeatPattern.daily,
        dailySlots: dailySlots,
      );
    }

    // Haftalık (belirli günler)
    final days = (med.usageDays ?? const []).toList()..sort();
    assert(days.isNotEmpty, 'usageDays boş; isEveryDay=false iken gün listesi gerekli');

    final weeklySlots = <domain.WeeklySlot>[];
    for (final d in days) {
      for (final m in times) {
        weeklySlots.add(
          domain.WeeklySlot(
            weekday: d,
            time: LocalTime.fromMinutes(m),
            notificationId: weeklyId(
              medId: med.id,
              weekday: d,
              minutesSinceMidnight: m,
            ),
          ),
        );
      }
    }

    return domain.MedicationPlan(
      medicationId: med.id,
      signature: signature,
      pattern: domain.RepeatPattern.weekly,
      weeklySlots: weeklySlots,
    );
  }

  /// İstersen one-off horizon kur (ör. önümüzdeki 30 gün).
  static domain.MedicationPlan buildOneOffHorizon(
    domain.Medication med, {
    required DateTime from,
    required DateTime to, // horizon end
  }) {
    final signature = buildMedicationSignature(med);

    final times = med.timeScheduleMode == domain.ScheduleMode.manual && med.reminderTimes != null
        ? med.reminderTimes!.map((t) => t.hour * 60 + t.minute).toList()
        : autoDistributeTimes(med.dailyDosage);
    times.sort();

    final days = med.isEveryDay
        ? <int>[1, 2, 3, 4, 5, 6, 7]
        : (med.usageDays ?? const <int>[]);

    final oneOffs = <domain.OneOffOccurrence>[];

    DateTime cursor = DateTime(from.year, from.month, from.day);
    final end = to;
    while (!cursor.isAfter(end)) {
      final weekday = cursor.weekday;
      final inRange = !cursor.isBefore(DateTime(med.startDate.year, med.startDate.month, med.startDate.day));
      final isUsableDay = med.isEveryDay ? true : days.contains(weekday);

      if (inRange && isUsableDay && (med.endDate == null || !cursor.isAfter(med.endDate!))) {
        for (final mm in times) {
          final dt = DateTime(
            cursor.year, cursor.month, cursor.day, mm ~/ 60, mm % 60,
          );
          if (dt.isAfter(from)) {
            oneOffs.add(
              domain.OneOffOccurrence(
                scheduledAt: dt,
                notificationId: oneOffId(medId: med.id, at: dt),
              ),
            );
          }
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return domain.MedicationPlan(
      medicationId: med.id,
      signature: signature,
      pattern: domain.RepeatPattern.none,
      oneOffs: oneOffs,
      plannedThrough: to,
    );
  }
}

// Lokal kopya: minutes çözümleyici
List<int> _resolveTimesMinutes(domain.Medication med) {
  if (med.timeScheduleMode == domain.ScheduleMode.manual && med.reminderTimes != null) {
    return med.reminderTimes!
        .map((t) => t.hour * 60 + t.minute)
        .toList()
      ..sort();
  }
  return autoDistributeTimes(med.dailyDosage)..sort();
}
