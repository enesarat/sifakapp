import 'package:hive/hive.dart';
import '../models/medication_plan_model.dart';

class LocalMedicationPlanDataSource {
  final Box<MedicationPlanModel> box;
  LocalMedicationPlanDataSource(this.box);

  Future<void> put(MedicationPlanModel m) async => box.put(m.medicationId, m);
  Future<MedicationPlanModel?> get(String medicationId) async => box.get(medicationId);
  Future<void> delete(String medicationId) async => box.delete(medicationId);
}
