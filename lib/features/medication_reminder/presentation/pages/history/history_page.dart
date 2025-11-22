import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/ui/spacing.dart';
import 'package:sifakapp/features/medication_reminder/application/plan/plan_builder.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication_category.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/get_all_medications.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/get_medication_category_by_key.dart';
import 'package:sifakapp/features/medication_reminder/domain/repositories/dose_log_repository.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/dose_log.dart' as dlog;

import '../../widgets/frosted_blob_background.dart';
import '../../widgets/floating_top_nav_bar.dart';
import '../../widgets/glass_floating_nav_bar.dart';
import '../../widgets/floating_nav_bar.dart';
import 'widgets/missed_snooze_info_card.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.initialIndex = 0, this.fromNotification = false});

  // 0: Kaçırıldı, 1: Pas Geçildi, 2: Kullanıldı
  final int initialIndex;
  final bool fromNotification;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
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
            child: SafeArea(
              top: true,
              bottom: false,
              child: FloatingTopNavBar(title: 'Geçmiş'),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: AppSpacing.pageInsets(context: context, top: 84, bottom: 0),
                child: ListView(
                  children: [
                    _HistoryTabBar(
                      index: _index,
                      onChanged: (i) => setState(() => _index = i),
                    ),
                    const SizedBox(height: 12),
                    if (_index == 0)
                      _MissedTab(fromNotification: widget.fromNotification)
                    else if (_index == 1)
                      const _PassedTab()
                    else
                      const _TakenTab(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
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

class _HistoryTabBar extends StatelessWidget {
  const _HistoryTabBar({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final glass = isLight ? Colors.white.withOpacity(0.30) : cs.surface.withOpacity(0.30);
    final borderColor = Colors.white.withOpacity(isLight ? 0.25 : 0.12);

    Widget seg(String text, int i) {
      final selected = i == index;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: () => onChanged(i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? cs.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(99),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? Colors.white
                        : (Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.85)),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: glass,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          seg('Kaçırıldı', 0),
          const SizedBox(width: 6),
          seg('Pas Geçildi', 1),
          const SizedBox(width: 6),
          seg('Kullanıldı', 2),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _MissedTab extends StatefulWidget {
  const _MissedTab({required this.fromNotification});
  final bool fromNotification;

  @override
  State<_MissedTab> createState() => _MissedTabState();
}

class _MissedTabState extends State<_MissedTab> {
  bool _loading = true;
  bool _clearing = false;
  int _totalMissed = 0;
  final Map<Medication, List<DateTime>> _missedByMed = {};
  bool _showInfo = true;
  List<_MissedEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _snoozeNotifications() async {
    if (_clearing) return;
    setState(() => _clearing = true);

    try {
      await AwesomeNotifications().dismiss(910001);
    } catch (_) {}

    try {
      final prefs = await Hive.openBox('app_prefs');
      await prefs.put('missed_baseline', 0);
      await prefs.put('missed_baseline_set_at', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}

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
        content: Text('Bildirimler yeni bir kaçırılan doza kadar susturuldu.'),
        duration: Duration(milliseconds: 1200),
      ),
    );

    if (!mounted) return;
    setState(() => _clearing = false);
    await _load();
  }

  Future<void> _load() async {
    try {
      final getAll = GetIt.I<GetAllMedications>();
      final meds = await getAll();
      final now = DateTime.now();
      final from = now.subtract(const Duration(hours: 24));
      final map = <Medication, List<DateTime>>{};
      var total = 0;

      if (GetIt.I.isRegistered<DoseLogRepository>()) {
        final logs = await GetIt.I<DoseLogRepository>().getInRange(from, now);
        final byId = {for (final m in meds) m.id: m};
        for (final l in logs) {
          // Sadece kaçırılanlar (acknowledged=false olanlar)
          if (l.status != dlog.DoseLogStatus.missed) continue;
          if (l.acknowledged) continue;
          final med = byId[l.medId];
          if (med == null) continue;
          (map[med] ??= <DateTime>[]).add(l.plannedAt);
          total += 1;
        }
      } else {
        // Repository yoksa, plan ufku üzerinden basit çıkarım
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
        SnackBar(content: Text('Kaçırılan dozlar yüklenemedi: $e')),
      );
    }
  }

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

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _relativeLabel(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(when.year, when.month, when.day);
    final diffDays = that.difference(today).inDays;
    if (diffDays == 0) return 'Bugün';
    if (diffDays == -1) return 'Dün';
    return '${that.day.toString().padLeft(2, '0')}.${that.month.toString().padLeft(2, '0')}.${that.year}';
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Palette.of(context);
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : (_totalMissed == 0)
            ? _EmptyState(
                onClose: widget.fromNotification
                    ? () => context.go(const HomeRoute().location)
                    : null,
              )
            : Column(
                children: [
                  if (_showInfo)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: MissedSnoozeInfoCard(
                        palette: pal,
                        onSnoozeTap: _snoozeNotifications,
                        onClose: () => setState(() => _showInfo = false),
                        clearing: _clearing,
                      ),
                    ),
                  const SizedBox(height: 12),
                  ..._entries.map(
                    (e) => _HistoryStatusCard(
                      med: e.medication,
                      time: e.at,
                      leftIcon: _iconForMedication(e.medication),
                      statusLabel: 'Kaçırıldı',
                      statusColor: pal.statusRed,
                      statusBg: pal.statusRedBg,
                      statusIcon: Icons.close,
                      pal: pal,
                    ),
                  ),
                ],
              );
  }
}

class _MissedEntry {
  final Medication medication;
  final DateTime at;
  const _MissedEntry({required this.medication, required this.at});
}

class _PassedTab extends StatefulWidget {
  const _PassedTab();

  @override
  State<_PassedTab> createState() => _PassedTabState();
}

class _PassedTabState extends State<_PassedTab> {
  bool _loading = true;
  int _total = 0;
  List<_MissedEntry> _entries = const [];

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
      final to = now.add(const Duration(hours: 24));
      final items = <_MissedEntry>[];

      if (GetIt.I.isRegistered<DoseLogRepository>()) {
        // Passed (skipped) log'larda kullanıcının aksiyonu "şimdi" olabilir,
        // ancak plannedAt ileri bir saat olabilir. Bu yüzden aralığı ileriye de genişletiyoruz.
        final logs = await GetIt.I<DoseLogRepository>().getInRange(from, to);
        final byId = {for (final m in meds) m.id: m};
        for (final l in logs) {
          if (l.status != dlog.DoseLogStatus.passed) continue;
          final med = byId[l.medId];
          if (med == null) continue;
          items.add(_MissedEntry(medication: med, at: l.plannedAt));
        }
      }

      items.sort((a, b) => b.at.compareTo(a.at));
      if (!mounted) return;
      setState(() {
        _entries = items;
        _total = items.length;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pas geçilen dozlar yüklenemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Palette.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_total == 0) {
      return const _PlaceholderTab(label: 'Son 24 saatte pas geçilen doz yok');
    }
    return Column(
      children: [
        const SizedBox(height: 4),
        ..._entries.map(
          (e) => _HistoryStatusCard(
            med: e.medication,
            time: e.at,
            leftIcon: _iconForMedication(e.medication),
            statusLabel: 'Pas Geçildi',
            statusColor: pal.statusOrange,
            statusBg: pal.statusOrangeBg,
            statusIcon: Icons.skip_next,
            pal: pal,
          ),
        ),
      ],
    );
  }
}

class _TakenTab extends StatefulWidget {
  const _TakenTab();

  @override
  State<_TakenTab> createState() => _TakenTabState();
}

class _TakenTabState extends State<_TakenTab> {
  bool _loading = true;
  int _total = 0;
  List<_MissedEntry> _entries = const [];

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
      final to = now.add(const Duration(hours: 24));
      final items = <_MissedEntry>[];

      if (GetIt.I.isRegistered<DoseLogRepository>()) {
        final logs = await GetIt.I<DoseLogRepository>().getInRange(from, to);
        final byId = {for (final m in meds) m.id: m};
        for (final l in logs) {
          if (l.status != dlog.DoseLogStatus.taken) continue;
          final med = byId[l.medId];
          if (med == null) continue;
          items.add(_MissedEntry(medication: med, at: l.plannedAt));
        }
      }

      items.sort((a, b) => b.at.compareTo(a.at));
      if (!mounted) return;
      setState(() {
        _entries = items;
        _total = items.length;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanılan dozlar yüklenemedi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = _Palette.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_total == 0) {
      return const _PlaceholderTab(label: 'Son 24 saatte kullanılan doz yok');
    }
    return Column(
      children: [
        const SizedBox(height: 4),
        ..._entries.map(
          (e) => _HistoryStatusCard(
            med: e.medication,
            time: e.at,
            leftIcon: _iconForMedication(e.medication),
            statusLabel: 'Kullanıldı',
            statusColor: pal.statusGreen,
            statusBg: pal.statusGreenBg,
            statusIcon: Icons.check_circle,
            pal: pal,
          ),
        ),
      ],
    );
  }
}

class _HistoryStatusCard extends StatelessWidget {
  const _HistoryStatusCard({
    required this.med,
    required this.time,
    required this.leftIcon,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
    required this.pal,
    required this.statusIcon,
  });

  final Medication med;
  final DateTime time;
  final IconData leftIcon;
  final String statusLabel;
  final Color statusColor;
  final Color statusBg;
  final IconData statusIcon;
  final _Palette pal;

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderColor = Colors.white.withOpacity(isLight ? 0.30 : 0.10);
    final leftIconBg = isLight ? Colors.white.withOpacity(0.50) : Colors.black.withOpacity(0.20);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pal.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: leftIconBg, shape: BoxShape.circle),
            child: Icon(leftIcon, color: pal.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        med.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800, color: pal.text),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                FutureBuilder<String?>(
                  future: _friendlyTypeLabelFor(med),
                  builder: (ctx, snap) {
                    final label = snap.data ?? med.type;
                    final text = label.isNotEmpty ? '1 $label' : '1 Doz';
                    return Text(
                      text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: pal.subtext),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black.withOpacity(isLight ? 0.10 : 0.10))),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _fmtDate(time),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: pal.subtext, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        _fmtTime(time),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: pal.subtext, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
            child: Icon(Icons.celebration, color: pal.primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Harika iş!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Son 24 saatte kaçırılan doz bulunmuyor. Böyle devam et!', textAlign: TextAlign.center),
          if (onClose != null) ...[
            const SizedBox(height: 24),
            TextButton(onPressed: onClose, child: const Text('Kapat / Anasayfa')),
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
  if (containsAny(const ['çözelti', 'cozelt', 'solüsyon', 'solution'])) {
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

class _Palette implements PaletteLike {
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
  final Color statusRed;
  final Color statusRedBg;
  final Color statusOrange;
  final Color statusOrangeBg;
  final Color statusGreen;
  final Color statusGreenBg;

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
    required this.statusRed,
    required this.statusRedBg,
    required this.statusOrange,
    required this.statusOrangeBg,
    required this.statusGreen,
    required this.statusGreenBg,
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
        statusRed: const Color(0xFFEF4444),
        statusRedBg: const Color(0xFFFEE2E2),
        statusOrange: const Color(0xFFF97316),
        statusOrangeBg: const Color(0xFFFFEDD5),
        statusGreen: const Color(0xFF10B981),
        statusGreenBg: const Color(0xFFD1FAE5),
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
        statusRed: const Color(0xFFF87171),
        statusRedBg: const Color(0x33EF4444),
        statusOrange: const Color(0xFFFB923C),
        statusOrangeBg: const Color(0x33FB923C),
        statusGreen: const Color(0xFF34D399),
        statusGreenBg: const Color(0x3310B981),
      );
    }
  }
}


