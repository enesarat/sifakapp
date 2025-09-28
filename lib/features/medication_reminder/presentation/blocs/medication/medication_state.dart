import '../../../domain/entities/medication.dart';

abstract class MedicationState {}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationLoaded extends MedicationState {
  final List<Medication> medications;
  MedicationLoaded(this.medications);
}

class MedicationError extends MedicationState {
  final String message;
  MedicationError(this.message);
}

class MedicationCreated extends MedicationState {
  final Medication medication;
  MedicationCreated(this.medication);
}

class MedicationUpdated extends MedicationState {
  final Medication medication;
  MedicationUpdated(this.medication);
}

class MedicationDeleted extends MedicationState {
  final String id;
  MedicationDeleted(this.id);
}

class DoseConsumed extends MedicationState {
  final Medication medication;
  DoseConsumed(this.medication);
}

class DoseSkipped extends MedicationState {
  final String id;
  DoseSkipped(this.id);
}
