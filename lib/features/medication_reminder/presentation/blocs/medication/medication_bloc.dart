// medication_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/create_medication.dart';
import '../../../domain/use_cases/delete_medication.dart';
import '../../../domain/use_cases/edit_medication.dart';
import '../../../domain/use_cases/get_all_medications.dart';
import '../../../domain/use_cases/plan/apply_plan_for_medication.dart';
import '../../../domain/use_cases/plan/reapply_plan_if_changed.dart';
import '../../../domain/use_cases/plan/cancel_plan_for_medication.dart';
import '../../../domain/use_cases/consume_dose.dart';
import '../../../domain/use_cases/skip_dose.dart';
import '../../../domain/use_cases/consume_dose_occurrence.dart';
import '../../../domain/use_cases/skip_dose_occurrence.dart';
import 'medication_event.dart';
import 'medication_state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final GetAllMedications getAllMedications;
  final CreateMedication createMedication;
  final DeleteMedication deleteMedication;
  final EditMedication editMedication;
  final ApplyPlanForMedication applyPlanForMedication;
  final ReapplyPlanIfChanged reapplyPlanIfChanged;
  final CancelPlanForMedication cancelPlanForMedication;
  final ConsumeDose consumeDose;
  final SkipDose skipDose;
  final ConsumeDoseOccurrence? consumeDoseOccurrence;
  final SkipDoseOccurrence? skipDoseOccurrence;

  MedicationBloc({
    required this.getAllMedications,
    required this.createMedication,
    required this.deleteMedication,
    required this.editMedication,
    required this.applyPlanForMedication,
    required this.reapplyPlanIfChanged,
    required this.cancelPlanForMedication,
    required this.consumeDose,
    required this.skipDose,
    this.consumeDoseOccurrence,
    this.skipDoseOccurrence,
  }) : super(MedicationInitial()) {
    on<FetchAllMedications>(_onFetchAll);
    on<AddMedication>(_onAdd);
    on<RemoveMedication>(_onRemove);
    on<UpdateMedication>(_onUpdate);
    on<ConsumeMedicationDose>(_onConsumeDose);
    on<SkipMedicationDose>(_onSkipDose);
  }

  Future<void> _onFetchAll(
    FetchAllMedications event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    try {
      final result = await getAllMedications.call();
      emit(MedicationLoaded(result));
    } catch (e) {
      emit(MedicationError('İlaçlar yüklenirken bir hata oluştu. Lütfen tekrar deneyin.'));
    }
  }

  Future<void> _onAdd(
    AddMedication event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      await createMedication.call(event.medication);
      try {
        await applyPlanForMedication.call(event.medication);
      } catch (_) {}
      emit(MedicationCreated(event.medication));
      add(FetchAllMedications());
    } catch (e) {
      emit(MedicationError('Kayıt eklenemedi. Lütfen tekrar deneyin.'));
    }
  }

  Future<void> _onRemove(
    RemoveMedication event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      try {
        await cancelPlanForMedication.call(event.id);
      } catch (_) {}
      await deleteMedication.call(event.id);
      emit(MedicationDeleted(event.id));
      add(FetchAllMedications());
    } catch (e) {
      emit(MedicationError('Kayıt silinemedi. Lütfen tekrar deneyin.'));
    }
  }

  Future<void> _onUpdate(
    UpdateMedication event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      await editMedication.call(event.medication);
      try {
        await reapplyPlanIfChanged.call(event.medication);
      } catch (_) {}
      emit(MedicationUpdated(event.medication));
      add(FetchAllMedications());
    } catch (e) {
      emit(MedicationError('Kayıt güncellenemedi. Lütfen tekrar deneyin.'));
    }
  }

  Future<void> _onConsumeDose(
    ConsumeMedicationDose event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      final updated = (event.occurrenceAt != null && consumeDoseOccurrence != null)
          ? await consumeDoseOccurrence!.call(
              medId: event.id, plannedAt: event.occurrenceAt!)
          : await consumeDose.call(event.id);
      emit(DoseConsumed(updated));
      add(FetchAllMedications());
    } catch (e) {
      emit(MedicationError('Doz kullanılamadı. Lütfen tekrar deneyin.'));
    }
  }

  Future<void> _onSkipDose(
    SkipMedicationDose event,
    Emitter<MedicationState> emit,
  ) async {
    try {
      if (event.occurrenceAt != null && skipDoseOccurrence != null) {
        await skipDoseOccurrence!.call(
            medId: event.id, plannedAt: event.occurrenceAt!);
      } else {
        await skipDose.call(event.id);
      }
      emit(DoseSkipped(event.id));
      add(FetchAllMedications());
    } catch (e) {
      emit(MedicationError('Doz atlanamadı. Lütfen tekrar deneyin.'));
    }
  }
}
