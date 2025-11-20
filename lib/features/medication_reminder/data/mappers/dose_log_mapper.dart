import '../../domain/entities/dose_log.dart' as domain;
import '../models/dose_log_model.dart' as model;

String buildDoseLogId(String medId, DateTime plannedAt) {
  final y = plannedAt.year.toString().padLeft(4, '0');
  final m = plannedAt.month.toString().padLeft(2, '0');
  final d = plannedAt.day.toString().padLeft(2, '0');
  final hh = plannedAt.hour.toString().padLeft(2, '0');
  final mm = plannedAt.minute.toString().padLeft(2, '0');
  return '$medId@$y$m$d$hh$mm';
}

model.DoseLogStatusModel toModelStatus(domain.DoseLogStatus s) {
  switch (s) {
    case domain.DoseLogStatus.taken:
      return model.DoseLogStatusModel.taken;
    case domain.DoseLogStatus.missed:
      return model.DoseLogStatusModel.missed;
    case domain.DoseLogStatus.passed:
      return model.DoseLogStatusModel.passed;
  }
}

domain.DoseLogStatus toDomainStatus(model.DoseLogStatusModel s) {
  switch (s) {
    case model.DoseLogStatusModel.taken:
      return domain.DoseLogStatus.taken;
    case model.DoseLogStatusModel.missed:
      return domain.DoseLogStatus.missed;
    case model.DoseLogStatusModel.passed:
      return domain.DoseLogStatus.passed;
  }
}

model.DoseLogModel toModel(domain.DoseLog e) {
  return model.DoseLogModel(
    id: e.id,
    medId: e.medId,
    plannedAt: e.plannedAt,
    resolvedAt: e.resolvedAt,
    status: toModelStatus(e.status),
  );
}

domain.DoseLog toEntity(model.DoseLogModel m) {
  return domain.DoseLog(
    id: m.id,
    medId: m.medId,
    plannedAt: m.plannedAt,
    resolvedAt: m.resolvedAt,
    status: toDomainStatus(m.status),
  );
}
