import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sifakapp/core/service_locator.dart';
import 'package:sifakapp/core/validations/validator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_catalog_entry.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/get_medication_category_by_key.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_event.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_state.dart';

// Reusable inputs
import '../widgets/widgets.dart';

// utils
import '../../utils/schedule_utils.dart'; // previewAutomaticUsageDays, generateAutomaticUsageDays
import '../../utils/time_utils.dart'; // generateEvenlySpacedTimes

class MedicationEditPage extends StatefulWidget {
  final String id;
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

  late final GetMedicationCategoryByKey _getMedicationCategoryByKey =
      sl<GetMedicationCategoryByKey>();

  final _formKey = GlobalKey<FormState>();

  // ---- Entity ile uyumlu alanlar ----
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  DateTime? _expirationDate;

  int _dailyDosage = 1;

  ScheduleMode _timeScheduleMode = ScheduleMode.automatic;
  ScheduleMode _dayScheduleMode = ScheduleMode.manual;

  bool _isEveryDay = true;
  List<int> _usageDays = []; // manuel günler (1..7)

  // Otomatik gün planı (haftada kaç gün & önizleme)
  int _autoDaysPerWeek = 3; // 0..6
  List<int> _autoPreviewDays = []; // 1..7 (chip önizlemesi)

  // Saatler
  List<TimeOfDay> _manualTimes = [];

  // Yemek bilgisi
  bool _isAfterMeal = true;
  int _hoursBeforeOrAfterMeal = 0;

  void _onMedicationNameEdited() {}

  void _onMedicationSuggestionSelected(MedicationCatalogEntry entry) {
    _applyCatalogSuggestion(entry);
  }

  Future<void> _applyCatalogSuggestion(MedicationCatalogEntry entry) async {
    if (entry.categoryKey == MedicationCategoryKey.oralCapsule &&
        entry.pieces != null) {
      _pillsController.text = entry.pieces.toString();
    }

    if (entry.categoryKey != null) {
      try {
        final category = await _getMedicationCategoryByKey(entry.categoryKey!);
        if (!mounted) return;
        if (category != null) {
          _typeController.text = category.label;
        } else {
          _typeController.text = entry.categoryKey!.value;
        }
      } catch (_) {
        if (!mounted) return;
        _typeController.text = entry.categoryKey!.value;
      }
    }
  }

  Medication? _med;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _diagnosisController = TextEditingController();
    _typeController = TextEditingController();
    _pillsController = TextEditingController();

    // 1) extra ile gelen
    _med = widget.initialMedication;
    if (_med != null) {
      _hydrateControllers(_med!);
      _ready = true;
      setState(() {});
      return;
    }

    // 2) mevcut listedeki kayıttan
    final current = context.read<MedicationBloc>().state;
    if (current is MedicationLoaded) {
      final found =
          current.medications.where((m) => m.id == widget.id).toList();
      if (found.isNotEmpty) {
        _med = found.first;
        _hydrateControllers(_med!);
        _ready = true;
        setState(() {});
        return;
      }
    }

    // 3) deep-link/refresh
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

    _startDate = med.startDate;
    _endDate = med.endDate;
    _expirationDate = med.expirationDate;

    _dailyDosage = med.dailyDosage;

    _timeScheduleMode = med.timeScheduleMode;
    _dayScheduleMode = med.dayScheduleMode;

    _isEveryDay = med.isEveryDay;

    _usageDays = List<int>.from(med.usageDays ?? const []);
    _autoDaysPerWeek =
        (!_isEveryDay && _dayScheduleMode == ScheduleMode.automatic)
            ? (_usageDays.length.clamp(0, 6))
            : 3;

    _manualTimes = List<TimeOfDay>.from(med.reminderTimes ?? const []);
    _isAfterMeal = med.isAfterMeal ?? true;
    _hoursBeforeOrAfterMeal = med.hoursBeforeOrAfterMeal ?? 0;

