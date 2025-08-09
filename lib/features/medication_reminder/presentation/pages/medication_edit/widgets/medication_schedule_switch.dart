import 'package:flutter/material.dart';

class MedicationScheduleSwitch extends StatelessWidget {
  const MedicationScheduleSwitch({
    super.key,
    required this.isManualSchedule,
    required this.onChanged,
  });

  final bool isManualSchedule;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("Zamanları Manuel Girmek İstiyorum"),
      value: isManualSchedule,
      onChanged: onChanged,
    );
  }
}
