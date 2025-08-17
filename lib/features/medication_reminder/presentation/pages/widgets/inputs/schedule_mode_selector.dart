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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: const SizedBox(height: 6),
      trailing: SegmentedButton<ScheduleMode>(
        segments: const [
          ButtonSegment(value: ScheduleMode.automatic, label: Text('Otomatik'), icon: Icon(Icons.auto_mode)),
          ButtonSegment(value: ScheduleMode.manual, label: Text('Manuel'), icon: Icon(Icons.tune)),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
