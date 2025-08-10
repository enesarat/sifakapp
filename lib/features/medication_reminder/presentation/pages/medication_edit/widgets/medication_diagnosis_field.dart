import 'package:flutter/material.dart';

class MedicationDiagnosisField extends StatelessWidget {
  const MedicationDiagnosisField({super.key, required this.controller, required this.validator});
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: "Tanı"),
      validator: validator,
    );
  }
}
