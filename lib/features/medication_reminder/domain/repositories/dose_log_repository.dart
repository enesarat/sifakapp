import '../entities/dose_log.dart';

abstract class DoseLogRepository {
  Future<DoseLog?> getByOccurrence(String medId, DateTime plannedAt);
  Future<void> upsert(DoseLog log);
  Future<List<DoseLog>> getInRange(DateTime start, DateTime end, {String? medId});
  Stream<List<DoseLog>> watchInRange(DateTime start, DateTime end, {String? medId});
}

