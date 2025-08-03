import '../repositories/medication_repository.dart';

class DeleteMedication {
  final MedicationRepository repository;

  DeleteMedication(this.repository);

  Future<void> call(String id) {
    return repository.deleteMedication(id);
  }
}
