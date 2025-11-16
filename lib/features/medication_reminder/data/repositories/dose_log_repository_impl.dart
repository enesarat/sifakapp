import 'dart:async';

import 'package:hive/hive.dart';

import '../../domain/entities/dose_log.dart' as domain;
import '../../domain/repositories/dose_log_repository.dart';
import '../models/dose_log_model.dart' as model;
import '../mappers/dose_log_mapper.dart' as mapper;

class DoseLogRepositoryImpl implements DoseLogRepository {
  final Box<model.DoseLogModel> box;
  DoseLogRepositoryImpl(this.box);

  @override
  Future<domain.DoseLog?> getByOccurrence(String medId, DateTime plannedAt) async {
    final id = mapper.buildDoseLogId(medId, plannedAt);
    final m = box.get(id);
    return m == null ? null : mapper.toEntity(m);
  }

  @override
  Future<void> upsert(domain.DoseLog log) async {
    await box.put(log.id, mapper.toModel(log));
  }

  @override
  Future<List<domain.DoseLog>> getInRange(DateTime start, DateTime end, {String? medId}) async {
    final out = <domain.DoseLog>[];
    for (final key in box.keys) {
      final m = box.get(key);
      if (m == null) continue;
      final inRange = !m.plannedAt.isBefore(start) && !m.plannedAt.isAfter(end);
      if (!inRange) continue;
      if (medId != null && m.medId != medId) continue;
      out.add(mapper.toEntity(m));
    }
    // Not ordered guarantee; sort by plannedAt
    out.sort((a, b) => a.plannedAt.compareTo(b.plannedAt));
    return out;
  }

  @override
  Stream<List<domain.DoseLog>> watchInRange(DateTime start, DateTime end, {String? medId}) {
    // Hive doesn't provide fine-grained range watch; listen to box and filter in memory
    final ctrl = StreamController<List<domain.DoseLog>>.broadcast();

    void emit() async {
      final list = await getInRange(start, end, medId: medId);
      if (!ctrl.isClosed) ctrl.add(list);
    }

    final sub = box.watch().listen((_) => emit());
    // Emit initial
    emit();

    ctrl.onCancel = () {
      sub.cancel();
    };

    return ctrl.stream;
  }
}

