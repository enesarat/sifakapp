import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/service_locator.dart';
import 'package:sifakapp/core/validations/validator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_catalog_entry.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/get_all_medication_categories.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/catalog/models/catalog_add_confirmation.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/check_medication_catalog_entry_exists.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/add_custom_medication_catalog_entry.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_event.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_state.dart';

// Reusable inputs (barrel)
import '../widgets/widgets.dart';

// utils
import '../../utils/schedule_utils.dart'; // previewAutomaticUsageDays, generateAutomaticUsageDays
import '../../utils/time_utils.dart'; // generateEvenlySpacedTimes

class MedicationFormPage extends StatefulWidget {
  const MedicationFormPage({super.key});

  @override
  State<MedicationFormPage> createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends State<MedicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _pillsController = TextEditingController();

  late final GetAllMedicationCategories _getAllMedicationCategories =
      sl<GetAllMedicationCategories>();
  late final CheckMedicationCatalogEntryExists
      _checkMedicationCatalogEntryExists =
      sl<CheckMedicationCatalogEntryExists>();
  late final AddCustomMedicationCatalogEntry _addCustomMedicationCatalogEntry =
      sl<AddCustomMedicationCatalogEntry>();

  // Dates
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  DateTime? _expirationDate;

  // Dosage & schedule
  int _dailyDosage = 1;
  ScheduleMode _timeScheduleMode = ScheduleMode.automatic;
  ScheduleMode _dayScheduleMode = ScheduleMode.manual;
  bool _isEveryDay = true;
  List<int> _usageDays = []; // manual selection
  int _autoDaysPerWeek = 3; // 0..6 (default 3)
  List<int> _autoPreviewDays = []; // UI preview

  // Times
  List<TimeOfDay> _manualTimes = [];

  // Meal
  bool _isAfterMeal = true;
  int _hoursBeforeOrAfterMeal = 0;

