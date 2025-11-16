import '../entities/dose_log.dart';
import '../repositories/dose_log_repository.dart';

class SkipDoseOccurrence {
  final DoseLogRepository logs;
  SkipDoseOccurrence(this.logs);

  Future<void> call({required String medId, required DateTime plannedAt}) async {
    final log = DoseLog(
      id: _idFor(medId, plannedAt),
      medId: medId,
      plannedAt: plannedAt,
      resolvedAt: DateTime.now(),
      status: DoseLogStatus.skipped,
    );
    await logs.upsert(log);
  }
}

String _idFor(String medId, DateTime at) {
  final y = at.year.toString().padLeft(4, '0');
  final m = at.month.toString().padLeft(2, '0');
  final d = at.day.toString().padLeft(2, '0');
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return '$medId@$y$m$d$hh$mm';
}

