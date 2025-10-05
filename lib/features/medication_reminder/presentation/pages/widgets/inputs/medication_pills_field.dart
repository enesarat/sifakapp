import 'package:flutter/material.dart';

class MedicationPillsField extends StatelessWidget {
  const MedicationPillsField({
    super.key,
    required this.controller,
    required this.validator,
    this.labelText = 'Toplam Hap Sayisi',
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }
}