  // Catalog categories
  List<MedicationCategory> _categories = [];
  bool _isCategoryLoading = true;
  MedicationCategoryKey? _selectedCategoryKey;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diagnosisController.dispose();
    _pillsController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _getAllMedicationCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isCategoryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = const [];
        _isCategoryLoading = false;
      });
    }
  }

  MedicationCategory? _categoryForKey(MedicationCategoryKey? key) {
    if (key == null) return null;
    for (final category in _categories) {
      if (category.key == key) {
        return category;
      }
    }
    return null;
  }

  Future<bool> _ensureCatalogEntry(String name, int totalPills) async {
    try {
      final exists = await _checkMedicationCatalogEntryExists(name);
      if (exists) {
        return true;
      }
    } catch (_) {
      return true;
    }

    final categoryLabel = _categoryForKey(_selectedCategoryKey)?.label;
    final decision = await AddCatalogEntryConfirmRoute(
      name: name,
      totalPills: totalPills,
      typeLabel: categoryLabel,
    ).push<CatalogAddDecision>(context);

    if (!mounted) {
      return false;
    }
    if (decision == null) {
      return false;
    }
    if (decision == CatalogAddDecision.add) {
      try {
        await _addCustomMedicationCatalogEntry(
          AddCustomMedicationCatalogEntryParams(
            name: name,
            categoryKey: _selectedCategoryKey,
            pieces: totalPills > 0 ? totalPills : null,
          ),
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İlaç kataloğu güncellenemedi.'),
            ),
          );
        }
      }
    }
    return true;
  }

  void _onMedicationNameEdited() {
    if (_selectedCategoryKey != null) {
      setState(() {
        _selectedCategoryKey = null;
      });
    }
  }

  void _onMedicationSuggestionSelected(MedicationCatalogEntry entry) {
    setState(() {
      if (entry.categoryKey == MedicationCategoryKey.oralCapsule &&
          entry.pieces != null) {
        _pillsController.text = entry.pieces.toString();
      }
      _selectedCategoryKey = entry.categoryKey;
    });
  }

  bool get _isCapsuleSelected =>
      _selectedCategoryKey == MedicationCategoryKey.oralCapsule;

  // ---- Pickers (UI side only) ----
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
  // ---- pickers end ----

  String _resolveTypeLabel() {
    final category = _categoryForKey(_selectedCategoryKey);
    if (category != null) {
      return category.label;
    }
    if (_selectedCategoryKey != null) {
      return _selectedCategoryKey!.value;
    }
    return '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen formu eksiksiz doldurun!')),
      );
      return;
    }

    if (_timeScheduleMode == ScheduleMode.manual) {
      final manualTimeError = Validator.validateManualTime(
        _manualTimes,
        _dailyDosage,
        true,
      );
      if (manualTimeError != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(manualTimeError)));
        return;
      }
    }

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
    final remainingPills = totalPills;

    final reminderTimes = _timeScheduleMode == ScheduleMode.manual
        ? _manualTimes
        : generateEvenlySpacedTimes(_dailyDosage);

    final medication = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      type: _resolveTypeLabel(),
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

    final canProceed = await _ensureCatalogEntry(
      medication.name,
      totalPills,
    );
    if (!canProceed) {
      return;
    }

    if (!mounted) {
      return;
    }

    context.read<MedicationBloc>().add(AddMedication(medication));
  }

  @override
  Widget build(BuildContext context) {
    final totalPillsLabel =
        _isCapsuleSelected ? 'Toplam Hap Sayısı' : 'Toplam Doz Sayısı';

    return BlocListener<MedicationBloc, MedicationState>(
      listenWhen: (prev, curr) =>
          curr is MedicationCreated || curr is MedicationError,
      listener: (context, state) {
        if (state is MedicationCreated) {
          context.pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt eklendi.')),
          );
        } else if (state is MedicationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: const Text('Plan Oluştur')),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: MedicationSaveButton(onPressed: () { _submit(); }),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const SizedBox(height: 12),
                MedicationDiagnosisField(
                  controller: _diagnosisController,
                  validator: Validator.validateDiagnosis,
                ),
                const SizedBox(height: 12),
                MedicationTypeField(
                  categories: _categories,
                  selectedKey: _selectedCategoryKey,
                  isLoading: _isCategoryLoading,
                  onChanged: (key) {
                    setState(() {
                      _selectedCategoryKey = key;
                    });
                  },
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MedicationStartDateField(
                        startDate: _startDate,
                        onPickDate: _pickStartDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MedicationEndDateField(
                        endDate: _endDate,
                        onPickDate: _pickEndDate,
                        onClear: () => setState(() => _endDate = null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MedicationExpirationDate(
                  expirationDate: _expirationDate,
                  onPickDate: _pickExpirationDate,
                  onClear: () => setState(() => _expirationDate = null),
                ),
                const SizedBox(height: 16),
                SectionHeader(title: 'Dozaj & Stok'),
                MedicationDailyDosageSlider(
                  dailyDosage: _dailyDosage,
                  onChanged: (value) => setState(() => _dailyDosage = value),
                ),
                const SizedBox(height: 12),
                MedicationPillsField(
                  controller: _pillsController,
                  validator: Validator.validatePills,
                  labelText: _isCapsuleSelected
                      ? 'Toplam Hap Sayısı'
                      : 'Toplam Doz Sayısı',
                ),

                const SizedBox(height: 16),
                SectionHeader(title: 'Plan'),
                // Time schedule
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
                    validator: (manualTimes) => Validator.validateManualTime(
                        manualTimes, _dailyDosage, true),
                  ),

                const SizedBox(height: 16),
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
                        _autoPreviewDays = previewAutomaticUsageDays(
                          isEveryDay: _isEveryDay,
                          isAutomaticDayMode: v == ScheduleMode.automatic,
                          autoDaysPerWeek: _autoDaysPerWeek,
                          startWeekday: _startDate.weekday,
                        );
                        if (v == ScheduleMode.manual) {
                          _usageDays = [];
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
                          // promote to every-day if all days picked
                          if (_usageDays.length >= 7) {
                            _isEveryDay = true;
                            _usageDays = [];
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      '7 gün seçildi: Her gün olarak ayarlandı.')),
                            );
                          }
                        });
                      },
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

                const SizedBox(height: 16),
                MedicationMealInfo(
                  isAfterMeal: _isAfterMeal,
                  onChanged: (value) => setState(() => _isAfterMeal = value),
                  hoursBeforeOrAfterMeal: _hoursBeforeOrAfterMeal,
                  onSliderChanged: (value) =>
                      setState(() => _hoursBeforeOrAfterMeal = value.toInt()),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
