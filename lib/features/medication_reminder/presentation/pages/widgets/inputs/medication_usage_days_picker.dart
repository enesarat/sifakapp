import 'package:flutter/material.dart';

class MedicationUsageDaysPicker extends StatelessWidget {
  const MedicationUsageDaysPicker({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    this.validator,
    this.helperText,
  });

  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;
  final String? Function(List<int> days)? validator;
  final String? helperText;

  static const _labels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final errorText = validator?.call(selectedDays);

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
          Text(helperText!, style: TextStyle(color: Theme.of(context).hintColor)),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
