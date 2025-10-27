import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';
import 'package:sifakapp/features/medication_reminder/application/plan/plan_builder.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/get_all_medications.dart';



class MissedDosesPage extends StatefulWidget {
  const MissedDosesPage({super.key});

  @override
  State<MissedDosesPage> createState() => _MissedDosesPageState();
}

class _MissedDosesPageState extends State<MissedDosesPage> {
  bool _loading = true;
  bool _clearing = false;
  int _totalMissed = 0;
  final Map<Medication, List<DateTime>> _missedByMed = {};

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
      for (final med in meds) {
        final plan = PlanBuilder.buildOneOffHorizon(med, from: from, to: now);
        final missed = plan.oneOffs
            .where((o) => !o.scheduledAt.isAfter(now))
            .map((o) => o.scheduledAt)
            .toList();
        if (missed.isNotEmpty) {
          map[med] = missed;
          total += missed.length;
        }
      }
      if (!mounted) return;
      setState(() {
        _missedByMed
          ..clear()
          ..addAll(map);
        _totalMissed = total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaçırılan dozlar yüklenemedi: $e')),
      );
    }
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}' ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Kaçırılan Dozlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () { context.go(const HomeRoute().location); },
            tooltip: 'Kapat',
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_totalMissed == 0)
              ? const Center(child: Text('Son 24 saatte kaçırılan doz yok.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _InfoBanner(),
                      const SizedBox(height: 12),
                      Text(
                        'Son 24 saatte $_totalMissed doz kaçırıldı',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
          Expanded(
            child: ListView(
                          children: _missedByMed.entries.map((e) {
                            final med = e.key;
                            final times = e.value..sort();
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      med.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: times
                                          .map((t) => Chip(label: Text(_fmtTime(t))))
                                          .toList(),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
          const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _clearing
                            ? Row(
                                key: const ValueKey('clearing_done'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Kaçırılan doz bildirimleri temizlendi')
                                ],
                              )
                            : SizedBox(
                                key: const ValueKey('clear_button'),
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.notifications_off_outlined),
                                  label: const Text('Bildirimleri Temizle'),
                                  onPressed: () async {
                                    setState(() => _clearing = true);
                                    try {
                                      await AwesomeNotifications().dismiss(910001);
                                    } catch (_) {}
                                    // Set snooze baseline to current missed count
                                    try {
                                      final prefs = await Hive.openBox('app_prefs');
                                      await prefs.put('missed_baseline', _totalMissed);
                                      await prefs.put('missed_baseline_set_at', DateTime.now().millisecondsSinceEpoch);
                                    } catch (_) {}
                                    // Feedback
                                    final controller = ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Kaçırılan dozlar için bilgilendirme temizlendi.'),
                                        duration: Duration(milliseconds: 1200),
                                      ),
                                    );
                                    await controller.closed;
                                    if (!mounted) return;
                                    setState(() => _clearing = false); // keep on page, list stays
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kaçırılan bildirimler 24 saat içinde otomatik temizlenir. '
              '“Bildirimleri Temizle” butonu, yeni bir kaçırılan oluşana kadar uyarıları susturur.',
            ),
          ),
        ],
      ),
    );
  }
}








