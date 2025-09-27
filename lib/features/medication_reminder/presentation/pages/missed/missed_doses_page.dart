import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  int _totalMissed = 0;
  final Map<Medication, List<DateTime>> _missedByMed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final getAll = GetIt.I<GetAllMedications>();
    final meds = await getAll();
    final now = DateTime.now();
    final from = now.subtract(const Duration(hours: 5));

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
    setState(() {
      _missedByMed.clear();
      _missedByMed.addAll(map);
      _totalMissed = total;
      _loading = false;
    });
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}' ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaçırılan Dozlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Kapat',
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_totalMissed == 0)
              ? const Center(child: Text('Son 5 saatte kaçırılan doz yok.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Son 5 saatte $_totalMissed doz kaçırıldı',
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
                    ],
                  ),
                ),
    );
  }
}

