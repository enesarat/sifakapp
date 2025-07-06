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
      expirationDate: fields[4] as DateTime,
      totalPills: fields[5] as int,
      dailyDosage: fields[6] as int,
      isManualSchedule: fields[7] as bool,
      manualTimes: (fields[8] as List?)?.cast<String>(),
      hoursBeforeOrAfterMeal: fields[9] as int?,
      isAfterMeal: fields[10] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.diagnosis)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.expirationDate)
      ..writeByte(5)
      ..write(obj.totalPills)
      ..writeByte(6)
      ..write(obj.dailyDosage)
      ..writeByte(7)
      ..write(obj.isManualSchedule)
      ..writeByte(8)
      ..write(obj.manualTimes)
      ..writeByte(9)
      ..write(obj.hoursBeforeOrAfterMeal)
      ..writeByte(10)
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
