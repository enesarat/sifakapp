import 'package:flutter/material.dart';

class MedicationStartDateField extends StatelessWidget {
  const MedicationStartDateField({
    super.key,
    required this.startDate,
    required this.onPickDate,
  });

  final DateTime startDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Başlangıç: "),
        TextButton(
          onPressed: onPickDate,
          child: Text("${startDate.toLocal()}".split(' ')[0]),
        ),
      ],
    );
  }
}
