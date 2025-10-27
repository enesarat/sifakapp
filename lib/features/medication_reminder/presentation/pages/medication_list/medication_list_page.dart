import 'package:flutter/material.dart';
import 'widgets/medication_list_appbar.dart';
import 'widgets/medication_list_body.dart';
import 'widgets/add_medication_fab.dart';

class MedicationListPage extends StatelessWidget {
  const MedicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const MedicationListAppBar(),
      body: const MedicationListBody(),
      floatingActionButton: const AddMedicationFab(),
    );
  }
}
