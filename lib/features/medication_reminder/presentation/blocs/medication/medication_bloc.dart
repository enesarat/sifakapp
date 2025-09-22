// medication_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/create_medication.dart';
import '../../../domain/use_cases/delete_medication.dart';
import '../../../domain/use_cases/edit_medication.dart';
import '../../../domain/use_cases/get_all_medications.dart';
import '../../../domain/use_cases/plan/apply_plan_for_medication.dart';
import '../../../domain/use_cases/plan/reapply_plan_if_changed.dart';
import '../../../domain/use_cases/plan/cancel_plan_for_medication.dart';
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

  MedicationBloc({
    required this.getAllMedications,
    required this.createMedication,
    required this.deleteMedication,
    required this.editMedication,
    required this.applyPlanForMedication,
    required this.reapplyPlanIfChanged,
    required this.cancelPlanForMedication,
  }) : super(MedicationInitial()) {
    on<FetchAllMedications>(_onFetchAll);
    on<AddMedication>(_onAdd);
    on<RemoveMedication>(_onRemove);
    on<UpdateMedication>(_onUpdate);
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
      // Tercihen createMedication, kaydedilen Medication veya id dönebilir.
      await createMedication.call(event.medication);

      // Kaydedilen ilaç için planı uygula (schedule + persist)
      try {
        await applyPlanForMedication.call(event.medication);
      } catch (_) {}

      // 1) Başarı sinyalini ver
      emit(MedicationCreated(event.medication));

      // 2) Listeyi tazele (UI zaten success'i dinleyebilir)
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
        // Önce planları iptal et, sonra ilacı sil
        try {
          await cancelPlanForMedication.call(event.id);
        } catch (_) {}
        await deleteMedication.call(event.id);

        // 1) Başarı sinyali
        emit(MedicationDeleted(event.id));

        // 2) Listeyi tazele
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

        // Değişiklik varsa planı yeniden uygula
        try {
          await reapplyPlanIfChanged.call(event.medication);
        } catch (_) {}

        // 1) Başarı sinyali
        emit(MedicationUpdated(event.medication));

        // 2) Listeyi tazele
        add(FetchAllMedications());
      } catch (e) {
        emit(MedicationError('Kayıt güncellenemedi. Lütfen tekrar deneyin.'));
      }
    }

}
