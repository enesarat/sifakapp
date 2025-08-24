import '../../entities/medication.dart';
import '../../entities/medication_plan.dart';
import '../../../application/plan/plan_builder.dart';
import '../../../application/plan/schedule_from_plan.dart';
import '../../repositories/medication_plan_repository.dart';

class ApplyPlanForMedication {
  final MedicationPlanRepository planRepo;
  final ScheduleFromPlan schedulerRunner;

  ApplyPlanForMedication(this.planRepo, this.schedulerRunner);

  Future<MedicationPlan> call(Medication med) async {
    // İstersen kriterlere göre weekly/daily ya da horizon seç
    final plan = med.isEveryDay
        ? PlanBuilder.buildRepeating(med) // daily
        : (med.usageDays != null && med.usageDays!.isNotEmpty)
            ? PlanBuilder.buildRepeating(med) // weekly
            : PlanBuilder.buildRepeating(med); // fallback

    await schedulerRunner.schedule(plan);
    await planRepo.save(plan);
    return plan;
  }
}
