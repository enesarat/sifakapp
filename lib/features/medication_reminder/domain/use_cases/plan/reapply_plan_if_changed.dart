import '../../entities/medication.dart';
import '../../../application/plan/signature_util.dart';
import '../../../application/plan/plan_builder.dart';
import '../../../application/plan/schedule_from_plan.dart';
import '../../repositories/medication_plan_repository.dart';

class ReapplyPlanIfChanged {
  final MedicationPlanRepository planRepo;
  final ScheduleFromPlan schedulerRunner;

  ReapplyPlanIfChanged(this.planRepo, this.schedulerRunner);

  Future<void> call(Medication med) async {
    final newSig = buildMedicationSignature(med);
    final old = await planRepo.getByMedicationId(med.id);

    if (old != null && old.signature == newSig) {
      return; // değişiklik yok
    }

    if (old != null) {
      await schedulerRunner.cancelAll(old);
    }

    final newPlan = PlanBuilder.buildRepeating(med);
    await schedulerRunner.schedule(newPlan);
    await planRepo.save(newPlan);
  }
}
