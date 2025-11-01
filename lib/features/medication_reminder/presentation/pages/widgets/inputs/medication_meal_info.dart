import 'package:flutter/material.dart';

class MedicationMealInfo extends StatelessWidget {
  const MedicationMealInfo({
    super.key,
    required this.isAfterMeal,
    required this.onChanged,
    required this.hoursBeforeOrAfterMeal,
    required this.onSliderChanged,
    this.accentColor,
  });

  final bool isAfterMeal;
  final ValueChanged<bool> onChanged;
  final int hoursBeforeOrAfterMeal;
  final ValueChanged<double> onSliderChanged;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = accentColor ?? cs.primary;

    Widget pill({
      required IconData icon,
      required String text,
      required bool selected,
      required VoidCallback onTap,
    }) => Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? accent
                    : (theme.brightness == Brightness.light ? Colors.white : cs.surface),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: selected ? Colors.transparent : cs.outlineVariant,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: selected ? Colors.white : cs.onSurface),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: TextStyle(
                        color: selected ? Colors.white : cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yemekle İlişkisi',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            pill(
              icon: Icons.restaurant,
              text: 'Yemekten Sonra',
              selected: isAfterMeal,
              onTap: () => onChanged(true),
            ),
            const SizedBox(width: 8),
            pill(
              icon: Icons.no_food,
              text: 'Aç Karnına',
              selected: !isAfterMeal,
              onTap: () => onChanged(false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kaç saat ${isAfterMeal ? 'sonra' : 'önce'}?'),
            Text(
              '$hoursBeforeOrAfterMeal',
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
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
          activeColor: accent,
          thumbColor: accent,
          onChanged: onSliderChanged,
        ),
      ],
    );
  }
}



