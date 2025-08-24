import '../entities/medication_plan.dart';

abstract class MedicationPlanRepository {
  Future<void> save(MedicationPlan plan);          // create or replace by medicationId
  Future<MedicationPlan?> getByMedicationId(String medicationId);
  Future<void> deleteByMedicationId(String medicationId);
}
