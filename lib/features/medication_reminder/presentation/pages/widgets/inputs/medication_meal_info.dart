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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget pill(String text, bool selected, VoidCallback onTap) => Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? (theme.brightness == Brightness.light
                        ? Colors.white
                        : cs.surfaceVariant)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: selected ? cs.primary : cs.onSurface.withOpacity(0.6),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yemek Bilgisi',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              pill('Yemekten Sonra', isAfterMeal, () => onChanged(true)),
              const SizedBox(width: 6),
              pill('Yemekten Önce', !isAfterMeal, () => onChanged(false)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kaç saat ${isAfterMeal ? 'sonra' : 'önce'}?'),
            Text(
              '$hoursBeforeOrAfterMeal',
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: hoursBeforeOrAfterMeal.toDouble(),
          min: 0,
          max: 3,
          divisions: 3,
          label: '$hoursBeforeOrAfterMeal saat',
          onChanged: onSliderChanged,
        ),
      ],
    );
  }
}

