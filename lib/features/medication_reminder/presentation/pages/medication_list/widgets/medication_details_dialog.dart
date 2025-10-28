import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/navigation/app_routes.dart';
import '../../../../domain/entities/medication.dart';
import '../../../../domain/entities/medication_category.dart';
import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_event.dart';
import '../../../blocs/medication/medication_state.dart';
import 'confirm_delete_medication_dialog.dart';
import '../../../../application/plan/auto_time_util.dart';

class MedicationDetailsDialog extends StatefulWidget {
  const MedicationDetailsDialog({super.key, required this.id, this.medication});

  final String id;
  final Medication? medication;

  @override
  State<MedicationDetailsDialog> createState() => _MedicationDetailsDialogState();
}

class _MedicationDetailsDialogState extends State<MedicationDetailsDialog> {
  bool _isDeleting = false;

  Medication get _med => widget.medication!;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final primaryLight = const Color(0xFFE7F8FE);
    final dividerColor = Theme.of(context).dividerColor.withOpacity(0.2);

    return BlocListener<MedicationBloc, MedicationState>(
      listenWhen: (prev, curr) => curr is MedicationDeleted || curr is MedicationError,
      listener: (ctx, state) {
        if (state is MedicationDeleted && state.id == _med.id) {
          Navigator.of(ctx, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İlaç silindi.')),
          );
        } else if (state is MedicationError) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF101D22)
            : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 520,
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48, height: 48),
                        Text(
                          'İlaç Detayı',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Diagnosis + Name
                    Column(
                      children: [
                        Text(
                          _med.diagnosis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF4C869A),
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _med.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Icon + planned times (top area)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? primary.withOpacity(0.12)
                                  : primaryLight,
                              shape: BoxShape.circle,
                              // shadow removed per request
                            ),
                            child: Icon(
                              _iconForMedication(_med),
                              color: primary,
                              size: 64,
                            ),
                          ),
                          const SizedBox(width: 28),
                          Flexible(child: _PlannedTimesList(times: _getPlannedTimes(_med))),
                        ],
                      ),
                    ),

                    // Stats (daha kompakt yükseklik, daha geniş kutular)
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Toplam Doz',
                            value: _med.totalPills.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            label: 'Kalan Doz',
                            value: _med.remainingPills.toString(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(color: dividerColor),

                    // Details list
                    _detailItem(
                      context,
                      label: 'Tarih Aralığı',
                      value: _formatDateRange(_med.startDate, _med.endDate),
                    ),
                    _detailItem(
                      context,
                      label: 'Günlük Doz',
                      value: 'Günde ${_med.dailyDosage} kez, 1 tablet',
                    ),
                    // Planlama bilgisi (günler)
                    _planlamaItem(context),
                    if (_med.isAfterMeal != null)
                      _detailItem(
                        context,
                        label: 'Yemek İlişkisi',
                        value: _formatMeal(_med),
                      ),

                    const SizedBox(height: 8),
                    Divider(color: dividerColor),
                    const SizedBox(height: 12),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: _PrimaryButton(
                            label: 'Düzenle',
                            onPressed: _isDeleting
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                    Future.microtask(() => context.push(
                                          MedicationEditRoute(id: _med.id).location,
                                          extra: _med,
                                        ));
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DangerButton(
                            label: 'Sil',
                            onPressed: _isDeleting
                                ? null
                                : () async {
                                    final confirmed = await showConfirmDeleteMedicationDialog(
                                      context,
                                      med: _med,
                                    );
                                    if (confirmed == true && mounted) {
                                      setState(() => _isDeleting = true);
                                      context.read<MedicationBloc>().add(RemoveMedication(_med.id));
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_isDeleting)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF4C869A),
          fontWeight: FontWeight.w600,
        );
    final valueStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: labelStyle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _planlamaItem(BuildContext context) {
    if (_med.isEveryDay) {
      return _detailItem(context, label: 'Planlama', value: 'Her gün');
    }
    final days = _med.usageDays ?? const <int>[];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'Planlama',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4C869A),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: days
                .map((d) => _DayChip(label: _turkishDayLetter(d)))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2F34) : const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(26),
      ),
      constraints: const BoxConstraints(minHeight: 52),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4C869A),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannedTimesList extends StatelessWidget {
  const _PlannedTimesList({required this.times});
  final List<TimeOfDay> times;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFFAB70);
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: accent,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final t in times)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, color: accent, size: 20),
                const SizedBox(width: 8),
                Text(t.format(context), style: textStyle),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final primaryLight = const Color(0xFFE7F8FE);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 32,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? primary.withOpacity(0.12) : primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isDark ? primaryLight : primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.red.withOpacity(0.12) : const Color(0xFFE7F0F3);
    final fg = isDark ? Colors.red.shade300 : const Color(0xFFD0021B);
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// -------------------------
// Helpers
// -------------------------

List<TimeOfDay> _getPlannedTimes(Medication m) {
  if (m.timeScheduleMode == ScheduleMode.manual && m.reminderTimes != null && m.reminderTimes!.isNotEmpty) {
    final list = List<TimeOfDay>.from(m.reminderTimes!);
    list.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    return list;
  }
  final minutes = autoDistributeTimes(m.dailyDosage)..sort();
  return minutes.map((mm) => TimeOfDay(hour: mm ~/ 60, minute: mm % 60)).toList();
}

String _formatDateRange(DateTime start, DateTime? end) {
  final s = _formatDate(start);
  final e = end != null ? _formatDate(end) : '—';
  return '$s - $e';
}

String _formatDate(DateTime dt) {
  final d = dt.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yy = (d.year % 100).toString().padLeft(2, '0');
  return '$dd.$mm.$yy';
}

String _formatMeal(Medication m) {
  final suffix = (m.hoursBeforeOrAfterMeal != null && m.hoursBeforeOrAfterMeal != 0)
      ? ' ${m.hoursBeforeOrAfterMeal} sa'
      : '';
  if (m.isAfterMeal == null) return '—';
  return m.isAfterMeal! ? 'Tok karnına$suffix' : 'Aç karnına$suffix';
}

String _turkishDayLetter(int weekday) {
  // 1=Mon..7=Sun
  switch (weekday) {
    case DateTime.monday:
      return 'Pt'; // Pazartesi
    case DateTime.tuesday:
      return 'Sa'; // Salı
    case DateTime.wednesday:
      return 'Çr'; // Çarşamba
    case DateTime.thursday:
      return 'Pe'; // Perşembe
    case DateTime.friday:
      return 'Cu'; // Cuma
    case DateTime.saturday:
      return 'Ct'; // Cumartesi
    case DateTime.sunday:
      return 'Pa'; // Pazar
    default:
      return '?';
  }
}

// --- Icon helpers (match type dropdown mapping) ---
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
  if (containsAny(const ['solüsyon', 'solution', 'çözelti', 'cozelti'])) {
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
