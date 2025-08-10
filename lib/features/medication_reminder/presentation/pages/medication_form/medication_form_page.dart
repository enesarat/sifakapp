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

class MedicationFormPage extends StatefulWidget {
  const MedicationFormPage({super.key});

  @override
  State<MedicationFormPage> createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends State<MedicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _typeController = TextEditingController();
  final _pillsController = TextEditingController();
  DateTime _expirationDate = DateTime.now();
  int _dailyDosage = 1;
  bool _isManualSchedule = false;
  List<TimeOfDay> _manualTimes = [];
  bool _isAfterMeal = true;
  int _hoursBeforeOrAfterMeal = 0;

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
      
      final medication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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

      context.read<MedicationBloc>().add(AddMedication(medication));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen formu eksiksiz doldurun!'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Medication")),
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
