import 'package:flutter/material.dart';

class MedicationEndDateField extends StatelessWidget {
  const MedicationEndDateField({
    super.key,
    required this.endDate,
    required this.onPickDate,
    required this.onClear,
  });

  final DateTime? endDate;
  final VoidCallback onPickDate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Bitiş: "),
        TextButton(
          onPressed: onPickDate,
          child: Text(endDate == null ? '—' : "${endDate!.toLocal()}".split(' ')[0]),
        ),
        if (endDate != null)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Temizle',
            onPressed: onClear,
          ),
      ],
    );
  }
}
