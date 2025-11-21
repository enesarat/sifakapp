import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';
import 'package:sifakapp/features/medication_reminder/application/plan/plan_builder.dart';
import 'package:sifakapp/core/ui/spacing.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/get_all_medications.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/get_medication_category_by_key.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/glass_floating_nav_bar.dart';
import '../../widgets/frosted_blob_background.dart';
import '../../widgets/floating_top_nav_bar.dart';
import 'package:sifakapp/features/medication_reminder/domain/repositories/dose_log_repository.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/dose_log.dart' as dlog;

class MissedDosesPage extends StatefulWidget {
  const MissedDosesPage({super.key, this.fromNotification = false});

  final bool fromNotification;

  @override
  State<MissedDosesPage> createState() => _MissedDosesPageState();
}

class _MissedDosesPageState extends State<MissedDosesPage> {
  bool _loading = true;
  bool _clearing = false;
  int _totalMissed = 0;
  final Map<Medication, List<DateTime>> _missedByMed = {};
  bool _showInfo = true;
  List<_MissedEntry> _entries = const [];

  Future<void> _snoozeNotifications() async {
    if (_clearing) return;
    setState(() => _clearing = true);

    try {
      await AwesomeNotifications().dismiss(910001);
    } catch (_) {}

    try {
      final prefs = await Hive.openBox('app_prefs');
      await prefs.put('missed_baseline', 0);
      await prefs.put(
        'missed_baseline_set_at',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}

    // Ayrıca ekranda görünen kaçırılan dozları "okundu/susturuldu" olarak işaretle
    try {
      if (GetIt.I.isRegistered<DoseLogRepository>()) {
        final logsRepo = GetIt.I<DoseLogRepository>();
        final now = DateTime.now();
        final from = now.subtract(const Duration(hours: 24));
        final logs = await logsRepo.getInRange(from, now);
        for (final l in logs) {
          if (l.status == dlog.DoseLogStatus.missed && !l.acknowledged) {
            final updated = dlog.DoseLog(
              id: l.id,
              medId: l.medId,
              plannedAt: l.plannedAt,
              resolvedAt: l.resolvedAt,
              status: l.status,
              acknowledged: true,
            );
            await logsRepo.upsert(updated);
          }
        }
      }
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bildirimler yeni bir kaçırılan doza kadar susturuldu.',
        ),
        duration: Duration(milliseconds: 1200),
      ),
    );

    if (!mounted) return;
    setState(() => _clearing = false);
    // Listeyi güncelle
    await _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final getAll = GetIt.I<GetAllMedications>();
      final meds = await getAll();
      final now = DateTime.now();
      final from = now.subtract(const Duration(hours: 24));
      final map = <Medication, List<DateTime>>{};
      var total = 0;

      // Prefer dose logs as the source of truth for missed list
      if (GetIt.I.isRegistered<DoseLogRepository>()) {
        final logs = await GetIt.I<DoseLogRepository>().getInRange(from, now);
        final byId = {for (final m in meds) m.id: m};
        for (final l in logs) {
          // Hem sistemin işaretlediği missed, hem de kullanıcının pas geçtiği
          // passed log'larını göster.
          if (l.status != dlog.DoseLogStatus.missed &&
              l.status != dlog.DoseLogStatus.passed) continue;
          // Susturulmuş (acknowledged) missed olanları listede göstermeyelim
          if (l.status == dlog.DoseLogStatus.missed && l.acknowledged) continue;
          final med = byId[l.medId];
          if (med == null) continue;
          (map[med] ??= <DateTime>[]).add(l.plannedAt);
          total += 1;
        }
      } else {
        // Fallback to plan-based horizon if repository is not available
        for (final med in meds) {
          final plan = PlanBuilder.buildOneOffHorizon(
            med,
            from: from,
            to: now,
          );

          final missed = plan.oneOffs
              .where((o) => !o.scheduledAt.isAfter(now))
              .map((o) => o.scheduledAt)
              .toList();

          if (missed.isNotEmpty) {
            map[med] = missed;
            total += missed.length;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _missedByMed
          ..clear()
          ..addAll(map);
        _totalMissed = total;
        _loading = false;
        _entries = _flatten(map);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kaçırılan dozlar yüklenemedi: $e'),
        ),
      );
    }
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  List<_MissedEntry> _flatten(Map<Medication, List<DateTime>> map) {
    final items = <_MissedEntry>[];
    map.forEach((med, times) {
      for (final t in times) {
        items.add(_MissedEntry(medication: med, at: t));
      }
    });
    items.sort((a, b) => b.at.compareTo(a.at));
    return items;
  }

