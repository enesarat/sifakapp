import '../../domain/entities/medication_plan.dart' as domain;
import '../../domain/repositories/medication_plan_repository.dart';
import '../data_sources/local_medication_plan_datasource.dart';
import '../mappers/medication_plan_mapper.dart';

class MedicationPlanRepositoryImpl implements MedicationPlanRepository {
  final LocalMedicationPlanDataSource ds;
  MedicationPlanRepositoryImpl(this.ds);

  @override
  Future<void> save(domain.MedicationPlan plan) async {
    final m = MedicationPlanMapper.toModel(plan);
    await ds.put(m);
  }

  @override
  Future<domain.MedicationPlan?> getByMedicationId(String medicationId) async {
    final m = await ds.get(medicationId);
    if (m == null) return null;
    return MedicationPlanMapper.toDomain(m);
  }

  @override
  Future<void> deleteByMedicationId(String medicationId) async {
    await ds.delete(medicationId);
  }
}
