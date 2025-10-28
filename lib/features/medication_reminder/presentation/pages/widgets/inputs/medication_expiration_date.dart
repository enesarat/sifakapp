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
    final formatted = expirationDate == null ? '' : "${expirationDate!.toLocal()}".split(' ')[0];
    return TextFormField(
      key: ValueKey(formatted),
      readOnly: true,
      initialValue: formatted,
      onTap: onPickDate,
      decoration: InputDecoration(
        labelText: 'SKT',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (expirationDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Temizle',
                onPressed: onClear,
              ),
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }
}
