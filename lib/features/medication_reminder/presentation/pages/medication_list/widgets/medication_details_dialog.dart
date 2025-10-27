import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/navigation/app_routes.dart';
import '../../../../domain/entities/medication.dart';
import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_event.dart';
import '../../../blocs/medication/medication_state.dart';
import 'confirm_delete_medication_dialog.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _med.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),

                    _detailRow('Tanı', _med.diagnosis),
                    _detailRow('Tür', _med.type),

                    _detailRow('Başlangıç', _formatDate(_med.startDate)),
                    if (_med.endDate != null)
                      _detailRow('Bitiş', _formatDate(_med.endDate)),
                    if (_med.expirationDate != null)
                      _detailRow('SKT', _formatDate(_med.expirationDate)),

                    _detailRow('Toplam Hap', _med.totalPills.toString()),
                    _detailRow('Kalan Hap', _med.remainingPills.toString()),
                    _detailRow('Günlük Doz', _med.dailyDosage.toString()),

                    _detailRow('Saat Planı', _scheduleModeLabel(_med.timeScheduleMode)),
                    _detailRow(
                      'Gün Planı',
                      '${_scheduleModeLabel(_med.dayScheduleMode)}${_med.isEveryDay ? ' • Her gün' : ''}',
                    ),
                    if (!_med.isEveryDay && _med.usageDays != null && _med.usageDays!.isNotEmpty)
                      _detailRow('Kullanılacak Günler', _formatUsageDays(_med.usageDays)),

                    if (_med.reminderTimes != null && _med.reminderTimes!.isNotEmpty)
                      _detailRow(
                        'Hatırlatıcı Saatler',
                        _med.reminderTimes!.map((e) => e.format(context)).join(', '),
                      ),

                    if (_med.isAfterMeal != null)
                      _detailRow('Yemek Zamanı', _formatMeal(_med)),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isDeleting
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  Future.microtask(() => context.push(
                                        MedicationEditRoute(id: _med.id).location,
                                        extra: _med,
                                      ));
                                },
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          label: const Text('Düzenle', style: TextStyle(color: Colors.blue)),
                        ),
                        OutlinedButton.icon(
                          onPressed: _isDeleting
                              ? null
                              : () async {
                                  final confirmed = await showConfirmDeleteMedicationDialog(
                                    context,
                                    med: _med,
                                  );
                                  if (confirmed == true) {
                                    setState(() => _isDeleting = true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('İlaç siliniyor...'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    context.read<MedicationBloc>().add(RemoveMedication(_med.id));
                                  }
                                },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Sil', style: TextStyle(color: Colors.red)),
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
                    borderRadius: BorderRadius.circular(20),
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
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Expanded(
          flex: 4,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    ),
  );
}

// -------------------------
// Helpers (null-safe)
// -------------------------

String _formatDate(DateTime? dt) {
  if (dt == null) return '—';
  final d = dt.toLocal();
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

String _scheduleModeLabel(ScheduleMode mode) {
  switch (mode) {
    case ScheduleMode.automatic:
      return 'Otomatik';
    case ScheduleMode.manual:
      return 'Manuel';
  }
}

String _formatUsageDays(List<int>? days) {
  if (days == null || days.isEmpty) return '—';
  const names = { 1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cts', 7: 'Paz' };
  return days.map((d) => names[d] ?? d.toString()).join(', ');
}

String _formatMeal(Medication m) {
  final suffix = (m.hoursBeforeOrAfterMeal != null && m.hoursBeforeOrAfterMeal != 0)
      ? ' ${m.hoursBeforeOrAfterMeal} sa'
      : '';
  return m.isAfterMeal! ? 'Yemekten sonra$suffix' : 'Yemekten önce$suffix';
}

