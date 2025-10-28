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
    final formatted = endDate == null ? '' : "${endDate!.toLocal()}".split(' ')[0];
    return TextFormField(
      key: ValueKey(formatted),
      readOnly: true,
      initialValue: formatted,
      onTap: onPickDate,
      decoration: InputDecoration(
        labelText: 'Bitiş',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (endDate != null)
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
