import 'package:flutter/material.dart';

class MedicationTypeField extends StatelessWidget {
  const MedicationTypeField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: "Tür (Vitamin vb.)"),
    );
  }
}