    _autoPreviewDays = previewAutomaticUsageDays(
      isEveryDay: _isEveryDay,
      isAutomaticDayMode: _dayScheduleMode == ScheduleMode.automatic,
      autoDaysPerWeek: _autoDaysPerWeek,
      startWeekday: _startDate.weekday,
    );
  }

  // ---- Pickers (UI tarafında kalmalı) ----
  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _autoPreviewDays = previewAutomaticUsageDays(
          isEveryDay: _isEveryDay,
          isAutomaticDayMode: _dayScheduleMode == ScheduleMode.automatic,
          autoDaysPerWeek: _autoDaysPerWeek,
          startWeekday: _startDate.weekday,
        );
      });
    }
  }

  Future<void> _pickEndDate() async {
    final initial = _endDate ?? _startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickExpirationDate() async {
    final initial = _expirationDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expirationDate = picked);
  }

  Future<void> _pickTime(int index) async {
    final initial = (_manualTimes.length > index)
        ? _manualTimes[index]
        : TimeOfDay(hour: 8 + index * 3, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
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
  // ---- pickers end ----

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen formu eksiksiz doldurun!')),
      );
      return;
    }

    // Saat planı manuel ise saat sayısı/doğrulama
    if (_timeScheduleMode == ScheduleMode.manual) {
      final manualTimeError = Validator.validateManualTime(
        _manualTimes,
        _dailyDosage,
        true,
      );
      if (manualTimeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(manualTimeError)),
        );
        return;
      }
    }

    // --- Gün doğrulaması (merkezileştirildi) ---
    final daysError = Validator.validateUsageDays(
      isEveryDay: _isEveryDay,
      isManualDayMode: _dayScheduleMode == ScheduleMode.manual,
      selectedDays: _usageDays,
      autoDaysPerWeek: _autoDaysPerWeek,
    );
    if (daysError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(daysError)));
      return;
    }

    // Kaydetmek için usageDays hazırla
    List<int>? usageDaysForSave;
    if (_isEveryDay) {
      usageDaysForSave = null;
    } else if (_dayScheduleMode == ScheduleMode.manual) {
      usageDaysForSave = (_usageDays..sort());
    } else {
      usageDaysForSave = generateAutomaticUsageDays(
        _autoDaysPerWeek,
        startWeekday: _startDate.weekday,
      );
    }

    final totalPills = int.tryParse(_pillsController.text) ?? 0;
    final remainingPills = _med?.remainingPills ?? totalPills;

    final reminderTimes = _timeScheduleMode == ScheduleMode.manual
        ? _manualTimes
        : generateEvenlySpacedTimes(_dailyDosage);

    final updated = Medication(
      id: _med?.id ?? widget.id,
      name: _nameController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      type: _typeController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      expirationDate: _expirationDate,
      totalPills: totalPills,
      remainingPills: remainingPills,
      dailyDosage: _dailyDosage,
      timeScheduleMode: _timeScheduleMode,
      dayScheduleMode: _dayScheduleMode,
      isEveryDay: _isEveryDay,
      usageDays: usageDaysForSave,
      reminderTimes:
          _timeScheduleMode == ScheduleMode.manual ? reminderTimes : null,
      hoursBeforeOrAfterMeal: _hoursBeforeOrAfterMeal,
      isAfterMeal: _isAfterMeal,
    );

    context.read<MedicationBloc>().add(UpdateMedication(updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicationBloc, MedicationState>(
      listenWhen: (prev, curr) =>
          curr is MedicationUpdated ||
          curr is MedicationError ||
          curr is MedicationLoaded,
      listener: (context, state) {
        if (state is MedicationLoaded && !_ready) {
          final found =
              state.medications.where((m) => m.id == widget.id).toList();
          if (found.isNotEmpty) {
            _med = found.first;
            _hydrateControllers(_med!);
            _ready = true;
            setState(() {});
          }
        } else if (state is MedicationUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt güncellendi.')),
          );
          Navigator.of(context).pop();
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
                        onSuggestionSelected: _onMedicationSuggestionSelected,
                        onManuallyEdited: _onMedicationNameEdited,
                      ),
                      MedicationDiagnosisField(
                        controller: _diagnosisController,
                        validator: Validator.validateDiagnosis,
                      ),
                      MedicationTypeField(controller: _typeController),

                      const SizedBox(height: 8),
                      MedicationStartDateField(
                        startDate: _startDate,
                        onPickDate: _pickStartDate,
                      ),
                      MedicationEndDateField(
                        endDate: _endDate,
                        onPickDate: _pickEndDate,
                        onClear: () => setState(() => _endDate = null),
                      ),
                      MedicationExpirationDate(
                        expirationDate: _expirationDate,
                        onPickDate: _pickExpirationDate,
                        onClear: () => setState(() => _expirationDate = null),
                      ),

                      MedicationPillsField(
                        controller: _pillsController,
                        validator: Validator.validatePills,
                      ),
                      MedicationDailyDosageSlider(
                        dailyDosage: _dailyDosage,
                        onChanged: (value) =>
                            setState(() => _dailyDosage = value),
                      ),

                      const SizedBox(height: 8),
                      // Saat planÃ„Â±
                      ScheduleModeSelector(
                        title: 'Saat Planı',
                        value: _timeScheduleMode,
                        onChanged: (v) => setState(() {
                          _timeScheduleMode = v;
                          _manualTimes = [];
                        }),
                      ),
                      if (_timeScheduleMode == ScheduleMode.manual)
                        MedicationTimePicker(
                          manualTimes: _manualTimes,
                          onPickTime: _pickTime,
                          dailyDosage: _dailyDosage,
                          validator: (manualTimes) =>
                              Validator.validateManualTime(
                                  manualTimes, _dailyDosage, true),
                        ),

                      const SizedBox(height: 12),
                      MedicationEveryDaySwitch(
                        isEveryDay: _isEveryDay,
                        onChanged: (v) {
                          setState(() {
                            _isEveryDay = v;
                            _autoPreviewDays = previewAutomaticUsageDays(
                              isEveryDay: _isEveryDay,
                              isAutomaticDayMode:
                                  _dayScheduleMode == ScheduleMode.automatic,
                              autoDaysPerWeek: _autoDaysPerWeek,
                              startWeekday: _startDate.weekday,
                            );
                            if (_isEveryDay) {
                              _usageDays = [];
                            }
                          });
                        },
                      ),

                      if (!_isEveryDay) ...[
                        ScheduleModeSelector(
                          title: 'Gün Planı',
                          value: _dayScheduleMode,
                          onChanged: (v) {
                            setState(() {
                              _dayScheduleMode = v;
                              if (v == ScheduleMode.automatic) {
                                _autoDaysPerWeek =
                                    (_usageDays.length).clamp(0, 6);
                                _autoPreviewDays = previewAutomaticUsageDays(
                                  isEveryDay: _isEveryDay,
                                  isAutomaticDayMode: true,
                                  autoDaysPerWeek: _autoDaysPerWeek,
                                  startWeekday: _startDate.weekday,
                                );
                              } else {
                                _usageDays = [];
                                _autoPreviewDays = [];
                              }
                            });
                          },
                        ),
                        if (_dayScheduleMode == ScheduleMode.manual)
                          MedicationUsageDaysPicker(
                            selectedDays: _usageDays,
                            onChanged: (days) {
                              setState(() {
                                _usageDays = days;
                                // 7 gün seçildiyse "Her gün"e geç
                                if (_usageDays.length >= 7) {
                                  _isEveryDay = true;
                                  _usageDays = [];
                                  _autoPreviewDays = previewAutomaticUsageDays(
                                    isEveryDay: _isEveryDay,
                                    isAutomaticDayMode: _dayScheduleMode ==
                                        ScheduleMode.automatic,
                                    autoDaysPerWeek: _autoDaysPerWeek,
                                    startWeekday: _startDate.weekday,
                                  );
                                }
                              });
                            },
                            // Inline validator (manuelde en az 1 gün, 1..7, tekrarsızlık)
                            validator: (days) => Validator.validateUsageDays(
                              isEveryDay: _isEveryDay,
                              isManualDayMode: true,
                              selectedDays: days,
                            ),
                          ),
                        if (_dayScheduleMode == ScheduleMode.automatic)
                          MedicationWeeklyDaysCount(
                            value: _autoDaysPerWeek,
                            onChanged: (v) {
                              setState(() {
                                _autoDaysPerWeek = v;
                                _autoPreviewDays = previewAutomaticUsageDays(
                                  isEveryDay: _isEveryDay,
                                  isAutomaticDayMode: true,
                                  autoDaysPerWeek: _autoDaysPerWeek,
                                  startWeekday: _startDate.weekday,
                                );
                              });
                            },
                            previewDays: _autoPreviewDays,
                          ),
                      ],

                      const SizedBox(height: 12),
                      MedicationMealInfo(
                        isAfterMeal: _isAfterMeal,
                        onChanged: (value) =>
                            setState(() => _isAfterMeal = value),
                        hoursBeforeOrAfterMeal: _hoursBeforeOrAfterMeal,
                        onSliderChanged: (value) => setState(
                            () => _hoursBeforeOrAfterMeal = value.toInt()),
                      ),

                      const SizedBox(height: 20),
                      MedicationSaveButton(onPressed: _submit),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
