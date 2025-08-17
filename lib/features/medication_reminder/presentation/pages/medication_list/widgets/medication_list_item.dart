import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_event.dart';
import 'show_medication_details_dialog.dart';
import 'confirm_delete_medication_dialog.dart';

// utils
import '../../../utils/medication_formatters.dart';

class MedicationListItem extends StatelessWidget {
  const MedicationListItem({super.key, required this.med});
  final Medication med;

  @override
  Widget build(BuildContext context) {
    final start = formatDateYmd(med.startDate);
    final end   = formatDateYmd(med.endDate);
    final exp   = formatDateYmd(med.expirationDate);
    final usageDaysLabel = med.isEveryDay ? 'Her gün' : formatUsageDays(med.usageDays);
    final meal = formatMealFromMedication(med);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showMedicationDetailsDialog(context, med),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                    const SizedBox(height: 6),
                    Text(
                      'Başlangıç: $start'
                      '${end != '—' ? '   •   Bitiş: $end' : ''}'
                      '${exp != '—' ? '   •   SKT: $exp' : ''}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Doz: ${med.dailyDosage}/gün')),
                        Chip(label: Text('Kalan: ${med.remainingPills}/${med.totalPills}')),
                        Chip(label: Text('Saat: ${scheduleModeLabel(med.timeScheduleMode)}')),
                        Chip(label: Text('Gün: ${scheduleModeLabel(med.dayScheduleMode)} • $usageDaysLabel')),
                        if (meal != null) Chip(label: Text(meal)),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Detay',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => showMedicationDetailsDialog(context, med),
                  ),
                  IconButton(
                    tooltip: 'Sil',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirmed = await showConfirmDeleteMedicationDialog(
                        context,
                        med: med,
                      );
                      if (confirmed == true) {
                        context.read<MedicationBloc>().add(RemoveMedication(med.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('İlaç siliniyor...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
