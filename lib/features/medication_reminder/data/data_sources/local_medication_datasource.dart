import 'package:hive/hive.dart';
import '../models/medication_model.dart';

class LocalMedicationDataSource {
  final Box<MedicationModel> box;

  LocalMedicationDataSource(this.box);

  Future<void> create(MedicationModel medication) async {
    await box.put(medication.id, medication);
  }

  Future<List<MedicationModel>> getAll() async {
    return box.values.toList();
  }

  Future<MedicationModel?> getById(String id) async {
    return box.get(id);
  }

  Future<void> update(MedicationModel medication) async {
    await box.put(medication.id, medication);
  }

  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
