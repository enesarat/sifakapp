import 'package:hive/hive.dart';

part 'medication_plan_model.g.dart';

/// Domain: RepeatPattern { daily, weekly, none }
@HiveType(typeId: 2)
enum RepeatPatternModel {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  none,
}

/// Domain VO: LocalTime (hour, minute) -> modelde minutesSinceMidnight
@HiveType(typeId: 3)
class LocalTimeModel {
  @HiveField(0)
  final int minutesSinceMidnight; // 0..1439

  const LocalTimeModel(this.minutesSinceMidnight)
      : assert(minutesSinceMidnight >= 0 && minutesSinceMidnight < 24 * 60);
}

/// Domain: DailySlot
@HiveType(typeId: 4)
class DailySlotModel {
  @HiveField(0)
  final LocalTimeModel time;

  @HiveField(1)
  final int notificationId;

  const DailySlotModel({
    required this.time,
    required this.notificationId,
  });
}

/// Domain: WeeklySlot
@HiveType(typeId: 5)
class WeeklySlotModel {
  @HiveField(0)
  final int weekday; // ISO-8601 (1=Mon..7=Sun)

  @HiveField(1)
  final LocalTimeModel time;

  @HiveField(2)
  final int notificationId;

  const WeeklySlotModel({
    required this.weekday,
    required this.time,
    required this.notificationId,
  });
}

/// Domain: OneOffOccurrence
@HiveType(typeId: 6)
class OneOffOccurrenceModel {
  @HiveField(0)
  final DateTime scheduledAt; // local wall-clock

  @HiveField(1)
  final int notificationId;

  const OneOffOccurrenceModel({
    required this.scheduledAt,
    required this.notificationId,
  });
}

/// Domain: MedicationPlan
@HiveType(typeId: 7)
class MedicationPlanModel extends HiveObject {
  @HiveField(0)
  final String medicationId;

  @HiveField(1)
  final String signature;

  @HiveField(2)
  final RepeatPatternModel pattern;

  @HiveField(3)
  final List<DailySlotModel> dailySlots;

  @HiveField(4)
  final List<WeeklySlotModel> weeklySlots;

  @HiveField(5)
  final List<OneOffOccurrenceModel> oneOffs;

  @HiveField(6)
  final DateTime? plannedThrough;

  @HiveField(7)
  final bool isEnabled;

  MedicationPlanModel({
    required this.medicationId,
    required this.signature,
    required this.pattern,
    List<DailySlotModel>? dailySlots,
    List<WeeklySlotModel>? weeklySlots,
    List<OneOffOccurrenceModel>? oneOffs,
    this.plannedThrough,
    this.isEnabled = true,
  })  : dailySlots = dailySlots ?? const [],
        weeklySlots = weeklySlots ?? const [],
        oneOffs = oneOffs ?? const [];
}
