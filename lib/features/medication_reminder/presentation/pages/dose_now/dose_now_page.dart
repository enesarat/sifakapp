import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui' show BlendMode;

import 'package:sifakapp/core/ui/spacing.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';

import '../../../domain/entities/medication.dart';
import '../../../domain/entities/medication_category.dart';
import '../../../domain/entities/dose_log.dart' as dlog;
import '../../../domain/use_cases/catalog/get_all_medication_categories.dart';
import '../../../application/plan/plan_builder.dart';
import '../../blocs/medication/medication_bloc.dart';
import '../../blocs/medication/medication_state.dart' as st;
import '../../widgets/frosted_blob_background.dart';
import '../../widgets/floating_top_nav_bar.dart';
import '../../widgets/glass_floating_nav_bar.dart';
import '../../widgets/floating_nav_bar.dart' show NavTab;
import '../../../domain/repositories/dose_log_repository.dart';

class DoseNowPage extends StatefulWidget {
  const DoseNowPage({super.key});

  @override
  State<DoseNowPage> createState() => _DoseNowPageState();
}

class _DoseNowPageState extends State<DoseNowPage> {
  final _getCats = GetIt.I<GetAllMedicationCategories>();
  List<MedicationCategory> _categories = const [];
  MedicationCategoryKey? _selectedKey;
  bool _loadingCats = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _getCats();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _selectedKey = cats.isNotEmpty ? cats.first.key : null; // default
        _loadingCats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = const [];
        _selectedKey = null;
        _loadingCats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          const Positioned.fill(child: FrostedBlobBackground()),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const FloatingTopNavBar(title: 'Dozu Şimdi Kullan'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Kategori',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: _loadingCats
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, i) {
                              final c = _categories[i];
                              final selected = c.key == _selectedKey;
                              final isLight = Theme.of(context).brightness == Brightness.light;
                              final bg = isLight
                                  ? Colors.white.withOpacity(0.55)
                                  : Theme.of(context).colorScheme.surface.withOpacity(0.50);
                              final borderColor = selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white.withOpacity(isLight ? 0.25 : 0.12);
                              return GestureDetector(
                                onTap: () => setState(() => _selectedKey = c.key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                        color: selected ? borderColor : Colors.transparent),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(_iconForCategoryKey(c.key),
                                          color: Theme.of(context).iconTheme.color, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        c.label.split('(').first.trim(),
                                        style: TextStyle(
                                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                          color: selected
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemCount: _categories.length,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double kTopFade = 12.0; // px, match History
                        return ShaderMask(
                          shaderCallback: (rect) {
                            final h = rect.height == 0 ? 1.0 : rect.height;
                            final t = (kTopFade / h).clamp(0.0, 1.0);
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: const [
                                Color(0x00000000), // transparent
                                Color(0xFF000000), // opaque
                                Color(0xFF000000),
                              ],
                              stops: [0.0, t, 1.0],
                            ).createShader(Rect.fromLTWH(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: Padding(
                            padding: AppSpacing.pageInsets(context: context, top: 0, bottom: 0),
                            child: _DoseList(selectedKey: _selectedKey, topPadding: kTopFade),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: GlassFloatingNavBar(selected: NavTab.dose),
          ),
        ],
      ),
    );
  }
}

class _DoseList extends StatelessWidget {
  const _DoseList({required this.selectedKey, this.topPadding = 0});
  final MedicationCategoryKey? selectedKey;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationBloc, st.MedicationState>(
      builder: (context, state) {
        if (selectedKey == null) return const SizedBox.shrink();
        if (state is st.MedicationLoading || state is st.MedicationInitial) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state is! st.MedicationLoaded) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        final tomorrowStart = start.add(const Duration(days: 1));
        final tomorrowEnd = end.add(const Duration(days: 1));

        final entries = <_DoseEntry>[];
        for (final m in state.medications) {
          final key = _deriveCategoryKeyFromType(m.type);
          if (key != selectedKey) continue;

          // Build today's occurrences and filter out times before creation time (same-day creation)
          final plan = PlanBuilder.buildOneOffHorizon(m, from: start, to: end);
          DateTime? createdAt;
          final idMillis = int.tryParse(m.id);
          if (idMillis != null) {
            createdAt = DateTime.fromMillisecondsSinceEpoch(idMillis);
          }
          for (final o in plan.oneOffs) {
            final at = o.scheduledAt;
            if (at.isBefore(start) || at.isAfter(end)) continue;
            // If medication created today after some slots, skip earlier ones
            final createdSameDay = createdAt != null &&
                createdAt.year == start.year &&
                createdAt.month == start.month &&
                createdAt.day == start.day;
            if (createdSameDay && !at.isAfter(createdAt)) {
              continue;
            }
            entries.add(_DoseEntry(med: m, at: at));
          }

          // If startDate is tomorrow, also surface tomorrow's entries as preview (disabled action)
          final sd = m.startDate;
          final isTomorrowStart = sd.year == tomorrowStart.year &&
              sd.month == tomorrowStart.month &&
              sd.day == tomorrowStart.day;
          if (isTomorrowStart) {
            final tomorrowPlan = PlanBuilder.buildOneOffHorizon(m, from: tomorrowStart, to: tomorrowEnd);
            for (final o in tomorrowPlan.oneOffs) {
              final at = o.scheduledAt;
              if (at.isBefore(tomorrowStart) || at.isAfter(tomorrowEnd)) continue;
              entries.add(_DoseEntry(med: m, at: at));
            }
          }
        }

        entries.sort((a, b) => a.at.compareTo(b.at));

        if (entries.isEmpty) {
          return Center(
            child: Text(
              'Bugün bu kategoride planlı doz yok',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75)),
            ),
          );
        }

        final logs = GetIt.I<DoseLogRepository>();
        return StreamBuilder<List<dlog.DoseLog>>(
          stream: logs.watchInRange(start, end),
          builder: (context, snap) {
            final data = snap.data ?? const <dlog.DoseLog>[];
            final byId = <String, dlog.DoseLogStatus>{};
            for (final l in data) {
              byId[_logId(l.medId, l.plannedAt)] = l.status;
            }
            return ListView.separated(
              padding: EdgeInsets.only(top: topPadding, bottom: 140),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final e = entries[i];
                final st = byId[_logId(e.med.id, e.at)];
                return _DoseCard(entry: e, status: st);
              },
            );
          },
        );
      },
    );
  }
}

