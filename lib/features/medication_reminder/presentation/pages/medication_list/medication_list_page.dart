import 'package:flutter/material.dart';
import 'widgets/medication_list_appbar.dart';
import 'widgets/medication_list_body.dart';
import 'widgets/add_medication_fab.dart';

class MedicationListPage extends StatelessWidget {
  const MedicationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MedicationListAppBar(),
      body: MedicationListBody(),
      floatingActionButton: AddMedicationFab(),
    );
  }
}
