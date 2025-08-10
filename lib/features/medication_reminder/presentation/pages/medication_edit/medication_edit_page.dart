import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sifakapp/core/validations/validator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_event.dart';
import 'widgets/medication_name_field.dart';
import 'widgets/medication_diagnosis_field.dart';
import 'widgets/medication_type_field.dart';
import 'widgets/medication_pills_field.dart';
import 'widgets/medication_expiration_date.dart';
import 'widgets/medication_daily_dosage_slider.dart';
import 'widgets/medication_schedule_switch.dart';
import 'widgets/medication_time_picker.dart';
import 'widgets/medication_meal_info.dart';
import 'widgets/medication_save_button.dart';

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
  final _formKey = GlobalKey<FormState>();

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
    if (_formKey.currentState!.validate()) {
      final reminderTimes = _isManualSchedule
          ? _manualTimes
          : _generateDefaultTimes(_dailyDosage);
      
      final manualTimeError = Validator.validateManualTime(_manualTimes, _dailyDosage, _isManualSchedule);
      if (manualTimeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(manualTimeError)),
        );
        return;
      }

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen formu eksiksiz doldurun!')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İlacı Düzenle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,  // Form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicationNameField(
                controller: _nameController,
                validator: Validator.validateMedicationName,
              ),
              MedicationDiagnosisField(
                controller: _diagnosisController,
                validator: Validator.validateDiagnosis,
              ),
              MedicationTypeField(controller: _typeController),
              MedicationPillsField(
                controller: _pillsController,
                validator: Validator.validatePills,
              ),
              MedicationExpirationDate(
                expirationDate: _expirationDate,
                onPickDate: () => _pickDate(context),
              ),
              MedicationDailyDosageSlider(
                dailyDosage: _dailyDosage,
                onChanged: (value) => setState(() => _dailyDosage = value),
              ),
              MedicationScheduleSwitch(
                isManualSchedule: _isManualSchedule,
                onChanged: (value) => setState(() {
                  _isManualSchedule = value;
                  _manualTimes = [];
                }),
              ),
              if (_isManualSchedule)
                MedicationTimePicker(
                  manualTimes: _manualTimes,
                  onPickTime: _pickTime,
                  dailyDosage: _dailyDosage,
                  validator: (manualTimes) => Validator.validateManualTime(manualTimes, _dailyDosage, true),
                ),
              MedicationMealInfo(
                isAfterMeal: _isAfterMeal,
                onChanged: (value) => setState(() => _isAfterMeal = value),
                hoursBeforeOrAfterMeal: _hoursBeforeOrAfterMeal,
                onSliderChanged: (value) =>
                    setState(() => _hoursBeforeOrAfterMeal = value.toInt()),
              ),
              const SizedBox(height: 20),
              MedicationSaveButton(
                onPressed: () {
                  // Validate the form
                  if (_formKey.currentState!.validate()) {
                    _submit();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
