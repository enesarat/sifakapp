import 'package:flutter/material.dart';

class MedicationMealInfo extends StatelessWidget {
  const MedicationMealInfo({
    super.key,
    required this.isAfterMeal,
    required this.onChanged,
    required this.hoursBeforeOrAfterMeal,
    required this.onSliderChanged,
  });

  final bool isAfterMeal;
  final ValueChanged<bool> onChanged;
  final int hoursBeforeOrAfterMeal;
  final ValueChanged<double> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 32),
        const Text("Öğün Bilgisi", style: TextStyle(fontWeight: FontWeight.bold)),
        SwitchListTile(
          title: Text(isAfterMeal ? "Yemekten Sonra" : "Yemekten Önce"),
          value: isAfterMeal,
          onChanged: onChanged,
        ),
        Row(
          children: [
            Text("Kaç saat ${isAfterMeal ? 'sonra' : 'önce'}?"),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: hoursBeforeOrAfterMeal.toDouble(),
                min: 0,
                max: 3,
                divisions: 3,
                label: "$hoursBeforeOrAfterMeal saat",
                onChanged: (value) => onSliderChanged(value),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
