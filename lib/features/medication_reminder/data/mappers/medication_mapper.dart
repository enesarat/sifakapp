import 'package:flutter/material.dart';

// Domain & Model importlarını ad-uzaylarıyla ayırdım
import '../../domain/entities/medication.dart' as domain;
import '../models/medication_model.dart' as model;

class MedicationMapper {
  /// MODEL (Hive) → ENTITY (Domain)
  static domain.Medication toEntity(model.MedicationModel m) {
    return domain.Medication(
      id: m.id,
      name: m.name,
      diagnosis: m.diagnosis,
      type: m.type,

      // Tarihler
      startDate: m.startDate,
      endDate: m.endDate,
      expirationDate: m.expirationDate,

      // Miktarlar
      totalPills: m.totalPills,
      remainingPills: m.remainingPills,
      dailyDosage: m.dailyDosage,

      // Planlama modları
      timeScheduleMode: _toDomainScheduleMode(m.timeScheduleMode),
      dayScheduleMode: _toDomainScheduleMode(m.dayScheduleMode),

      // Saatler (String "HH:mm" -> TimeOfDay)
      reminderTimes: m.reminderTimes?.map(_parseTime).toList(),

      // Gün seçimi
      isEveryDay: m.isEveryDay,
      usageDays: m.usageDays,

      // Yemek ilişkisi
      hoursBeforeOrAfterMeal: m.hoursBeforeOrAfterMeal,
      isAfterMeal: m.isAfterMeal,
    );
  }

  /// ENTITY (Domain) → MODEL (Hive)
  static model.MedicationModel toModel(domain.Medication e) {
    return model.MedicationModel(
      id: e.id,
      name: e.name,
      diagnosis: e.diagnosis,
      type: e.type,

      // Tarihler
      startDate: e.startDate,
      endDate: e.endDate,
      expirationDate: e.expirationDate,

      // Miktarlar
      totalPills: e.totalPills,
      remainingPills: e.remainingPills,
      dailyDosage: e.dailyDosage,

      // Planlama modları
      timeScheduleMode: _toModelScheduleMode(e.timeScheduleMode),
      dayScheduleMode: _toModelScheduleMode(e.dayScheduleMode),

      // Saatler (TimeOfDay -> String "HH:mm")
      reminderTimes: e.reminderTimes?.map(_formatTime).toList(),

      // Gün seçimi
      isEveryDay: e.isEveryDay,
      usageDays: e.usageDays,

      // Yemek ilişkisi
      hoursBeforeOrAfterMeal: e.hoursBeforeOrAfterMeal,
      isAfterMeal: e.isAfterMeal,
    );
  }

  // -------------------------
  // Helpers
  // -------------------------

  /// "08:30" → TimeOfDay(8, 30)
  static TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// TimeOfDay(8, 30) → "08:30"
  static String _formatTime(TimeOfDay t) {
    final hour = t.hour.toString().padLeft(2, '0');
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Model → Domain enum map
  static domain.ScheduleMode _toDomainScheduleMode(
      model.ScheduleMode mMode) {
    switch (mMode) {
      case model.ScheduleMode.automatic:
        return domain.ScheduleMode.automatic;
      case model.ScheduleMode.manual:
        return domain.ScheduleMode.manual;
    }
  }

  /// Domain → Model enum map
  static model.ScheduleMode _toModelScheduleMode(
      domain.ScheduleMode dMode) {
    switch (dMode) {
      case domain.ScheduleMode.automatic:
        return model.ScheduleMode.automatic;
      case domain.ScheduleMode.manual:
        return model.ScheduleMode.manual;
    }
  }
}
