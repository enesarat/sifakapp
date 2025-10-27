// domain/entities/medication_plan.dart
import 'local_time.dart';

enum RepeatPattern { daily, weekly, none } // none = one-off

class DailySlot {
  final LocalTime time;
  final int notificationId; // cancel için şart
  const DailySlot({required this.time, required this.notificationId});
}

class WeeklySlot {
  final int weekday; // ISO-8601: 1=Mon..7=Sun
  final LocalTime time;
  final int notificationId;
  const WeeklySlot({
    required this.weekday,
    required this.time,
    required this.notificationId,
  }) : assert(weekday >= 1 && weekday <= 7);
}

class OneOffOccurrence {
  final DateTime scheduledAt; // local wall-clock (tz hesaplaması scheduler’da)
  final int notificationId;
  const OneOffOccurrence({
    required this.scheduledAt,
    required this.notificationId,
  });
}

class MedicationPlan {
  final String medicationId;
  /// Medication’daki plan alanlarından üretilen stabil imza (md5/sha1)
  final String signature;
  final RepeatPattern pattern;

  /// pattern == daily ise dolu
  final List<DailySlot> dailySlots;

  /// pattern == weekly ise dolu
  final List<WeeklySlot> weeklySlots;

  /// pattern == none (one-off) ise dolu
  final List<OneOffOccurrence> oneOffs;

  /// Rolling horizon için ileriye kurulduğu son tarih (opsiyonel)
  final DateTime? plannedThrough;

  /// Planı geçici kapama/pausa etmek için
  final bool isEnabled;

  // NOT: const değil; çünkü runtime assert kullanıyoruz.
  MedicationPlan({
    required this.medicationId,
    required this.signature,
    required this.pattern,
    List<DailySlot> dailySlots = const [],
    List<WeeklySlot> weeklySlots = const [],
    List<OneOffOccurrence> oneOffs = const [],
    this.plannedThrough,
    this.isEnabled = true,
  })  : dailySlots = List.unmodifiable(dailySlots),
        weeklySlots = List.unmodifiable(weeklySlots),
        oneOffs = List.unmodifiable(oneOffs) {
    // runtime validation (const ctor'da bu mümkün değil)
    final okDaily = pattern == RepeatPattern.daily &&
        dailySlots.isNotEmpty &&
        weeklySlots.isEmpty &&
        oneOffs.isEmpty;
    final okWeekly = pattern == RepeatPattern.weekly &&
        weeklySlots.isNotEmpty &&
        dailySlots.isEmpty &&
        oneOffs.isEmpty;
    // one-off horizon kullanımlarında boş liste dönebileceği için
    // RepeatPattern.none için boş oneOffs da kabul edilir.
    final okNone = pattern == RepeatPattern.none &&
        dailySlots.isEmpty &&
        weeklySlots.isEmpty;

    assert(okDaily || okWeekly || okNone,
        'Slots must match the repeat pattern');
  }

  int get totalScheduledCount =>
      dailySlots.length + weeklySlots.length + oneOffs.length;

  MedicationPlan copyWith({
    String? medicationId,
    String? signature,
    RepeatPattern? pattern,
    List<DailySlot>? dailySlots,
    List<WeeklySlot>? weeklySlots,
    List<OneOffOccurrence>? oneOffs,
    DateTime? plannedThrough,
    bool? isEnabled,
  }) {
    return MedicationPlan(
      medicationId: medicationId ?? this.medicationId,
      signature: signature ?? this.signature,
      pattern: pattern ?? this.pattern,
      dailySlots: dailySlots ?? this.dailySlots,
      weeklySlots: weeklySlots ?? this.weeklySlots,
      oneOffs: oneOffs ?? this.oneOffs,
      plannedThrough: plannedThrough ?? this.plannedThrough,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
