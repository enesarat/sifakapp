import '../../domain/entities/local_time.dart' as domain;
import '../../domain/entities/medication_plan.dart' as domain;

import '../models/medication_plan_model.dart' as model;

class MedicationPlanMapper {
  // ---------------------------
  // Enum map
  // ---------------------------
  static model.RepeatPatternModel toModelRepeat(domain.RepeatPattern p) {
    switch (p) {
      case domain.RepeatPattern.daily:
        return model.RepeatPatternModel.daily;
      case domain.RepeatPattern.weekly:
        return model.RepeatPatternModel.weekly;
      case domain.RepeatPattern.none:
        return model.RepeatPatternModel.none;
    }
  }

  static domain.RepeatPattern toDomainRepeat(model.RepeatPatternModel p) {
    switch (p) {
      case model.RepeatPatternModel.daily:
        return domain.RepeatPattern.daily;
      case model.RepeatPatternModel.weekly:
        return domain.RepeatPattern.weekly;
      case model.RepeatPatternModel.none:
        return domain.RepeatPattern.none;
    }
  }

  // ---------------------------
  // LocalTime map
  // ---------------------------
  static model.LocalTimeModel toModelTime(domain.LocalTime t) =>
      model.LocalTimeModel(t.minutesSinceMidnight);

  static domain.LocalTime toDomainTime(model.LocalTimeModel t) =>
      domain.LocalTime.fromMinutes(t.minutesSinceMidnight);

  // ---------------------------
  // Slot maps
  // ---------------------------
  static model.DailySlotModel toModelDaily(domain.DailySlot s) =>
      model.DailySlotModel(
        time: toModelTime(s.time),
        notificationId: s.notificationId,
      );

  static domain.DailySlot toDomainDaily(model.DailySlotModel s) =>
      domain.DailySlot(
        time: toDomainTime(s.time),
        notificationId: s.notificationId,
      );

  static model.WeeklySlotModel toModelWeekly(domain.WeeklySlot s) =>
      model.WeeklySlotModel(
        weekday: s.weekday,
        time: toModelTime(s.time),
        notificationId: s.notificationId,
      );

  static domain.WeeklySlot toDomainWeekly(model.WeeklySlotModel s) =>
      domain.WeeklySlot(
        weekday: s.weekday,
        time: toDomainTime(s.time),
        notificationId: s.notificationId,
      );

  static model.OneOffOccurrenceModel toModelOneOff(domain.OneOffOccurrence o) =>
      model.OneOffOccurrenceModel(
        scheduledAt: o.scheduledAt,
        notificationId: o.notificationId,
      );

  static domain.OneOffOccurrence toDomainOneOff(model.OneOffOccurrenceModel o) =>
      domain.OneOffOccurrence(
        scheduledAt: o.scheduledAt,
        notificationId: o.notificationId,
      );

  // ---------------------------
  // MedicationPlan map
  // ---------------------------
  static model.MedicationPlanModel toModel(domain.MedicationPlan p) {
    switch (p.pattern) {
      case domain.RepeatPattern.daily:
        return model.MedicationPlanModel(
          medicationId: p.medicationId,
          signature: p.signature,
          pattern: toModelRepeat(p.pattern),
          dailySlots: p.dailySlots.map(toModelDaily).toList(),
          weeklySlots: const [],
          oneOffs: const [],
          plannedThrough: p.plannedThrough,
          isEnabled: p.isEnabled,
        );
      case domain.RepeatPattern.weekly:
        return model.MedicationPlanModel(
          medicationId: p.medicationId,
          signature: p.signature,
          pattern: toModelRepeat(p.pattern),
          dailySlots: const [],
          weeklySlots: p.weeklySlots.map(toModelWeekly).toList(),
          oneOffs: const [],
          plannedThrough: p.plannedThrough,
          isEnabled: p.isEnabled,
        );
      case domain.RepeatPattern.none:
        return model.MedicationPlanModel(
          medicationId: p.medicationId,
          signature: p.signature,
          pattern: toModelRepeat(p.pattern),
          dailySlots: const [],
          weeklySlots: const [],
          oneOffs: p.oneOffs.map(toModelOneOff).toList(),
          plannedThrough: p.plannedThrough,
          isEnabled: p.isEnabled,
        );
    }
  }

  static domain.MedicationPlan toDomain(model.MedicationPlanModel m) {
    final pattern = toDomainRepeat(m.pattern);
    switch (pattern) {
      case domain.RepeatPattern.daily:
        return domain.MedicationPlan(
          medicationId: m.medicationId,
          signature: m.signature,
          pattern: pattern,
          dailySlots: m.dailySlots.map(toDomainDaily).toList(),
          plannedThrough: m.plannedThrough,
          isEnabled: m.isEnabled,
        );
      case domain.RepeatPattern.weekly:
        return domain.MedicationPlan(
          medicationId: m.medicationId,
          signature: m.signature,
          pattern: pattern,
          weeklySlots: m.weeklySlots.map(toDomainWeekly).toList(),
          plannedThrough: m.plannedThrough,
          isEnabled: m.isEnabled,
        );
      case domain.RepeatPattern.none:
        return domain.MedicationPlan(
          medicationId: m.medicationId,
          signature: m.signature,
          pattern: pattern,
          oneOffs: m.oneOffs.map(toDomainOneOff).toList(),
          plannedThrough: m.plannedThrough,
          isEnabled: m.isEnabled,
        );
    }
  }
}
