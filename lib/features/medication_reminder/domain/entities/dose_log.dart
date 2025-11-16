enum DoseLogStatus { taken, skipped }

class DoseLog {
  final String id; // medId@yyyyMMddHHmm
  final String medId;
  final DateTime plannedAt; // local wall-clock occurrence time
  final DateTime resolvedAt; // when user acted or worker marked
  final DoseLogStatus status;

  const DoseLog({
    required this.id,
    required this.medId,
    required this.plannedAt,
    required this.resolvedAt,
    required this.status,
  });
}

