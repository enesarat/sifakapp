import 'package:flutter/material.dart';

class MedicationPillsField extends StatelessWidget {
  const MedicationPillsField({super.key, required this.controller, required this.validator});
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: "Toplam Hap Sayısı"),
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }
}
