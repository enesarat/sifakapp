import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart'; // Medication domain TimeOfDay içeriyor
import '../../domain/entities/medication.dart';
import 'auto_time_util.dart';

List<int> _resolveTimesMinutes(Medication med) {
  if (med.timeScheduleMode == ScheduleMode.manual && med.reminderTimes != null) {
    return med.reminderTimes!
        .map((t) => t.hour * 60 + t.minute)
        .toList()
      ..sort();
  }
  return autoDistributeTimes(med.dailyDosage)..sort();
}

String buildMedicationSignature(Medication med) {
  // Günler sıralı ve null-safe
  final days = med.isEveryDay
      ? <int>[]
      : (med.usageDays == null ? <int>[] : (List<int>.from(med.usageDays!)..sort()));

  final times = _resolveTimesMinutes(med);

  // Kanonik bir map -> json -> md5
  final payload = <String, dynamic>{
    'startDate': med.startDate.toUtc().toIso8601String(),
    'endDate': med.endDate?.toUtc().toIso8601String(),
    'isEveryDay': med.isEveryDay,
    'usageDays': days, // sıralı
    'dailyDosage': med.dailyDosage,
    'timeScheduleMode': med.timeScheduleMode.name,
    'dayScheduleMode': med.dayScheduleMode.name,
    'times': times, // dakikalar
    // İsteğe bağlı: yemek ilişkisi planı etkileyebilir
    'isAfterMeal': med.isAfterMeal,
    'hoursBeforeOrAfterMeal': med.hoursBeforeOrAfterMeal,
  };

  final jsonStr = jsonEncode(payload);
  final digest = md5.convert(utf8.encode(jsonStr)).toString();
  return digest;
}
