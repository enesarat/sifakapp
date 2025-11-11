import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/validations/validator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_event.dart' as ev;
import 'package:sifakapp/features/medication_reminder/presentation/blocs/medication/medication_state.dart' as st;
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/medication_wizard_state.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/widgets/medication_preview_dialog.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/widgets/wizard_progress_header.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/widgets/widgets.dart';
import 'package:sifakapp/features/medication_reminder/presentation/utils/time_utils.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/wizard_palette.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';

class Step3ReminderPage extends StatefulWidget {
  const Step3ReminderPage({super.key, this.wiz});

  final MedicationWizardState? wiz;

  @override
  State<Step3ReminderPage> createState() => _Step3ReminderPageState();
}

class _Step3ReminderPageState extends State<Step3ReminderPage> {
  final _formKey = GlobalKey<FormState>();
  MedicationWizardState? _wiz;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _wiz = widget.wiz;
  }

  bool get _isCapsuleSelected =>
      _wiz?.selectedCategoryKey == MedicationCategoryKey.oralCapsule;

  Future<void> _pickExpirationDate() async {
    final now = DateTime.now();
    final initial =
        _wiz!.expirationDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
      builder: (ctx, child) {
        final base = Theme.of(ctx);
        final accent = WizardPalette.primary;
        final purple = base.copyWith(
          colorScheme: base.colorScheme.copyWith(primary: accent),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: accent,
            selectionColor: WizardPalette.primarySelection,
            selectionHandleColor: accent,
          ),
          inputDecorationTheme: base.inputDecorationTheme.copyWith(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(width: 2, color: accent),
            ),
          ),
          datePickerTheme: base.datePickerTheme.copyWith(
            headerForegroundColor: accent,
            dividerColor: accent,
          ),
          timePickerTheme: base.timePickerTheme.copyWith(
            hourMinuteTextColor: accent,
            dayPeriodTextColor: accent,
            dialHandColor: accent,
            hourMinuteColor: accent.withOpacity(0.12),
            dayPeriodColor: accent.withOpacity(0.12),
          ),
        );
        return Theme(data: purple, child: child!);
      },
    );
    if (picked != null && mounted) {
      setState(() => _wiz!.setExpirationDate(picked));
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_wiz == null) return;

    final confirm = await showMedicationPreviewDialog(
      context,
      wiz: _wiz!,
      accent: WizardPalette.primary,
    );
    if (confirm == true) {
      _createMedication();
    }
  }

  void _createMedication() {
    if (_wiz == null || _saving) return;
    setState(() => _saving = true);

    // Usage days resolution
    List<int>? usageDaysForSave;
    if (_wiz!.isEveryDay) {
      usageDaysForSave = null;
    } else if (_wiz!.dayScheduleMode == ScheduleMode.manual) {
      usageDaysForSave = (_wiz!.usageDays..sort());
    } else {
      // Distribute across the week starting from start date
      final count = _wiz!.autoDaysPerWeek.clamp(1, 6);
      final start = _wiz!.startDate.weekday;
      final step = 7 / count;
      final set = <int>{};
      for (int i = 0; i < count; i++) {
        final offset = (i * step).round();
        final day = ((start - 1 + offset) % 7) + 1;
        set.add(day);
      }
      var cursor = start;
      while (set.length < count) {
        cursor = (cursor % 7) + 1;
        set.add(cursor);
      }
      usageDaysForSave = set.toList()..sort();
    }

    final totalPills = int.tryParse(_wiz!.pillsController.text) ?? 0;
    final remainingPills = totalPills;

    final times = _wiz!.timeScheduleMode == ScheduleMode.manual
        ? _wiz!.manualTimes
        : generateEvenlySpacedTimes(_wiz!.dailyDosage);

    final medication = Medication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _wiz!.nameController.text.trim(),
      diagnosis: _wiz!.diagnosisController.text.trim(),
      type: _wiz!.selectedCategoryKey?.value ?? '',
      startDate: _wiz!.startDate,
      endDate: _wiz!.endDate,
      expirationDate: _wiz!.expirationDate,
      totalPills: totalPills,
      remainingPills: remainingPills,
      dailyDosage: _wiz!.dailyDosage,
      timeScheduleMode: _wiz!.timeScheduleMode,
      dayScheduleMode: _wiz!.dayScheduleMode,
      isEveryDay: _wiz!.isEveryDay,
      usageDays: usageDaysForSave,
      reminderTimes:
          _wiz!.timeScheduleMode == ScheduleMode.manual ? times : null,
      hoursBeforeOrAfterMeal: _wiz!.hoursBeforeOrAfterMeal,
      isAfterMeal: _wiz!.isAfterMeal,
    );

    context.read<MedicationBloc>().add(ev.AddMedication(medication));
  }

  @override
  Widget build(BuildContext context) {
    if (_wiz == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          title: const Text('İlaç Ekle'),
          centerTitle: true,
        ),
        body: Center(
          child: FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: WizardPalette.primary),
            onPressed: () => context.pop(),
            child: const Text('Akışı Baştan Başlat'),
          ),
        ),
      );
    }
    final cs = Theme.of(context).colorScheme;

    return BlocListener<MedicationBloc, st.MedicationState>(
      listenWhen: (prev, curr) =>
          curr is st.MedicationCreated || curr is st.MedicationError,
      listener: (context, state) {
        if (state is st.MedicationCreated) {
          if (!mounted) return;
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt eklendi.')),
          );
          const HomeRoute().go(context);
        } else if (state is st.MedicationError) {
          if (!mounted) return;
          setState(() => _saving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          title: const Text('İlaç Ekle'),
          centerTitle: true,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: WizardPalette.primary),
                onPressed: _saving ? null : _onSave,
                child: Text(_saving ? 'Kaydediliyor…' : 'Kaydet'),
              ),
            ),
          ),
        ),
        body: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: WizardPalette.primary),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: WizardPalette.primary,
              selectionColor: WizardPalette.primarySelection,
              selectionHandleColor: WizardPalette.primary,
            ),
            inputDecorationTheme: Theme.of(context).inputDecorationTheme
                .copyWith(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(width: 2, color: WizardPalette.primary),
              ),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WizardProgressHeader(activeStep: 3),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Text('Stok Takibi',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  MedicationPillsField(
                    controller: _wiz!.pillsController,
                    validator: Validator.validatePills,
                    labelText: _isCapsuleSelected
                        ? 'Toplam Hap Sayısı'
                        : 'Toplam Doz Sayısı',
                  ),
                  const SizedBox(height: 16),
                  MedicationExpirationDate(
                    expirationDate: _wiz!.expirationDate,
                    onPickDate: _pickExpirationDate,
                    onClear: () =>
                        setState(() => _wiz!.setExpirationDate(null)),
                  ),
                  const SizedBox(height: 16),
                  MedicationMealInfo(
                    isAfterMeal: _wiz!.isAfterMeal,
                    hoursBeforeOrAfterMeal: _wiz!.hoursBeforeOrAfterMeal,
                    onChanged: (v) => setState(() => _wiz!.setMealAfter(v)),
                    onSliderChanged: (v) =>
                        setState(() => _wiz!.setMealHours(v.toInt())),
                    accentColor: WizardPalette.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
