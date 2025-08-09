import 'package:flutter/material.dart';

class MedicationPillsField extends StatelessWidget {
  const MedicationPillsField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(labelText: "Toplam Hap Sayısı"),
      keyboardType: TextInputType.number,
    );
  }
}
