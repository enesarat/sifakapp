import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_event.dart';
import 'show_medication_details_dialog.dart';
import 'confirm_delete_medication_dialog.dart';

class MedicationListItem extends StatelessWidget {
  const MedicationListItem({super.key, required this.med});
  final Medication med;

  @override
  Widget build(BuildContext context) {
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
              // Sol kısım: başlık + alt bilgi
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
                    const SizedBox(height: 4),
                    Text(
                      'Son Kullanma: ${med.expirationDate.toLocal().toString().split(' ').first}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Sağ kısım: detay oku oku ikonu + sil
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
                        // BLoC'a bildir
                        // (ID string ise med.id string olmalı; tipine göre uyarlayın)
                        // Hata olursa UI zaten MedicationError gösterecek.
                        // ignore: use_build_context_synchronously
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
