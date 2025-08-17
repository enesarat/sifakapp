// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationModelAdapter extends TypeAdapter<MedicationModel> {
  @override
  final int typeId = 0;

  @override
  MedicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationModel(
      id: fields[0] as String,
      name: fields[1] as String,
      diagnosis: fields[2] as String,
      type: fields[3] as String,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime?,
      expirationDate: fields[6] as DateTime?,
      totalPills: fields[7] as int,
      remainingPills: fields[8] as int,
      dailyDosage: fields[9] as int,
      timeScheduleMode: fields[10] as ScheduleMode,
      dayScheduleMode: fields[11] as ScheduleMode,
      reminderTimes: (fields[12] as List?)?.cast<String>(),
      isEveryDay: fields[13] as bool,
      usageDays: (fields[14] as List?)?.cast<int>(),
      hoursBeforeOrAfterMeal: fields[15] as int?,
      isAfterMeal: fields[16] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.diagnosis)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.expirationDate)
      ..writeByte(7)
      ..write(obj.totalPills)
      ..writeByte(8)
      ..write(obj.remainingPills)
      ..writeByte(9)
      ..write(obj.dailyDosage)
      ..writeByte(10)
      ..write(obj.timeScheduleMode)
      ..writeByte(11)
      ..write(obj.dayScheduleMode)
      ..writeByte(12)
      ..write(obj.reminderTimes)
      ..writeByte(13)
      ..write(obj.isEveryDay)
      ..writeByte(14)
      ..write(obj.usageDays)
      ..writeByte(15)
      ..write(obj.hoursBeforeOrAfterMeal)
      ..writeByte(16)
      ..write(obj.isAfterMeal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleModeAdapter extends TypeAdapter<ScheduleMode> {
  @override
  final int typeId = 1;

  @override
  ScheduleMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleMode.automatic;
      case 1:
        return ScheduleMode.manual;
      default:
        return ScheduleMode.automatic;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleMode obj) {
    switch (obj) {
      case ScheduleMode.automatic:
        writer.writeByte(0);
        break;
      case ScheduleMode.manual:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
