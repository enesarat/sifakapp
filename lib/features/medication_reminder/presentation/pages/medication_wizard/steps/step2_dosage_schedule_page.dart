import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/validations/validator.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/medication_wizard_state.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/widgets/wizard_progress_header.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/widgets/widgets.dart';
import 'package:sifakapp/features/medication_reminder/presentation/utils/schedule_utils.dart';
import 'package:sifakapp/features/medication_reminder/presentation/utils/time_utils.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/wizard_palette.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';
import 'package:sifakapp/core/navigation/app_route_paths.dart';

class Step2DosageSchedulePage extends StatefulWidget {
  const Step2DosageSchedulePage({super.key, this.wiz});

  final MedicationWizardState? wiz;

  @override
  State<Step2DosageSchedulePage> createState() => _Step2DosageSchedulePageState();
}

class _Step2DosageSchedulePageState extends State<Step2DosageSchedulePage> {
  MedicationWizardState? _wiz;

  @override
  void initState() {
    super.initState();
    _wiz = widget.wiz;
  }

  bool get _isValid {
    if (_wiz == null) return false;
    // Validate times if manual time schedule is selected
    final manualTimeError = Validator.validateManualTime(
      _wiz!.manualTimes,
      _wiz!.dailyDosage,
      _wiz!.timeScheduleMode == ScheduleMode.manual,
    );

    String? usageDaysError;
    if (!_wiz!.isEveryDay) {
      if (_wiz!.dayScheduleMode == ScheduleMode.manual) {
        usageDaysError = Validator.validateUsageDays(
          isEveryDay: _wiz!.isEveryDay,
          isManualDayMode: true,
          selectedDays: _wiz!.usageDays,
        );
      } else {
        usageDaysError = Validator.validateUsageDays(
          isEveryDay: _wiz!.isEveryDay,
          isManualDayMode: false,
          selectedDays: const [],
          autoDaysPerWeek: _wiz!.autoDaysPerWeek,
        );
      }
    }

    return manualTimeError == null && usageDaysError == null;
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final initial = _wiz!.startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() {
        _wiz!.setStartDate(picked);
        _wiz!.autoPreviewDays = previewAutomaticUsageDays(
          isEveryDay: _wiz!.isEveryDay,
          isAutomaticDayMode: _wiz!.dayScheduleMode == ScheduleMode.automatic,
          autoDaysPerWeek: _wiz!.autoDaysPerWeek,
          startWeekday: _wiz!.startDate.weekday,
        );
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial = _wiz!.endDate ?? _wiz!.startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) setState(() => _wiz!.setEndDate(picked));
  }

