import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_form/medication_form_page.dart';

class AddMedicationFab extends StatelessWidget {
  const AddMedicationFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicationFormPage()),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
