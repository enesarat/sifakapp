import 'package:flutter/material.dart';

/// Planlama modu: otomatik/manuel (gün & saat için ayrı ayrı)
enum ScheduleMode { automatic, manual }

class Medication {
  // --- Kimlik & Temel ---
  final String id;
  final String name;
  final String diagnosis;
  /// Tablet, kapsül, şurup vb.
  final String type;

  // --- Tarihler ---
  /// Kullanımın planlanan başlangıç tarihi
  final DateTime startDate;

  /// Kullanımın planlanan bitiş tarihi (opsiyonel)
  final DateTime? endDate;

  /// İlacın kutu üstündeki SKT (opsiyonel)
  final DateTime? expirationDate;

  // --- Miktarlar ---
  /// Başlangıçtaki toplam adet
  final int totalPills;

  /// Güncel kalan adet (bildirim onayı ile azalır)
  final int remainingPills;

  /// Günde kaç kez alınacağı (örn. 3)
  final int dailyDosage;

  // --- Zamanlama Modları & Değerleri ---
  /// Saat planlaması: otomatik mi manuel mi?
  final ScheduleMode timeScheduleMode;

  /// Gün planlaması: otomatik mi manuel mi?
  final ScheduleMode dayScheduleMode;

  /// Manuel saat seçimi yapıldıysa: HH:mm formatında TimeOfDay listesi
  final List<TimeOfDay>? reminderTimes;

  /// Her gün mü kullanılıyor? true ise usageDays yok sayılır
  final bool isEveryDay;

  /// Belirli günlerde kullanım: 1=Mon, 2=Tue, ..., 7=Sun (ISO-8601)
  /// (isEveryDay=false ve dayScheduleMode=manual ise zorunlu)
  final List<int>? usageDays;

  // --- Yemek ilişkisi (opsiyonel) ---
  /// Yemekten önce/sonra kaç saat?
  final int? hoursBeforeOrAfterMeal;

  /// true: yemekten sonra, false: yemekten önce, null: önemsiz
  final bool? isAfterMeal;

  Medication({
    // Kimlik & temel
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.type,

    // Tarihler
    required this.startDate,
    this.endDate,
    this.expirationDate,

    // Miktarlar
    required this.totalPills,
    required this.remainingPills,
    required this.dailyDosage,

    // Planlama
    required this.timeScheduleMode,
    required this.dayScheduleMode,
    this.reminderTimes,
    required this.isEveryDay,
    this.usageDays,

    // Yemek ilişkisi
    this.hoursBeforeOrAfterMeal,
    this.isAfterMeal,
  }) : assert(dailyDosage > 0, 'dailyDosage must be > 0');

  // -------------------------
  // Helpers
  // -------------------------

  /// Planlanan tarih aralığına göre bitmiş mi?
  bool get isFinishedByDate => endDate != null && DateTime.now().isAfter(endDate!);

  /// Stok bitti mi?
  bool get isOutOfStock => remainingPills <= 0;

  /// Verilen tarihte alınması gerekiyor mu?
  /// isEveryDay=true ise her gün; değilse usageDays kontrol edilir.
  bool shouldTakeOn(DateTime date) {
    if (isEveryDay) return true;
    if (usageDays == null || usageDays!.isEmpty) return false;
    final weekday = date.weekday; // 1..7 (Mon..Sun)
    return usageDays!.contains(weekday);
  }

  /// Immutable kullanım için copyWith
  Medication copyWith({
    String? id,
    String? name,
    String? diagnosis,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? expirationDate,
    int? totalPills,
    int? remainingPills,
    int? dailyDosage,
    ScheduleMode? timeScheduleMode,
    ScheduleMode? dayScheduleMode,
    List<TimeOfDay>? reminderTimes,
    bool? isEveryDay,
    List<int>? usageDays,
    int? hoursBeforeOrAfterMeal,
    bool? isAfterMeal,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      diagnosis: diagnosis ?? this.diagnosis,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      expirationDate: expirationDate ?? this.expirationDate,
      totalPills: totalPills ?? this.totalPills,
      remainingPills: remainingPills ?? this.remainingPills,
      dailyDosage: dailyDosage ?? this.dailyDosage,
      timeScheduleMode: timeScheduleMode ?? this.timeScheduleMode,
      dayScheduleMode: dayScheduleMode ?? this.dayScheduleMode,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isEveryDay: isEveryDay ?? this.isEveryDay,
      usageDays: usageDays ?? this.usageDays,
      hoursBeforeOrAfterMeal:
          hoursBeforeOrAfterMeal ?? this.hoursBeforeOrAfterMeal,
      isAfterMeal: isAfterMeal ?? this.isAfterMeal,
    );
  }
}
