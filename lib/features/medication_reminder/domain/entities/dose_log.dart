enum DoseLogStatus {
  /// Doz zamanında veya sonradan kullanıcı tarafından alındı.
  taken,

  /// Kullanıcı hiçbir işlem yapmadı; sistem tarafından kaçırıldı olarak işaretlendi.
  missed,

  /// Kullanıcı bilerek “Atla” vb. aksiyonla pas geçti.
  passed,
}

class DoseLog {
  final String id; // medId@yyyyMMddHHmm
  final String medId;
  final DateTime plannedAt; // local wall-clock occurrence time
  final DateTime resolvedAt; // when user acted or worker marked
  final DoseLogStatus status;
  final bool acknowledged; // Susturulmuş/okundu (listelenmesin/yeniden bildirilmesin)

  const DoseLog({
    required this.id,
    required this.medId,
    required this.plannedAt,
    required this.resolvedAt,
    required this.status,
    this.acknowledged = false,
  });
}
