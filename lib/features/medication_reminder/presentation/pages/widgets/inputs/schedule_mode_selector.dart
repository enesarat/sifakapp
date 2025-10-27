import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';

class ScheduleModeSelector extends StatelessWidget {
  const ScheduleModeSelector({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final ScheduleMode value;
  final ValueChanged<ScheduleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedColor = Colors.white;
    final unselectedColor = cs.onSurface.withOpacity(0.6);

    Widget pill(String text, bool selected, VoidCallback onTap) => Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? (Theme.of(context).brightness == Brightness.light
                        ? selectedColor
                        : cs.surfaceVariant)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: selected ? cs.primary : unselectedColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                pill('Otomatik', value == ScheduleMode.automatic,
                    () => onChanged(ScheduleMode.automatic)),
                const SizedBox(width: 6),
                pill('Manuel', value == ScheduleMode.manual,
                    () => onChanged(ScheduleMode.manual)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
