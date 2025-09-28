import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';

import '../../../domain/entities/medication.dart';
import '../../../domain/use_cases/get_all_medications.dart';
import '../../../application/plan/plan_builder.dart';
import '../../utils/time_utils.dart';
import '../../blocs/medication/medication_bloc.dart';
import '../../blocs/medication/medication_event.dart' as ev;
import '../../blocs/medication/medication_state.dart' as st;

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
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) context.go(const HomeRoute().location);
        } else if (state is st.DoseSkipped) {
          if (mounted) context.go(const HomeRoute().location);
        } else if (state is st.MedicationError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() => _processing = false);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('İlaç Kullanım'),
          actions: [
            IconButton(
              tooltip: 'Kapat',
              icon: const Icon(Icons.close),
              onPressed: () => context.go(const HomeRoute().location),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_med == null)
                ? const Center(child: Text('Kayıt bulunamadı'))
                : _buildContent(context, _med!),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Medication med) {
    final days = _weekdayLabels(med);
    final times = _timeLabels(med);

    final canConsume = med.remainingPills > 0 && !_processing;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Kalan doz: ${med.remainingPills}'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: days.map((d) => Chip(label: Text(d))).toList()),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: times.map((t) => Chip(label: Text(t))).toList()),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: canConsume
                      ? () {
                          setState(() => _processing = true);
                          context.read<MedicationBloc>().add(ev.ConsumeMedicationDose(med.id, occurrenceAt: widget.occurrenceAt));
                        }
                      : null,
                  child: _processing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Dozu kullanıldı'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _processing
                      ? null
                      : () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Dozu atla?'),
                              content: const Text('Bu dozu atlamak istediğinize emin misiniz?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
                                FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Atla')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            setState(() => _processing = true);
                            context.read<MedicationBloc>().add(ev.SkipMedicationDose(med.id, occurrenceAt: widget.occurrenceAt));
                          }
                        },
                  child: const Text('Dozu atla'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

