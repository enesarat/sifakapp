import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/core/ui/spacing.dart';
import 'medication_list_item.dart';

class MedicationListView extends StatelessWidget {
  const MedicationListView({super.key, required this.medications});
  final List<Medication> medications;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.pageInsets(context: context, top: 16, bottom: 16),
      itemCount: medications.length,
      itemBuilder: (_, i) => MedicationListItem(med: medications[i]),
    );
  }
}
