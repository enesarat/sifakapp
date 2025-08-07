import 'package:flutter/material.dart';

import '../../domain/entities/medication.dart';
import '../models/medication_model.dart';

class MedicationMapper {
  /// Model → Entity
  static Medication toEntity(MedicationModel model) {
    return Medication(
      id: model.id,
      name: model.name,
      diagnosis: model.diagnosis,
      type: model.type,
      expirationDate: model.expirationDate,
      totalPills: model.totalPills,
      dailyDosage: model.dailyDosage,
      isManualSchedule: model.isManualSchedule,
      reminderTimes: model.reminderTimes?.map(_parseTime).toList(),
      hoursBeforeOrAfterMeal: model.hoursBeforeOrAfterMeal,
      isAfterMeal: model.isAfterMeal,
    );
  }

  /// Entity → Model
  static MedicationModel toModel(Medication entity) {
    return MedicationModel(
      id: entity.id,
      name: entity.name,
      diagnosis: entity.diagnosis,
      type: entity.type,
      expirationDate: entity.expirationDate,
      totalPills: entity.totalPills,
      dailyDosage: entity.dailyDosage,
      isManualSchedule: entity.isManualSchedule,
      reminderTimes: entity.reminderTimes?.map(_formatTime).toList(),
      hoursBeforeOrAfterMeal: entity.hoursBeforeOrAfterMeal,
      isAfterMeal: entity.isAfterMeal,
    );
  }

  /// "08:30" → TimeOfDay(8, 30)
  static TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// TimeOfDay(8, 30) → "08:30"
  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
