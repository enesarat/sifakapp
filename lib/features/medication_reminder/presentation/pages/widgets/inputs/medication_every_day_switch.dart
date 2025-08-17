import 'package:flutter/material.dart';

class MedicationEveryDaySwitch extends StatelessWidget {
  const MedicationEveryDaySwitch({
    super.key,
    required this.isEveryDay,
    required this.onChanged,
  });

  final bool isEveryDay;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Her gün kullanılacak'),
      value: isEveryDay,
      onChanged: onChanged,
    );
  }
}