  String _relativeLabel(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(when.year, when.month, when.day);

    final diffDays = that.difference(today).inDays;
    if (diffDays == 0) return 'Bugün';
    if (diffDays == -1) return 'Dün';

    return '${that.day.toString().padLeft(2, '0')}.'
        '${that.month.toString().padLeft(2, '0')}.'
        '${that.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Palette.of(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: null,
      body: Stack(
        children: [
          const Positioned.fill(child: FrostedBlobBackground()),
          const Positioned(
            left: 0,
            right: 0,
            top: 8,
            child: SafeArea(top: true, bottom: false, child: FloatingTopNavBar(title: 'Geçmiş')),
          ),
          Positioned.fill(
            child: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_totalMissed == 0)
              ? _EmptyState(
                  onClose: widget.fromNotification
                      ? () => context.go(const HomeRoute().location)
                      : null,
                )
              : Stack(
                  children: [
                    // Content with bottom padding to avoid overlap
                    Positioned.fill(
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: AppSpacing.pageInsets(
                            context: context,
                            top: 84,
                            bottom: 0,
                          ),
                          child: ListView(
                            children: [
                              if (_showInfo)
                                _InfoBanner(
                                  onClose: () {
                                    setState(() {
                                      _showInfo = false;
                                    });
                                  },
                                ),
                              const SizedBox(height: 12),
                              ..._entries.map(
                                (e) => _MissedCard(
                                  med: e.medication,
                                  time: e.at,
                                  icon: _iconForMedication(e.medication),
                                  pal: pal,
                                  labelBuilder: (dt) =>
                                      "${_relativeLabel(dt)} ${_fmtTime(dt)}'da kaçırıldı",
                                ),
                              ),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                  ],
                ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: GlassFloatingNavBar(selected: NavTab.history),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({this.onClose});
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final pal = _Palette.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.amberBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: pal.amberBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: pal.amberText,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kaçırılan Doz Bilgisi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
          Text(
            'Aşağıdaki dozlar son 24 saat içinde kaçırıldı. '
            'Bildirimleri susturmak bir sonraki kaçırılan doza kadar '
            'uyarıları durduracaktır.',
            style: TextStyle(
              fontSize: 13,
              color: pal.amberSubtext,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: pal.amberSubtext,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: () async {
                final state =
                    context.findAncestorStateOfType<_MissedDosesPageState>();
                await state?._snoozeNotifications();
              },
              icon: const Icon(Icons.notifications_off),
              label: const Text('Bildirimleri Sustur'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissedEntry {
  final Medication medication;
  final DateTime at;
  const _MissedEntry({required this.medication, required this.at});
}

class _MissedCard extends StatelessWidget {
  const _MissedCard({
    required this.med,
    required this.time,
    required this.labelBuilder,
    required this.icon,
    required this.pal,
  });

  final Medication med;
  final DateTime time;
  final String Function(DateTime) labelBuilder;
  final IconData icon;
  final _Palette pal;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).cardTheme.color,
      elevation: (Theme.of(context).cardTheme.elevation ?? 2),
      shape: (Theme.of(context).cardTheme.shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          )),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: pal.iconBg,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Icon(
                    icon,
                    color: pal.text,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      FutureBuilder<String?>(
                        future: _friendlyTypeLabelFor(med),
                        builder: (ctx, snap) {
                          final label = snap.data ?? med.type;
                          final text = label.isNotEmpty ? '1 $label' : '1 Doz';
                          return Text(
                            text,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: pal.primary),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: pal.listRowBg,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: pal.amberSubtext),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FutureBuilder<dlog.DoseLog?>(
                      future: GetIt.I<DoseLogRepository>()
                          .getByOccurrence(med.id, time),
                      builder: (ctx, snap) {
                        final st = snap.data?.status;
                        var txt = labelBuilder(time);
                        if (st == dlog.DoseLogStatus.passed) {
                          txt = txt.replaceFirst('kaçırıldı', 'pas geçildi');
                        }
                        return Text(
                          txt,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        );
                      },
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onClose});
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final pal = _Palette.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: pal.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.celebration,
              color: pal.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Harika iş!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Son 24 saatte kaçırılan doz bulunmuyor. Böyle devam et!',
            textAlign: TextAlign.center,
          ),
          if (onClose != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: onClose,
              child: const Text('Kapat / Anasayfa'),
            ),
          ],
        ],
      ),
    );
  }
}

Future<String?> _friendlyTypeLabelFor(Medication m) async {
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

// --- Icon helpers (mapping aligned with dose_intake_page.dart) ---
IconData _iconForMedication(Medication m) {
  final key =
      _deriveCategoryKeyFromType(m.type) ?? MedicationCategoryKey.oralCapsule;
  return _iconForCategoryKey(key);
}

MedicationCategoryKey? _deriveCategoryKeyFromType(String value) {
  final v = value.trim();
  final byKey = MedicationCategoryKey.fromValue(v);
  if (byKey != null) return byKey;

  final t = v.toLowerCase();
  bool containsAny(List<String> needles) =>
      needles.any((n) => t.contains(n));

  if (containsAny(const ['kaps', 'tablet', 'hap', 'capsule', 'pill'])) {
    return MedicationCategoryKey.oralCapsule;
  }
  if (containsAny(const ['pomad', 'merhem', 'krem', 'jel'])) {
    return MedicationCategoryKey.topicalSemisolid;
  }
  if (containsAny(
      const ['enjeks', 'amp', 'flakon', 'iğne', 'igne', 'vial'])) {
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
  if (containsAny(
      const ['çözelt', 'cozelt', 'solüsyon', 'solution'])) {
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

// --- Palette to match the reference HTML ---
class _Palette {
  final Color primary;
  final Color appBarBg;
  final Color card;
  final Color border;
  final Color iconBg;
  final Color text;
  final Color subtext;
  final Color listRowBg;
  final Color amberBg;
  final Color amberBorder;
  final Color amberText;
  final Color amberSubtext;

  _Palette({
    required this.primary,
    required this.appBarBg,
    required this.card,
    required this.border,
    required this.iconBg,
    required this.text,
    required this.subtext,
    required this.listRowBg,
    required this.amberBg,
    required this.amberBorder,
    required this.amberText,
    required this.amberSubtext,
  });

  factory _Palette.of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    if (!isDark) {
      return _Palette(
        primary: const Color(0xFF13B6EC),
        appBarBg: const Color(0xFFFFFFFF),
        card: const Color(0xFFFFFFFF),
        border: const Color(0xFFCFE1E7),
        iconBg: const Color(0xFFE7F0F3),
        text: const Color(0xFF0D181B),
        subtext: const Color(0xFF4C869A),
        listRowBg: const Color(0xFFF6F8F8),
        amberBg: const Color(0xFFFFFBEB),
        amberBorder: const Color(0xFFFDE68A),
        amberText: const Color(0xFFD97706),
        amberSubtext: const Color(0xFFF59E0B),
      );
    } else {
      return _Palette(
        primary: const Color(0xFF13B6EC),
        appBarBg: const Color(0xFF1A2A30),
        card: const Color(0xFF1A2A30),
        border: const Color(0xFF343E41),
        iconBg: const Color(0xFF2D3A40),
        text: const Color(0xFFE1E3E4),
        subtext: const Color(0xFFA1AEB3),
        listRowBg: const Color(0xFF1A2A30),
        amberBg: const Color(0xFF2C240E),
        amberBorder: const Color(0xFF5F4C10),
        amberText: const Color(0xFFFCD34D),
        amberSubtext: const Color(0xFFD97706),
      );
    }
  }
}
