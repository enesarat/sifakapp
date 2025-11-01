import 'package:flutter/material.dart';

class MedicationTimePicker extends StatelessWidget {
  const MedicationTimePicker({
    super.key,
    required this.manualTimes,
    required this.onPickTime,
    required this.dailyDosage,
    this.validator,
    this.chipStyle = false,
    this.accentColor,
    this.chipRadius,
  });

  final List<TimeOfDay> manualTimes;
  final Future<void> Function(int index) onPickTime;
  final int dailyDosage;
  final String? Function(List<TimeOfDay> times)? validator;
  final bool chipStyle;
  final Color? accentColor;
  final double? chipRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = accentColor ?? cs.primary;
    final errorText = validator?.call(manualTimes);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Manuel Saatler'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(dailyDosage, (i) {
            final label = (manualTimes.length > i)
                ? manualTimes[i].format(context)
                : 'Seç';
            if (chipStyle) {
              return InkWell(
                onTap: () => onPickTime(i),
                borderRadius: BorderRadius.circular(chipRadius ?? 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(chipRadius ?? 24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, color: accent),
                      const SizedBox(width: 6),
                      Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }
            return OutlinedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(label),
              onPressed: () => onPickTime(i),
            );
          }),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: TextStyle(color: cs.error)),
        ],
      ],
    );
  }
}
