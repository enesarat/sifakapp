import '../../../domain/entities/medication.dart';

abstract class MedicationEvent {}

class FetchAllMedications extends MedicationEvent {}

class AddMedication extends MedicationEvent {
  final Medication medication;
  AddMedication(this.medication);
}

class RemoveMedication extends MedicationEvent {
  final String id;
  RemoveMedication(this.id);
}

class UpdateMedication extends MedicationEvent {
  final Medication medication;
  UpdateMedication(this.medication);
}

class ConsumeMedicationDose extends MedicationEvent {
  final String id;
  final DateTime? occurrenceAt;
  ConsumeMedicationDose(this.id, {this.occurrenceAt});
}

class SkipMedicationDose extends MedicationEvent {
  final String id;
  final DateTime? occurrenceAt;
  SkipMedicationDose(this.id, {this.occurrenceAt});
}
