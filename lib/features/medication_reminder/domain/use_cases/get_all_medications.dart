import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

class GetAllMedications {
  final MedicationRepository repository;

  GetAllMedications(this.repository);

  Future<List<Medication>> call() {
    return repository.getAllMedications();
  }
}
