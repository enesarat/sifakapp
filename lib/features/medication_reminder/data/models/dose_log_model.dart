import 'package:hive/hive.dart';

@HiveType(typeId: 8)
enum DoseLogStatusModel {
  @HiveField(0)
  taken,
  @HiveField(1)
  missed,
  @HiveField(2)
  passed,
}

@HiveType(typeId: 9)
class DoseLogModel extends HiveObject {
  @HiveField(0)
  final String id; // medId@yyyyMMddHHmm

  @HiveField(1)
  final String medId;

  @HiveField(2)
  final DateTime plannedAt;

  @HiveField(3)
  final DateTime resolvedAt;

  @HiveField(4)
  final DoseLogStatusModel status;

  DoseLogModel({
    required this.id,
    required this.medId,
    required this.plannedAt,
    required this.resolvedAt,
    required this.status,
  });
}

// Manual adapters to avoid codegen dependency in this step.
class DoseLogStatusModelAdapter extends TypeAdapter<DoseLogStatusModel> {
  @override
  final int typeId = 8;

  @override
  DoseLogStatusModel read(BinaryReader reader) {
    final index = reader.readByte();
    switch (index) {
      case 0:
        return DoseLogStatusModel.taken;
      case 1:
        // Eski verilerde 1 = skipped idi; bunları missed olarak yorumla.
        return DoseLogStatusModel.missed;
      case 2:
        return DoseLogStatusModel.passed;
    }
    return DoseLogStatusModel.taken;
  }

  @override
  void write(BinaryWriter writer, DoseLogStatusModel obj) {
    writer.writeByte(obj.index);
  }
}

class DoseLogModelAdapter extends TypeAdapter<DoseLogModel> {
  @override
  final int typeId = 9;

  @override
  DoseLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return DoseLogModel(
      id: fields[0] as String,
      medId: fields[1] as String,
      plannedAt: fields[2] as DateTime,
      resolvedAt: fields[3] as DateTime,
      status: fields[4] as DoseLogStatusModel,
    );
  }

  @override
  void write(BinaryWriter writer, DoseLogModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medId)
      ..writeByte(2)
      ..write(obj.plannedAt)
      ..writeByte(3)
      ..write(obj.resolvedAt)
      ..writeByte(4)
      ..write(obj.status);
  }
}
