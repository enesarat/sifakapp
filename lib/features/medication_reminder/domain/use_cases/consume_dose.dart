import '../repositories/medication_repository.dart';
import '../entities/medication.dart';

class ConsumeDose {
  final MedicationRepository repository;
  ConsumeDose(this.repository);

  /// Decrements remainingPills by 1 (not below 0) and returns updated entity.
  Future<Medication> call(String medId) async {
    final med = await repository.getMedicationById(medId);
    if (med == null) {
      throw ArgumentError('Medication not found: $medId');
    }
    final newRemaining = (med.remainingPills - 1).clamp(0, 1 << 31);
    final updated = med.copyWith(remainingPills: newRemaining);
    await repository.updateMedication(updated);
    return updated;
  }
}

