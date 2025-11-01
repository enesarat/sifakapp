import 'package:flutter/material.dart';

class MedicationUsageDaysPicker extends StatelessWidget {
  const MedicationUsageDaysPicker({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    this.validator,
    this.helperText,
    this.accentColor,
    this.borderRadius,
  });

  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;
  final String? Function(List<int> days)? validator;
  final String? helperText;
  final Color? accentColor;
  final double? borderRadius;

  static const _labels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final errorText = validator?.call(selectedDays);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = accentColor ?? cs.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kullanım Günleri'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (i) {
            final day = i + 1; // 1..7
            final isSelected = selectedDays.contains(day);
            return ChoiceChip(
              label: Text(_labels[i]),
              selected: isSelected,
              selectedColor: accent.withOpacity(0.12),
              labelStyle: TextStyle(
                color: isSelected ? accent : theme.textTheme.labelLarge?.color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 16),
              ),
              onSelected: (sel) {
                final set = selectedDays.toSet();
                if (sel) {
                  set.add(day);
                } else {
                  set.remove(day);
                }
                final updated = set.toList()..sort();
                onChanged(updated);
              },
            );
          }),
        ),
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: 6),
          Text(helperText!, style: TextStyle(color: theme.hintColor)),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: TextStyle(color: cs.error),
          ),
        ],
      ],
    );
  }
}
