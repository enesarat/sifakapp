import 'package:flutter/material.dart';

class Validator {
  // İlaç adı validasyonu: Boş olamaz
  static String? validateMedicationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'İlaç adı boş olamaz!';
    }
    return null;
  }

  // Tanı validasyonu: Boş olamaz
  static String? validateDiagnosis(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanı boş olamaz!';
    }
    return null;
  }

  // Hap sayısı validasyonu: Sayısal ve boş olamaz
  static String? validatePills(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hap sayısı boş olamaz!';
    }
    final pills = int.tryParse(value);
    if (pills == null || pills <= 0) {
      return 'Geçerli bir sayı giriniz!';
    }
    return null;
  }

  // Manuel zaman girilmesi validasyonu
  static String? validateManualTime(List<TimeOfDay> manualTimes, int dailyDosage, bool isManualSchedule) {

    // Eğer manuel zaman eksikse, hata mesajı döndür
    if (manualTimes.isEmpty && isManualSchedule) {
      return 'Zamanlar boş olamaz! Lütfen en az bir zaman girin.';
    }

    // Eğer manuel zaman sayısı, günlük doz sayısından azsa, hata döndür
    if (manualTimes.length < dailyDosage && isManualSchedule) {
      return "Tüm zamanları girmeniz gerekiyor!";
    }

    return null;
  }


  // Günlük doz validasyonu: 1 ile 5 arasında olmalı
  static String? validateDailyDosage(int dosage) {
    if (dosage < 1 || dosage > 5) {
      return 'Günlük doz 1 ile 5 arasında olmalı!';
    }
    return null;
  }

  // Manuel zaman girilmesi ve tüm zamanların doldurulması gerektiği validasyonu
  static String? validateAllTimes(List<TimeOfDay> manualTimes, bool isManualSchedule, int dailyDosage) {
    if (isManualSchedule && manualTimes.length < dailyDosage) {
      return "Tüm manuel zamanları girmeniz gerekiyor!";
    }
    return null;
  }
}
