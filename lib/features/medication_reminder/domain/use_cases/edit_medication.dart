import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class EditMedication {
  final MedicationRepository repository;

  EditMedication(this.repository);

  Future<void> call(Medication medication) {
    return repository.updateMedication(medication);
  }
}
