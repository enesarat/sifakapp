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
    final formatted = "${startDate.toLocal()}".split(' ')[0];
    return TextFormField(
      key: ValueKey(formatted),
      readOnly: true,
      initialValue: formatted,
      onTap: onPickDate,
      decoration: const InputDecoration(
        labelText: 'Başlangıç',
        suffixIcon: Icon(Icons.calendar_today_outlined),
      ),
    );
  }
}

