import 'package:flutter/material.dart';

class MedicationDiagnosisField extends StatelessWidget {
  const MedicationDiagnosisField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: "Tanı"),
    );
  }
}