class _DoseCard extends StatelessWidget {
  const _DoseCard({required this.entry, this.status});
  final _DoseEntry entry;
  final dlog.DoseLogStatus? status;

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _mealLabel(Medication m) {
    if (m.isAfterMeal == true) return 'Yemekten sonra';
    if (m.isAfterMeal == false) return 'Aç karına';
    return 'Yemekle ilişkisi yok';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final key = _deriveCategoryKeyFromType(entry.med.type) ?? MedicationCategoryKey.oralCapsule;
    final icon = _iconForCategoryKey(key);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final glass = isLight ? Colors.white.withOpacity(0.55) : cs.surface.withOpacity(0.55);
    final borderColor = Colors.white.withOpacity(isLight ? 0.30 : 0.15);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.med.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_mealLabel(entry.med)} • Öğün başına 1 doz',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fmt(entry.at),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.w300, letterSpacing: 3),
              ),
              _ActionButton(cs: cs, entry: entry, status: status),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.cs, required this.entry, this.status});
  final ColorScheme cs;
  final _DoseEntry entry;
  final dlog.DoseLogStatus? status;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final tomorrowEnd = DateTime(tomorrowStart.year, tomorrowStart.month, tomorrowStart.day, 23, 59, 59, 999);

    if (status == dlog.DoseLogStatus.taken) {
      return _pillButton(
        label: 'Kullanıldı',
        bg: Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white10,
        fg: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70,
        enabled: false,
      );
    }
    if (status == dlog.DoseLogStatus.missed || status == dlog.DoseLogStatus.passed) {
      return _pillButton(
        label: status == dlog.DoseLogStatus.passed ? 'Pas geçildi' : 'Kaçırıldı',
        bg: Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white10,
        fg: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white70,
        enabled: false,
      );
    }

    // If this occurrence is tomorrow, show disabled 'Yarın' button in pastel dark blue
    final at = entry.at;
    final isTomorrow = !at.isBefore(tomorrowStart) && !at.isAfter(tomorrowEnd);
    if (isTomorrow) {
      final blue = Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF5C6BC0) // Indigo 400
          : const Color(0xFF3949AB); // Indigo 600 for dark
      return _pillButton(
        label: 'Yarın',
        bg: blue,
        fg: Colors.white,
        enabled: false,
      );
    }
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () => DoseIntakeRoute(id: entry.med.id, occurrenceAt: entry.at).go(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: const Text('Kullan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _pillButton({required String label, required Color bg, required Color fg, required bool enabled}) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: enabled ? () {} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _DoseEntry {
  final Medication med;
  final DateTime at;
  const _DoseEntry({required this.med, required this.at});
}

// --- Icon helpers ---
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

String _logId(String medId, DateTime at) {
  final y = at.year.toString().padLeft(4, '0');
  final m = at.month.toString().padLeft(2, '0');
  final d = at.day.toString().padLeft(2, '0');
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return '$medId@$y$m$d$hh$mm';
}
