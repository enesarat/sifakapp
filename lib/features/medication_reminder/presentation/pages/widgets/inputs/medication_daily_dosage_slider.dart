import 'package:flutter/material.dart';

class MedicationDailyDosageSlider extends StatelessWidget {
  const MedicationDailyDosageSlider({
    super.key,
    required this.dailyDosage,
    required this.onChanged,
  });

  final int dailyDosage;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Günlük Doz'),
            Text(
              '$dailyDosage',
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: dailyDosage.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: dailyDosage.toString(),
          onChanged: (val) => onChanged(val.toInt()),
        ),
      ],
    );
  }
}
