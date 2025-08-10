import 'package:flutter/material.dart';

class MedicationTimePicker extends StatelessWidget {
  const MedicationTimePicker({
    super.key,
    required this.manualTimes,
    required this.onPickTime,
    required this.dailyDosage,
    required this.validator,
  });

  final List<TimeOfDay> manualTimes;
  final void Function(int) onPickTime;
  final int dailyDosage;
  final String? Function(List<TimeOfDay>) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(
          dailyDosage,
          (index) => ListTile(
            title: Text(manualTimes.length > index
                ? manualTimes[index].format(context)
                : 'Zaman Seç (${index + 1})'),
            trailing: const Icon(Icons.access_time),
            onTap: () => onPickTime(index),
          ),
        ),
        if (validator(manualTimes) != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              validator(manualTimes)!,
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
  }
}
