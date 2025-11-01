import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
// import 'package:sifakapp/core/navigation/app_routes.dart';
import 'package:sifakapp/core/navigation/app_route_paths.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';

import '../../../domain/entities/medication.dart';
import '../../../domain/use_cases/get_all_medications.dart';
import '../../../application/plan/plan_builder.dart';
import '../../utils/time_utils.dart';
import '../../blocs/medication/medication_bloc.dart';
import '../../blocs/medication/medication_event.dart' as ev;
import '../../blocs/medication/medication_state.dart' as st;
import '../../../domain/entities/medication_category.dart';
import '../../../domain/use_cases/catalog/get_medication_category_by_key.dart';
import 'widgets/confirm_skip_dialog.dart';

class DoseIntakePage extends StatefulWidget {
  final String id;
  final DateTime? occurrenceAt;
  const DoseIntakePage({super.key, required this.id, this.occurrenceAt});

  @override
  State<DoseIntakePage> createState() => _DoseIntakePageState();
}

class _DoseIntakePageState extends State<DoseIntakePage> {
  Medication? _med;
  bool _loading = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _resolveMedication();
  }

  Future<void> _resolveMedication() async {
    // Try from current bloc state first
    final state = context.read<MedicationBloc>().state;
    if (state is st.MedicationLoaded) {
      final found = state.medications.where((m) => m.id == widget.id).toList();
      if (found.isNotEmpty) {
        setState(() {
          _med = found.first;
          _loading = false;
        });
        return;
      }
    }
    // Fallback: load via use case
    final getAll = GetIt.I<GetAllMedications>();
    final meds = await getAll();
    final found = meds.where((m) => m.id == widget.id).toList();
    setState(() {
      _med = found.isNotEmpty ? found.first : null;
      _loading = false;
    });
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  List<String> _weekdayLabels(Medication m) {
    if (m.isEveryDay) return ['Her gün'];
    final days = (m.usageDays ?? const []).toList()..sort();
    const map = {1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cmt', 7: 'Paz'};
    return days.map((d) => map[d] ?? d.toString()).toList();
  }

  List<String> _timeLabels(Medication m) {
    if (m.timeScheduleMode == ScheduleMode.manual && m.reminderTimes != null) {
      return m.reminderTimes!
          .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
          .toList();
    }
    final auto = generateEvenlySpacedTimes(m.dailyDosage);
    return auto
        .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList();
  }

  DateTime? _nextOccurrence(Medication m) {
    final now = DateTime.now();
    final plan = PlanBuilder.buildOneOffHorizon(m, from: now, to: now.add(const Duration(days: 7)));
    return plan.oneOffs.isNotEmpty ? plan.oneOffs.first.scheduledAt : null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicationBloc, st.MedicationState>(
      listener: (ctx, state) async {
        if (state is st.DoseConsumed) {
          final next = _nextOccurrence(state.medication);
          if (next != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sonraki doz: ${_fmtTime(next)}')),
            );
          }
          await Future.delayed(const Duration(milliseconds: 300));
          _scheduleGoHome();
        } else if (state is st.DoseSkipped) {
          _scheduleGoHome();
        } else if (state is st.MedicationError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() => _processing = false);
          }
        }
      },
      child: Theme(
        data: _doseGreenTheme(context),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const SizedBox.shrink(),
            actions: [
              IconButton(
                tooltip: 'Kapat',
                icon: const Icon(Icons.close),
                onPressed: () => const HomeRoute().go(context),
              ),
            ],
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : (_med == null)
                  ? const Center(child: Text('Kayıt bulunamadı'))
                  : _buildContent(context, _med!),
        ),
      ),
    );
  }

  void _scheduleGoHome() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      const HomeRoute().go(context);
    });
  }

  ThemeData _doseGreenTheme(BuildContext context) {
    const primaryGreen = Color(0xFF4CAF50); // istenen yeşil ton (#4CAF50)
    final base = Theme.of(context);
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: base.brightness,
    );
    final schemeFixed = scheme.copyWith(primary: primaryGreen);
    return base.copyWith(
      colorScheme: schemeFixed,
      primaryColor: primaryGreen,
      appBarTheme: base.appBarTheme.copyWith(
        // Bu ekranda AppBar arka planı genel arka plan ile aynı olsun
        backgroundColor: base.scaffoldBackgroundColor,
        foregroundColor: schemeFixed.onSurface,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return schemeFixed.primary.withOpacity(0.5);
            }
            return schemeFixed.primary;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStateProperty.all(
            base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(56)),
        ),
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        behavior: SnackBarBehavior.floating,
        backgroundColor: schemeFixed.surfaceVariant,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: schemeFixed.onSurface,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: base.brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF2D2F34),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Medication med) {
    final canConsume = med.remainingPills > 0 && !_processing;

    final plannedAt = widget.occurrenceAt ?? _nextOccurrence(med);
    final plannedText = plannedAt != null ? _fmtTime(plannedAt) : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconHero(medication: med),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          med.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: FutureBuilder<String?>(
                          future: _friendlyTypeLabel(med),
                          builder: (ctx, snap) {
                            final label = snap.data;
                            return Text(
                              label ?? med.type,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  ),
                            );
                          },
                        ),
                      ),
                      if (plannedText != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Planlanan saat: $plannedText',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Buttons
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: canConsume
                          ? () {
                              setState(() => _processing = true);
                              context.read<MedicationBloc>().add(
                                    ev.ConsumeMedicationDose(
                                      med.id,
                                      occurrenceAt: widget.occurrenceAt,
                                    ),
                                  );
                            }
                          : null,
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                      ),
                      child: _processing
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Dozu aldım',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: _processing
                          ? null
                          : () async {
                              final ok = await showConfirmSkipDoseDialog(context);
                              if (ok == true) {
                                setState(() => _processing = true);
                                // Skip
                                context.read<MedicationBloc>().add(
                                      ev.SkipMedicationDose(
                                        med.id,
                                        occurrenceAt: widget.occurrenceAt,
                                      ),
                                    );
                              }
                            },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          final scheme = Theme.of(context).colorScheme;
                          if (states.contains(WidgetState.disabled)) {
                            return scheme.surfaceVariant.withOpacity(0.6);
                          }
                          return scheme.surfaceVariant;
                        }),
                        foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                      ),
                      child: const Text(
                        'Atla',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _friendlyTypeLabel(Medication m) async {
    final key = _deriveCategoryKeyFromType(m.type);
    if (key == null) return m.type;
    try {
      final getByKey = GetIt.I<GetMedicationCategoryByKey>();
      final cat = await getByKey(key);
      return cat?.label;
    } catch (_) {
      return m.type;
    }
  }
}

