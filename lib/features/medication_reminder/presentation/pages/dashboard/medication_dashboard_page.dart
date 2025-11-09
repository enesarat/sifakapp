import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/navigation/app_routes.dart';
import '../../../../../../core/navigation/app_route_paths.dart';
import '../../../application/plan/plan_builder.dart';
import '../../../domain/entities/medication.dart';
import '../../../domain/entities/medication_category.dart';
import '../../../domain/use_cases/catalog/get_all_medication_categories.dart';
import '../../blocs/medication/medication_bloc.dart';
import '../../blocs/medication/medication_state.dart' as st;
import '../medication_list/widgets/medication_list_item.dart';
// Dashboard uses its own floating nav bar style (not shared)

class MedicationDashboardPage extends StatefulWidget {
  const MedicationDashboardPage({super.key});

  @override
  State<MedicationDashboardPage> createState() => _MedicationDashboardPageState();
}

class _MedicationDashboardPageState extends State<MedicationDashboardPage> {
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
        _selectedKey = cats.isNotEmpty ? cats.first.key : null;
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
          // Soft gradient background
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.18),
                      cs.secondary.withOpacity(0.14),
                      cs.tertiary.withOpacity(0.18),
                    ],
                    stops: const [0.05, 0.55, 0.95],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _Header(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Merhaba!', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Bugüne ait ilaç planın.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75),
                              )),
                    ],
                  ),
                ),

                // Progress Ring
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: _TodayProgressRing(),
                  ),
                ),

                // Category chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('Kategori', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
                                  border: Border.all(color: selected ? borderColor : Colors.transparent),
                                ),
                                child: Row(
                                  children: [
                                    Icon(_iconForCategory(c.key), color: Theme.of(context).iconTheme.color, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.label.split('(').first.trim(),
                                      style: TextStyle(
                                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                        color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color,
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

                // Upcoming dose
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('Gelecek Doz', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ),
                _UpcomingDoseCard(selectedKey: _selectedKey),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // Floating nav bar without SafeArea; positioned with margins
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _DashboardBottomBar(),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final glass = isLight
        ? Colors.white.withOpacity(0.55)
        : cs.surface.withOpacity(0.55);
    final borderColor = Colors.white.withOpacity(isLight ? 0.30 : 0.15);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: glass,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            const SizedBox(width: 6),
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
            Expanded(
              child: Center(
                child: Text('Bugün', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(radius: 18, backgroundColor: cs.primary.withOpacity(0.25), child: const Icon(Icons.person)),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _TodayProgressRing extends StatelessWidget {
  const _TodayProgressRing();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationBloc, st.MedicationState>(
      builder: (context, state) {
        int planned = 0;
        int taken = 0; // TODO: daily taken tracking can populate this

        if (state is st.MedicationLoaded) {
          final today = DateTime.now();
          for (final m in state.medications) {
            if (!_shouldTakeOn(m, today)) continue;
            final times = _plannedTimesCountFor(m);
            planned += times;
          }
        }

        final pct = planned == 0 ? 0.0 : (taken / planned).clamp(0.0, 1.0);

        return _ProgressRing(
          progress: pct,
          size: 188,
          stroke: 14,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(pct * 100).round()}%', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('$taken / $planned Alındı', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
            ],
          ),
        );
      },
    );
  }

  bool _shouldTakeOn(Medication m, DateTime date) {
    if (m.isEveryDay) return true;
    final days = m.usageDays ?? const <int>[];
    return days.contains(date.weekday);
  }

  int _plannedTimesCountFor(Medication m) {
    if (m.timeScheduleMode == ScheduleMode.manual && m.reminderTimes != null) {
      return m.reminderTimes!.length;
    }
    return m.dailyDosage;
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.size, required this.stroke, required this.center});
  final double progress; // 0..1
  final double size;
  final double stroke;
  final Widget center;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: progress,
              stroke: stroke,
              background: Theme.of(context).brightness == Brightness.light
                  ? Colors.white.withOpacity(0.4)
                  : cs.surfaceVariant.withOpacity(0.4),
              color: cs.primary,
            ),
          ),
          center,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double stroke;
  final Color background;
  final Color color;

  _RingPainter({required this.progress, required this.stroke, required this.background, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2 - stroke / 2;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = background;
    canvas.drawCircle(center, radius, bgPaint);

    final sweep = 2 * math.pi * progress;
    final start = -math.pi / 2; // 12 o'clock
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.stroke != stroke || oldDelegate.color != color || oldDelegate.background != background;
  }
}

class _UpcomingDoseCard extends StatelessWidget {
  const _UpcomingDoseCard({required this.selectedKey});
  final MedicationCategoryKey? selectedKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationBloc, st.MedicationState>(builder: (context, state) {
      if (state is! st.MedicationLoaded || selectedKey == null) {
        return const SizedBox.shrink();
      }

      final now = DateTime.now();
      final meds = state.medications.where((m) => _deriveCategoryKeyFromType(m.type) == selectedKey).toList();

      DateTime? nextFor(Medication m) {
        final plan = PlanBuilder.buildOneOffHorizon(m, from: now, to: now.add(const Duration(days: 14)));
        if (plan.oneOffs.isEmpty) return null;
        return plan.oneOffs.first.scheduledAt;
      }

      meds.sort((a, b) {
        final na = nextFor(a);
        final nb = nextFor(b);
        if (na == null && nb == null) return 0;
        if (na == null) return 1;
        if (nb == null) return -1;
        return na.compareTo(nb);
      });

      final med = meds.isNotEmpty ? meds.first : null;
      if (med == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Bu kategoride planlı bir doz bulunamadı.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7))),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: MedicationListItem(med: med),
      );
    });
  }
}

// Dashboard-specific bottom nav (glass style)
class _DashboardBottomBar extends StatelessWidget {
  const _DashboardBottomBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final glass = isLight ? Colors.white.withOpacity(0.55) : cs.surface.withOpacity(0.55);
    final borderColor = Colors.white.withOpacity(isLight ? 0.30 : 0.15);

    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 76,
            decoration: BoxDecoration(
              color: glass,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DBNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  selected: true,
                  onTap: () => const HomeRoute().go(context),
                ),
                _DBNavItem(
                  icon: Icons.calendar_month,
                  label: 'Plans',
                  onTap: () => const PlansRoute().go(context),
                ),
                const SizedBox(width: 56),
                _DBNavItem(
                  icon: Icons.history,
                  label: 'History',
                  onTap: () => const MissedDosesRoute().go(context),
                ),
                _DBNavItem(
                  icon: Icons.medication_outlined,
                  label: 'Dose',
                  onTap: () => const PlansRoute().go(context),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () => context.push(AppRoutePaths.medicationsNewStep1),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class _DBNavItem extends StatelessWidget {
  const _DBNavItem({required this.icon, required this.label, this.onTap, this.selected = false});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected
        ? cs.primary
        : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.85);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color, fontWeight: selected ? FontWeight.w800 : FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helpers (kept aligned with DoseIntake mapping) ---
IconData _iconForCategory(MedicationCategoryKey key) {
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
