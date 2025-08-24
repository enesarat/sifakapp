// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_plan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalTimeModelAdapter extends TypeAdapter<LocalTimeModel> {
  @override
  final int typeId = 3;

  @override
  LocalTimeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalTimeModel(
      fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LocalTimeModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.minutesSinceMidnight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalTimeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailySlotModelAdapter extends TypeAdapter<DailySlotModel> {
  @override
  final int typeId = 4;

  @override
  DailySlotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySlotModel(
      time: fields[0] as LocalTimeModel,
      notificationId: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailySlotModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySlotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeeklySlotModelAdapter extends TypeAdapter<WeeklySlotModel> {
  @override
  final int typeId = 5;

  @override
  WeeklySlotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklySlotModel(
      weekday: fields[0] as int,
      time: fields[1] as LocalTimeModel,
      notificationId: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklySlotModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.weekday)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklySlotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OneOffOccurrenceModelAdapter extends TypeAdapter<OneOffOccurrenceModel> {
  @override
  final int typeId = 6;

  @override
  OneOffOccurrenceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OneOffOccurrenceModel(
      scheduledAt: fields[0] as DateTime,
      notificationId: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OneOffOccurrenceModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.scheduledAt)
      ..writeByte(1)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OneOffOccurrenceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationPlanModelAdapter extends TypeAdapter<MedicationPlanModel> {
  @override
  final int typeId = 7;

  @override
  MedicationPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationPlanModel(
      medicationId: fields[0] as String,
      signature: fields[1] as String,
      pattern: fields[2] as RepeatPatternModel,
      dailySlots: (fields[3] as List?)?.cast<DailySlotModel>(),
      weeklySlots: (fields[4] as List?)?.cast<WeeklySlotModel>(),
      oneOffs: (fields[5] as List?)?.cast<OneOffOccurrenceModel>(),
      plannedThrough: fields[6] as DateTime?,
      isEnabled: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationPlanModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.medicationId)
      ..writeByte(1)
      ..write(obj.signature)
      ..writeByte(2)
      ..write(obj.pattern)
      ..writeByte(3)
      ..write(obj.dailySlots)
      ..writeByte(4)
      ..write(obj.weeklySlots)
      ..writeByte(5)
      ..write(obj.oneOffs)
      ..writeByte(6)
      ..write(obj.plannedThrough)
      ..writeByte(7)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatPatternModelAdapter extends TypeAdapter<RepeatPatternModel> {
  @override
  final int typeId = 2;

  @override
  RepeatPatternModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatPatternModel.daily;
      case 1:
        return RepeatPatternModel.weekly;
      case 2:
        return RepeatPatternModel.none;
      default:
        return RepeatPatternModel.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatPatternModel obj) {
    switch (obj) {
      case RepeatPatternModel.daily:
        writer.writeByte(0);
        break;
      case RepeatPatternModel.weekly:
        writer.writeByte(1);
        break;
      case RepeatPatternModel.none:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatPatternModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
