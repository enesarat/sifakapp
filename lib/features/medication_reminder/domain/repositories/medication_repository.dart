import '../entities/medication.dart';

abstract class MedicationRepository {
  Future<void> createMedication(Medication medication);
  Future<List<Medication>> getAllMedications();
  Future<void> updateMedication(Medication medication);
  Future<void> deleteMedication(String id);
  Future<Medication?> getMedicationById(String id);
}
