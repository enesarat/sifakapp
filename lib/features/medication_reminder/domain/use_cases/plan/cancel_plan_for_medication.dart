import '../../../application/plan/schedule_from_plan.dart';
import '../../repositories/medication_plan_repository.dart';

class CancelPlanForMedication {
  final MedicationPlanRepository planRepo;
  final ScheduleFromPlan schedulerRunner;

  CancelPlanForMedication(this.planRepo, this.schedulerRunner);

  Future<void> call(String medicationId) async {
    final plan = await planRepo.getByMedicationId(medicationId);
    if (plan == null) return;
    await schedulerRunner.cancelAll(plan);
    await planRepo.deleteByMedicationId(medicationId);
  }
}
