import 'package:hive/hive.dart';

part 'medication_model.g.dart'; // Build runner ile oluşturulacak

@HiveType(typeId: 0)
class MedicationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String diagnosis;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final DateTime expirationDate;

  @HiveField(5)
  final int totalPills;

  @HiveField(6)
  final int dailyDosage;

  @HiveField(7)
  final bool isManualSchedule;

  @HiveField(8)
  final List<String>? reminderTimes; // "08:00", "13:00" gibi saat stringleri

  @HiveField(9)
  final int? hoursBeforeOrAfterMeal;

  @HiveField(10)
  final bool? isAfterMeal;

  MedicationModel({
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.type,
    required this.expirationDate,
    required this.totalPills,
    required this.dailyDosage,
    required this.isManualSchedule,
    this.reminderTimes,
    this.hoursBeforeOrAfterMeal,
    this.isAfterMeal,
  });
}