class _IconHero extends StatelessWidget {
  const _IconHero({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconData = _iconForMedication(medication);

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft large circle background
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
          // Inner accent circle for depth
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            iconData,
            size: 120,
            color: scheme.primary,
          ),
        ],
      ),
    );
  }
}

// --- Icon helpers (kept consistent with details dialog mapping) ---
IconData _iconForMedication(Medication m) {
  final key = _deriveCategoryKeyFromType(m.type) ?? MedicationCategoryKey.oralCapsule;
  return _iconForCategoryKey(key);
}

MedicationCategoryKey? _deriveCategoryKeyFromType(String value) {
  final v = value.trim();
  final byKey = MedicationCategoryKey.fromValue(v);
  if (byKey != null) return byKey;

  final t = v.toLowerCase();
  bool containsAny(List<String> needles) => needles.any((n) => t.contains(n));

  if (containsAny(const ['kaps', 'tablet', 'hap', 'capsule', 'pill'])) {
    return MedicationCategoryKey.oralCapsule;
  }
  if (containsAny(const ['pomad', 'merhem', 'krem', 'jel'])) {
    return MedicationCategoryKey.topicalSemisolid;
  }
  if (containsAny(const ['enjeks', 'amp', 'flakon', 'iğne', 'igne', 'vial'])) {
    return MedicationCategoryKey.parenteral;
  }
  if (containsAny(const ['şurup', 'surup', 'sirup'])) {
    return MedicationCategoryKey.oralSyrup;
  }
  if (containsAny(const ['süspans', 'suspans'])) {
    return MedicationCategoryKey.oralSuspension;
  }
  if (containsAny(const ['damla', 'drop'])) {
    return MedicationCategoryKey.oralDrops;
  }
  if (containsAny(const ['çözelti', 'cozelti', 'solüsyon', 'solution'])) {
    return MedicationCategoryKey.oralSolution;
  }
  return null;
}

IconData _iconForCategoryKey(MedicationCategoryKey key) {
  switch (key) {
    case MedicationCategoryKey.oralCapsule:
      return Icons.medication_outlined;
    case MedicationCategoryKey.topicalSemisolid:
      return Icons.icecream_outlined;
    case MedicationCategoryKey.parenteral:
      return Icons.vaccines_outlined;
    case MedicationCategoryKey.oralSyrup:
      return Icons.medication_liquid_outlined;
    case MedicationCategoryKey.oralSuspension:
      return Icons.science_outlined;
    case MedicationCategoryKey.oralDrops:
      return Icons.water_drop_outlined;
    case MedicationCategoryKey.oralSolution:
      return Icons.bubble_chart_outlined;
  }
}

