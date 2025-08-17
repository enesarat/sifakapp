import 'package:flutter/material.dart';

class MedicationWeeklyDaysCount extends StatelessWidget {
  const MedicationWeeklyDaysCount({
    super.key,
    required this.value,                 // 0..6
    required this.onChanged,
    this.previewDays = const <int>[],    // 1..7 ISO; UI'de chip olarak gösterilir
  });

  final int value;
  final ValueChanged<int> onChanged;
  final List<int> previewDays;

  static const _labels = {
    1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cts', 7: 'Paz',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Haftada kaç gün kullanılacak?"),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 6,
                divisions: 6,
                label: value.toString(),
                onChanged: (v) => onChanged(v.toInt()),
              ),
            ),
            SizedBox(width: 8),
            Text("$value gün"),
          ],
        ),
        if (previewDays.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: previewDays
                .map((d) => Chip(label: Text(_labels[d] ?? d.toString())))
                .toList(),
          ),
        ],
      ],
    );
  }
}
