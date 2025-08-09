// medication_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/create_medication.dart';
import '../../../domain/use_cases/delete_medication.dart';
import '../../../domain/use_cases/edit_medication.dart';
import '../../../domain/use_cases/get_all_medications.dart';
import 'medication_event.dart';
import 'medication_state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final GetAllMedications getAllMedications;
  final CreateMedication createMedication;
  final DeleteMedication deleteMedication;
  final EditMedication editMedication;

  MedicationBloc({
    required this.getAllMedications,
    required this.createMedication,
    required this.deleteMedication,
    required this.editMedication,
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
      await createMedication.call(event.medication);
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
      await deleteMedication.call(event.id);
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
      add(FetchAllMedications());
    } catch (e) {
      emit(MedicationError('Kayıt güncellenemedi. Lütfen tekrar deneyin.'));
    }
  }
}
