import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class CreateMedication {
  final MedicationRepository repository;

  CreateMedication(this.repository);

  Future<void> call(Medication medication) {
    return repository.createMedication(medication);
  }
}
