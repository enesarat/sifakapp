import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/medication.dart';
import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';

class MedicationFormPage extends StatefulWidget {
  const MedicationFormPage({super.key});

  @override
  _MedicationFormPageState createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends State<MedicationFormPage> {
  final _nameController = TextEditingController();
  TimeOfDay? _selectedTime;

  void _submit() {
    if (_selectedTime != null && _nameController.text.isNotEmpty) {
      final newMedication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        diagnosis: '',
        type: '',
        expirationDate: DateTime.now(),
        totalPills: 0, 
        dailyDosage: 1,
        isManualSchedule: true,
        manualTimes: [_selectedTime!],
      );
      context.read<MedicationBloc>().add(AddMedication(newMedication));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Medication")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) setState(() => _selectedTime = picked);
              },
              child: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Pick Time'),
            ),
            Spacer(),
            ElevatedButton(onPressed: _submit, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
