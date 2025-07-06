import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final String diagnosis;
  final String type; // Antibiotic, Vitamin, etc.
  final DateTime expirationDate;
  final int totalPills;
  final int dailyDosage; // Kaç defa alınacak
  final bool isManualSchedule;
  final List<TimeOfDay>? manualTimes; // Eğer manuelse
  final int? hoursBeforeOrAfterMeal; // Opsiyonel
  final bool? isAfterMeal;

  Medication({
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.type,
    required this.expirationDate,
    required this.totalPills,
    required this.dailyDosage,
    required this.isManualSchedule,
    this.manualTimes,
    this.hoursBeforeOrAfterMeal,
    this.isAfterMeal,
  });
}
