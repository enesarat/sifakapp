import 'package:flutter/material.dart';

class Validator {
  // Medication name validation
  static String? validateMedicationName(String? value) {
    if (value == null || value.isEmpty) return 'İlaç adı boş olamaz!';
    return null;
  }

  // Diagnosis is optional
  static String? validateDiagnosis(String? value) {
    if (value == null) return null;
    if (value.trim().isEmpty) return null;
    return null;
  }

  // Total pills validation
  static String? validatePills(String? value) {
    if (value == null || value.isEmpty) return 'Miktar boş olamaz!';
    final pills = int.tryParse(value);
    if (pills == null || pills <= 0) return 'Geçerli bir sayı giriniz!';
    return null;
  }

  // Daily dosage validation: 1..5
  static String? validateDailyDosage(int dosage) {
    if (dosage < 1 || dosage > 5) {
      return 'Günlük doz 1 ile 5 arasında olmalıdır!';
    }
    return null;
  }

  // Manual time validation
  static String? validateManualTime(
    List<TimeOfDay> manualTimes,
    int dailyDosage,
    bool isManualSchedule,
  ) {
    if (!isManualSchedule) return null;

    if (manualTimes.isEmpty) {
      return 'Zamanlar boş olamaz! Lütfen en az bir zaman girin.';
    }
    if (manualTimes.length < dailyDosage) {
      return 'Tüm zamanları girmeniz gerekiyor!';
    }
    return null;
  }

  /// Gün seçimi validasyonu
  /// isEveryDay: her gün mü?
  /// isManualDayMode: gün planı manuel mi? (ScheduleMode.manual)
  /// selectedDays: seçilen günler (1=Pts .. 7=Paz)
  /// autoDaysPerWeek: otomatik mod için haftalık gün sayısı (1..6)
  /// expectedManualDaysCount: manuel modda tam şu kadar gün seçilmesini zorunlu kıl
    static String? validateUsageDays({
    required bool isEveryDay,
    required bool isManualDayMode,
    required List<int> selectedDays,
    int? autoDaysPerWeek,
  }) {
    if (isEveryDay) return null;

    if (isManualDayMode) {
      if (selectedDays.isEmpty) {
      return 'Lütfen en az bir gün seçin.';
      }
      if (selectedDays.any((d) => d < 1 || d > 7)) {
      return 'Günler 1–7 arasında olmalı (1=Pzt … 7=Paz).';
      }
      if (selectedDays.toSet().length != selectedDays.length) {
      return 'Günler tekrarlanmamalı.';
      }
      return null;
    } else {
      final count = autoDaysPerWeek ?? 0;
      if (count < 1 || count > 6) {
      return 'Haftalık gün sayısını 1–6 arasında seçin.';
      }
      return null;
    }
  }
}
