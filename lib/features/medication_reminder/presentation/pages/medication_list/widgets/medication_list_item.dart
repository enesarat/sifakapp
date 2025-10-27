import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_event.dart';
import 'show_medication_details_dialog.dart';
import 'confirm_delete_medication_dialog.dart';

// utils
import '../../../utils/medication_formatters.dart';
import '../../../utils/time_utils.dart';

class MedicationListItem extends StatelessWidget {
  const MedicationListItem({super.key, required this.med});
  final Medication med;

  @override
  Widget build(BuildContext context) {
    final start = formatDateYmd(med.startDate);
    final end = formatDateYmd(med.endDate);
    final exp = formatDateYmd(med.expirationDate);
    final cs = Theme.of(context).colorScheme;

    final remaining = med.remainingPills;
    final total = med.totalPills;
    final double pct = total > 0 ? ((remaining / total).clamp(0.0, 1.0) as double) : 0.0;

    String _fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    TimeOfDay _nextDose() {
      final times = (med.timeScheduleMode == ScheduleMode.manual &&
              med.reminderTimes != null &&
              med.reminderTimes!.isNotEmpty)
          ? List<TimeOfDay>.from(med.reminderTimes!)
          : generateEvenlySpacedTimes(med.dailyDosage);
      times.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      final now = TimeOfDay.now();
      final nowM = now.hour * 60 + now.minute;
      for (final t in times) {
        final m = t.hour * 60 + t.minute;
        if (m > nowM) return t;
      }
      return times.first;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showMedicationDetailsDialog(context, med),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Başlangıç: ' + start + (end != '—' ? ', Bitiş: ' + end : '') + (exp != '—' ? ', SKT: ' + exp : ''),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.primary.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    med.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${med.totalPills} adet, ${med.dailyDosage} kez/gün',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.primary.withOpacity(0.85)),
                      ),
                      GestureDetector(
                        onTap: () => showMedicationDetailsDialog(context, med),
                        child: Builder(builder: (ctx) {
                          final baseSize = Theme.of(ctx).textTheme.titleSmall?.fontSize ?? 14;
                          const labelColor = Color(0xFF6F9B8F); // gri-yeşil
                          const timeColor = Color(0xFF2BAA7F);  // daha belirgin yeşil
                          return RichText(
                            text: TextSpan(
                              style: Theme.of(ctx).textTheme.titleSmall,
                              children: [
                                TextSpan(
                                  text: 'Gelecek doz: ',
                                  style: TextStyle(
                                    color: labelColor,
                                    fontSize: baseSize - 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: _fmt(_nextDose()),
                                  style: TextStyle(
                                    color: timeColor,
                                    fontSize: baseSize + 2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cs.outlineVariant)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_remainingLabel(med),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                      Text('$remaining/$total',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 8,
                      child: Stack(
                        children: [
                          Container(color: cs.surfaceVariant.withOpacity(0.7)),
                          FractionallySizedBox(
                            widthFactor: pct,
                            child: Container(color: cs.primary),
                          ),
                        ],
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
}

String _remainingLabel(Medication med) {
  final t = (med.type).toLowerCase();
  const pillHints = ['kaps', 'tablet', 'hap', 'capsule', 'pill'];
  final isPill = pillHints.any((h) => t.contains(h));
  return isPill ? 'Kalan hap' : 'Kalan doz';
}
