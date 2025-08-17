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
    return Row(
      children: [
        const Text("Günlük Doz: "),
        Expanded(
          child: Slider(
            value: dailyDosage.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: dailyDosage.toString(),
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
        Text("$dailyDosage")
      ],
    );
  }
}
