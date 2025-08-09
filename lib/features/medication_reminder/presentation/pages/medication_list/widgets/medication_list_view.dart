import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'medication_list_item.dart';

class MedicationListView extends StatelessWidget {
  const MedicationListView({super.key, required this.medications});
  final List<Medication> medications;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medications.length,
      itemBuilder: (_, i) => MedicationListItem(med: medications[i]),
    );
  }
}