  Future<void> _pickManualTime(int index) async {
    // Use evenly spaced suggestions as defaults for each slot
    final suggestions = generateEvenlySpacedTimes(_wiz!.dailyDosage);
    final suggested = (index < suggestions.length)
        ? suggestions[index]
        : const TimeOfDay(hour: 8, minute: 0);
    final current = (_wiz!.manualTimes.length > index)
        ? _wiz!.manualTimes[index]
        : suggested;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null && mounted) setState(() => _wiz!.setManualTime(index, picked));
  }

  void _goNext() {
    // Path sabiti ile extra taşı
    context.push(AppRoutePaths.medicationsNewStep3, extra: _wiz);
  }

  @override
  Widget build(BuildContext context) {
    // Guard: if wizard state missing, guide user back to step1
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
          child: FilledButton(style: FilledButton.styleFrom(backgroundColor: WizardPalette.primary),
            onPressed: () => const MedicationWizardStep1Route().replace(context),
            child: const Text('Akışı Baştan Başlat'),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final autoTimes = generateEvenlySpacedTimes(_wiz!.dailyDosage);
    final dayLabels = const ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final previewDays = previewAutomaticUsageDays(
      isEveryDay: _wiz!.isEveryDay,
      isAutomaticDayMode: _wiz!.dayScheduleMode == ScheduleMode.automatic,
      autoDaysPerWeek: _wiz!.autoDaysPerWeek,
      startWeekday: _wiz!.startDate.weekday,
    );

    final cs = Theme.of(context).colorScheme;
    final accent = WizardPalette.primary;
    return Scaffold(
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
            child: FilledButton(style: FilledButton.styleFrom(backgroundColor: WizardPalette.primary),
              onPressed: _isValid ? _goNext : null,
              child: const Text('İlerle'),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardProgressHeader(activeStep: 2),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: MedicationStartDateField(
                    startDate: _wiz!.startDate,
                    onPickDate: _pickStartDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MedicationEndDateField(
                    endDate: _wiz!.endDate,
                    onPickDate: _pickEndDate,
                    onClear: () => setState(() => _wiz!.setEndDate(null)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ScheduleModeSelector(
              title: 'Günlük Plan',
              value: _wiz!.timeScheduleMode,
              onChanged: (v) => setState(() => _wiz!.setTimeScheduleMode(v)),
            ),
            const SizedBox(height: 8),
            // Daily dosage slider with content area below
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Günlük Doz Sayısı'),
                      Text(_wiz!.dailyDosage.toString(), style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Slider(value: _wiz!.dailyDosage.toDouble(), min: 1, max: 10, divisions: 9, activeColor: accent, thumbColor: accent,
                    onChanged: (v) => setState(() => _wiz!.setDailyDosage(v.toInt())),
                  ),
                  const SizedBox(height: 8),
                  if (_wiz!.timeScheduleMode == ScheduleMode.automatic) ...[
                    Text('Örnek Saatler',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in autoTimes)
                          Chip(
                            label: Text(t.format(context)),
                            backgroundColor: accent.withOpacity(0.12),
                            labelStyle: TextStyle(color: accent),
                          ),
                      ],
                    ),
                  ] else ...[
                    MedicationTimePicker(
                      manualTimes: _wiz!.manualTimes,
                      onPickTime: _pickManualTime,
                      dailyDosage: _wiz!.dailyDosage,
                      validator: (times) => Validator.validateManualTime(
                          times, _wiz!.dailyDosage, true),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            MedicationEveryDaySwitch(
              isEveryDay: _wiz!.isEveryDay,
              onChanged: (v) {
                setState(() {
                  _wiz!.setEveryDay(v);
                  _wiz!.autoPreviewDays = previewAutomaticUsageDays(
                    isEveryDay: _wiz!.isEveryDay,
                    isAutomaticDayMode: _wiz!.dayScheduleMode == ScheduleMode.automatic,
                    autoDaysPerWeek: _wiz!.autoDaysPerWeek,
                    startWeekday: _wiz!.startDate.weekday,
                  );
                });
              },
            ),
            if (!_wiz!.isEveryDay) ...[
              ScheduleModeSelector(
                title: 'Gün Planı',
                value: _wiz!.dayScheduleMode,
                onChanged: (v) {
                  setState(() {
                    _wiz!.setDayScheduleMode(v);
                    _wiz!.autoPreviewDays = previewAutomaticUsageDays(
                      isEveryDay: _wiz!.isEveryDay,
                      isAutomaticDayMode: v == ScheduleMode.automatic,
                      autoDaysPerWeek: _wiz!.autoDaysPerWeek,
                      startWeekday: _wiz!.startDate.weekday,
                    );
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _wiz!.dayScheduleMode == ScheduleMode.automatic
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Gün Sayısı'),
                              Text('${_wiz!.autoDaysPerWeek}',
                                  style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Slider(
                            value: _wiz!.autoDaysPerWeek.toDouble(),
                            min: 1,
                            max: 6,
                            divisions: 5,
                            onChanged: (v) => setState(() {
                              _wiz!.setAutoDaysPerWeek(v.toInt());
                              _wiz!.autoPreviewDays = previewAutomaticUsageDays(
                                isEveryDay: _wiz!.isEveryDay,
                                isAutomaticDayMode:
                                    _wiz!.dayScheduleMode == ScheduleMode.automatic,
                                autoDaysPerWeek: _wiz!.autoDaysPerWeek,
                                startWeekday: _wiz!.startDate.weekday,
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text('Otomatik Günler',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final d in previewDays)
                                Chip(
                                  label: Text(dayLabels[d - 1]),
                                  backgroundColor: accent.withOpacity(0.12),
                                  labelStyle:
                                      TextStyle(color: accent),
                                ),
                            ],
                          ),
                        ],
                      )
                    : MedicationUsageDaysPicker(
                        selectedDays: _wiz!.usageDays,
                        onChanged: (days) => setState(() => _wiz!.setUsageDays(days)),
                        validator: (days) => Validator.validateUsageDays(
                          isEveryDay: _wiz!.isEveryDay,
                          isManualDayMode: true,
                          selectedDays: days,
                        ),
                      ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}















