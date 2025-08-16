import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sifakapp/core/validations/validator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_event.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_state.dart';

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
  /// URL paramı (typed route: /medications/:id/edit)
  final String id;

  /// Listeden gelirken hız için extra ile taşınabilir
  final Medication? initialMedication;

  const MedicationEditPage({
    super.key,
    required this.id,
    this.initialMedication,
  });

  @override
  State<MedicationEditPage> createState() => _MedicationEditPageState();
}

class _MedicationEditPageState extends State<MedicationEditPage> {
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _typeController;
  late final TextEditingController _pillsController;

  final _formKey = GlobalKey<FormState>();

  // Form alanları
  late DateTime _expirationDate;
  late int _dailyDosage;
  late bool _isManualSchedule;
  late List<TimeOfDay> _manualTimes;
  late bool _isAfterMeal;
  late int _hoursBeforeOrAfterMeal;

  Medication? _med; // tek kaynak
  bool _ready = false; // UI’ı yükleme/spinner kontrolü

  @override
  void initState() {
    super.initState();

    // Boş controller’larla başla; veri geldikçe hydrate edeceğiz
    _nameController = TextEditingController();
    _diagnosisController = TextEditingController();
    _typeController = TextEditingController();
    _pillsController = TextEditingController();

    // Varsayılanlar (fallback) – veri geldiğinde hydrate ile üzerine yazılacak
    _expirationDate = DateTime.now();
    _dailyDosage = 1;
    _isManualSchedule = false;
    _manualTimes = <TimeOfDay>[];
    _isAfterMeal = true;
    _hoursBeforeOrAfterMeal = 0;

    // 1) Extra varsa anında doldur
    _med = widget.initialMedication;
    if (_med != null) {
      _hydrateControllers(_med!);
      _ready = true;
      setState(() {});
      return;
    }

    // 2) BLoC’ta zaten yüklü liste varsa oradan bul
    final current = context.read<MedicationBloc>().state;
    if (current is MedicationLoaded) {
      final found = current.medications.where((m) => m.id == widget.id).toList();
      if (found.isNotEmpty) {
        _med = found.first;
        _hydrateControllers(_med!);
        _ready = true;
        setState(() {});
        return;
      }
    }

    // 3) Hâlâ yoksa listeyi tazele (deep link / refresh)
    context.read<MedicationBloc>().add(FetchAllMedications());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diagnosisController.dispose();
    _typeController.dispose();
    _pillsController.dispose();
    super.dispose();
  }

  void _hydrateControllers(Medication med) {
    _nameController.text = med.name;
    _diagnosisController.text = med.diagnosis;
    _typeController.text = med.type;
    _pillsController.text = med.totalPills.toString();

    _expirationDate = med.expirationDate;
    _dailyDosage = med.dailyDosage;
    _isManualSchedule = med.isManualSchedule;
    _manualTimes = List<TimeOfDay>.from(med.reminderTimes ?? const []);
    _isAfterMeal = med.isAfterMeal ?? true;
    _hoursBeforeOrAfterMeal = med.hoursBeforeOrAfterMeal ?? 0;
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
    final clamped = dose <= 0 ? 1 : dose; // 0’a bölünmeyi engelle
    final List<TimeOfDay> times = [];
    final interval = (24 / clamped).floor();
    for (int i = 0; i < clamped; i++) {
      times.add(TimeOfDay(hour: (i * interval) % 24, minute: 0));
    }
    return times;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final reminderTimes =
          _isManualSchedule ? _manualTimes : _generateDefaultTimes(_dailyDosage);

      final manualTimeError = Validator.validateManualTime(
        _manualTimes,
        _dailyDosage,
        _isManualSchedule,
      );
      if (manualTimeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(manualTimeError)),
        );
        return;
      }

      final updatedMedication = Medication(
        id: _med?.id ?? widget.id, // id her koşulda garanti
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen formu eksiksiz doldurun!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicationBloc, MedicationState>(
      listenWhen: (prev, curr) =>
          curr is MedicationUpdated ||
          curr is MedicationError ||
          // deep link / refresh sonrası liste gelince hydrate etmek için
          curr is MedicationLoaded,
      listener: (context, state) {
        if (state is MedicationLoaded && !_ready) {
          final found = state.medications.where((m) => m.id == widget.id).toList();
          if (found.isNotEmpty) {
            _med = found.first;
            _hydrateControllers(_med!);
            _ready = true;
            setState(() {});
          }
        } else if (state is MedicationUpdated) {
          // önce mesajı göster, sonra geri dön
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt güncellendi.')),
          );
          Navigator.of(context).pop(); // go_router kullanıyorsan: context.pop();
        } else if (state is MedicationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("İlacı Düzenle")),
        body: !_ready
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
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
                          validator: (manualTimes) => Validator.validateManualTime(
                            manualTimes,
                            _dailyDosage,
                            true,
                          ),
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
                          if (_formKey.currentState!.validate()) {
                            _submit();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
