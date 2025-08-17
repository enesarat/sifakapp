import 'package:flutter/material.dart';

class MedicationTimePicker extends StatelessWidget {
  const MedicationTimePicker({
    super.key,
    required this.manualTimes,
    required this.onPickTime,
    required this.dailyDosage,
    this.validator,
  });

  final List<TimeOfDay> manualTimes;
  final Future<void> Function(int index) onPickTime;
  final int dailyDosage;
  final String? Function(List<TimeOfDay> times)? validator;

  @override
  Widget build(BuildContext context) {
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
            return OutlinedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(label),
              onPressed: () => onPickTime(i),
            );
          }),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }
}
