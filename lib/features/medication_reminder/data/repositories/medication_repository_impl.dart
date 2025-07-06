import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../data/data_sources/local_medication_datasource.dart';
import '../mappers/medication_mapper.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final LocalMedicationDataSource dataSource;

  MedicationRepositoryImpl(this.dataSource);

  @override
  Future<void> createMedication(Medication medication) {
    final model = MedicationMapper.toModel(medication);
    return dataSource.create(model);
  }

  @override
  Future<void> deleteMedication(String id) =>
      dataSource.delete(id);

  @override
  Future<List<Medication>> getAllMedications() async {
    final models = await dataSource.getAll();
    return models.map(MedicationMapper.toEntity).toList();
  }

  @override
  Future<void> updateMedication(Medication medication) {
    final model = MedicationMapper.toModel(medication);
    return dataSource.update(model);
  }

  @override
  Future<Medication?> getMedicationById(String id) async {
    final model = await dataSource.getById(id);
    return model != null ? MedicationMapper.toEntity(model) : null;
  }
}
