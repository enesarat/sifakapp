import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/medication.dart';
import '../bloc/medication_bloc.dart';
import '../bloc/medication_event.dart';

class MedicationEditPage extends StatefulWidget {
  final Medication medication;

  const MedicationEditPage({super.key, required this.medication});

  @override
  State<MedicationEditPage> createState() => _MedicationEditPageState();
}

class _MedicationEditPageState extends State<MedicationEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _diagnosisController;
  late TextEditingController _typeController;
  late TextEditingController _pillsController;

  late DateTime _expirationDate;
  late int _dailyDosage;
  late bool _isManualSchedule;
  late List<TimeOfDay> _manualTimes;

  late bool _isAfterMeal;
  late int _hoursBeforeOrAfterMeal;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _diagnosisController = TextEditingController(text: widget.medication.diagnosis);
    _typeController = TextEditingController(text: widget.medication.type);
    _pillsController = TextEditingController(text: widget.medication.totalPills.toString());

    _expirationDate = widget.medication.expirationDate;
    _dailyDosage = widget.medication.dailyDosage;
    _isManualSchedule = widget.medication.isManualSchedule;
    _manualTimes = widget.medication.reminderTimes ?? [];
    _isAfterMeal = widget.medication.isAfterMeal ?? true;
    _hoursBeforeOrAfterMeal = widget.medication.hoursBeforeOrAfterMeal ?? 0;
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8 + index * 3, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (_manualTimes.length > index) {
          _manualTimes[index] = picked;
        } else {
          _manualTimes.add(picked);
        }
      });
    }
  }

  List<TimeOfDay> _generateDefaultTimes(int dose) {
    final List<TimeOfDay> times = [];
    final interval = (24 / dose).floor();
    for (int i = 0; i < dose; i++) {
      times.add(TimeOfDay(hour: (i * interval) % 24, minute: 0));
    }
    return times;
  }

  void _submit() {
    final reminderTimes = _isManualSchedule
        ? _manualTimes
        : _generateDefaultTimes(_dailyDosage);

    final updatedMedication = Medication(
      id: widget.medication.id,
      name: _nameController.text,
      diagnosis: _diagnosisController.text,
      type: _typeController.text,
      expirationDate: _expirationDate,
      totalPills: int.tryParse(_pillsController.text) ?? 0,
      dailyDosage: _dailyDosage,
      isManualSchedule: _isManualSchedule,
      reminderTimes: reminderTimes,
      hoursBeforeOrAfterMeal: _hoursBeforeOrAfterMeal,
      isAfterMeal: _isAfterMeal,
    );

    context.read<MedicationBloc>().add(UpdateMedication(updatedMedication));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İlacı Düzenle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "İlaç Adı")),
            TextField(controller: _diagnosisController, decoration: const InputDecoration(labelText: "Tanı")),
            TextField(controller: _typeController, decoration: const InputDecoration(labelText: "Tür (Vitamin vb.)")),
            TextField(
              controller: _pillsController,
              decoration: const InputDecoration(labelText: "Toplam Hap Sayısı"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Son Kullanma Tarihi: "),
                TextButton(
                  onPressed: () => _pickDate(context),
                  child: Text("${_expirationDate.toLocal()}".split(' ')[0]),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Günlük Doz: "),
                Expanded(
                  child: Slider(
                    value: _dailyDosage.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _dailyDosage.toString(),
                    onChanged: (val) => setState(() => _dailyDosage = val.toInt()),
                  ),
                ),
                Text("$_dailyDosage")
              ],
            ),
            SwitchListTile(
              title: const Text("Zamanları Manuel Girmek İstiyorum"),
              value: _isManualSchedule,
              onChanged: (val) {
                setState(() {
                  _isManualSchedule = val;
                  _manualTimes = [];
                });
              },
            ),
            if (_isManualSchedule)
              ...List.generate(
                _dailyDosage,
                (index) => ListTile(
                  title: Text(_manualTimes.length > index
                      ? _manualTimes[index].format(context)
                      : 'Zaman Seç (${index + 1})'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _pickTime(index),
                ),
              ),
            const Divider(height: 32),
            const Text("Öğün Bilgisi", style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: Text(_isAfterMeal ? "Yemekten Sonra" : "Yemekten Önce"),
              value: _isAfterMeal,
              onChanged: (val) => setState(() => _isAfterMeal = val),
            ),
            Row(
              children: [
                Text("Kaç saat ${_isAfterMeal ? 'sonra' : 'önce'}?"),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _hoursBeforeOrAfterMeal.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: "$_hoursBeforeOrAfterMeal saat",
                    onChanged: (val) => setState(() => _hoursBeforeOrAfterMeal = val.toInt()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: _submit,
                child: const Text("Güncelle"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}