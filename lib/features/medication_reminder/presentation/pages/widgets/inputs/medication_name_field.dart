import 'package:flutter/material.dart';

class MedicationNameField extends StatelessWidget {
  const MedicationNameField({super.key, required this.controller, required this.validator});
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: "İlaç Adı"),
      validator: validator,
    );
  }
}
