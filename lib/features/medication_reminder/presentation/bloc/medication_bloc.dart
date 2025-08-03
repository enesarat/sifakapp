import '../../domain/use_cases/create_medication.dart';
import '../../domain/use_cases/delete_medication.dart';
import '../../domain/use_cases/get_all_medications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'medication_event.dart';
import 'medication_state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final GetAllMedications getAllMedications;
  final CreateMedication createMedication;
  final DeleteMedication deleteMedication;

  MedicationBloc({
    required this.getAllMedications,
    required this.createMedication,
    required this.deleteMedication,
  }) : super(MedicationInitial()) {
    on<FetchAllMedications>((event, emit) async {
      emit(MedicationLoading());
      final result = await getAllMedications.call();
      emit(MedicationLoaded(result));
    });

    on<AddMedication>((event, emit) async {
      await createMedication.call(event.medication);
      add(FetchAllMedications());
    });

    on<RemoveMedication>((event, emit) async {
      await deleteMedication.call(event.id);
      add(FetchAllMedications());
    });
  }
}
