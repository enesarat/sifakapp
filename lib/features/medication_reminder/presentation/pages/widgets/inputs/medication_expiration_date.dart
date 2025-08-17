import 'package:flutter/material.dart';

class MedicationExpirationDate extends StatelessWidget {
  const MedicationExpirationDate({
    super.key,
    required this.expirationDate,
    required this.onPickDate,
    required this.onClear,
  });

  final DateTime? expirationDate;
  final VoidCallback onPickDate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("SKT: "),
        TextButton(
          onPressed: onPickDate,
          child: Text(expirationDate == null ? '—' : "${expirationDate!.toLocal()}".split(' ')[0]),
        ),
        if (expirationDate != null)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Temizle',
            onPressed: onClear,
          ),
      ],
    );
  }
}
