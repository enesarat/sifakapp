import 'package:flutter/material.dart';

class MedicationNameField extends StatelessWidget {
  const MedicationNameField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: "İlaç Adı"),
    );
  }
}
