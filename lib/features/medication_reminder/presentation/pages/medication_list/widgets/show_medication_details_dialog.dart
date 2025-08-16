import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';
import '../../../../domain/entities/medication.dart';
import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_event.dart';
import '../../../blocs/medication/medication_state.dart';
import 'confirm_delete_medication_dialog.dart';

void showMedicationDetailsDialog(BuildContext context, Medication med) {
  bool isDeleting = false;            // yerel durum
  StateSetter? modalSetState;         // StatefulBuilder setState'ine erişmek için

  showDialog(
    context: context,
    barrierDismissible: !isDeleting,  // silme sırasında dışarı tıklamayla kapanmasın
    builder: (dialogCtx) {
      return BlocListener<MedicationBloc, MedicationState>(
        listenWhen: (prev, curr) =>
            curr is MedicationDeleted || curr is MedicationError,
        listener: (ctx, state) {
          if (state is MedicationDeleted && state.id == med.id) {
            // Başarılı silme -> diyaloğu kapat + snackbar göster
            Navigator.of(ctx, rootNavigator: true).pop(); // dialog'u kapat
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('İlaç silindi.')),
            );
          } else if (state is MedicationError) {
            // Hata -> butonları tekrar etkinleştir, mesajı göster
            modalSetState?.call(() => isDeleting = false);
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: StatefulBuilder(
          builder: (ctx, setModalState) {
            modalSetState = setModalState;
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  // ---- İçerik ----
                  Container(
                    padding: const EdgeInsets.all(20),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.75,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            med.name,
                            style: Theme.of(ctx)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          _detailRow("Tanı", med.diagnosis),
                          _detailRow("Tür", med.type),
                          _detailRow("Son Kullanma",
                              med.expirationDate.toLocal().toString().split(' ')[0]),
                          _detailRow("Toplam Hap", med.totalPills.toString()),
                          _detailRow("Günlük Doz", med.dailyDosage.toString()),
                          _detailRow("Zaman Türü", med.isManualSchedule ? "Manuel" : "Otomatik"),
                          if (med.reminderTimes != null && med.reminderTimes!.isNotEmpty)
                            _detailRow(
                              "Hatırlatıcı Saatler",
                              med.reminderTimes!.map((e) => e.format(ctx)).join(', '),
                            ),
                          if (med.hoursBeforeOrAfterMeal != null && med.isAfterMeal != null)
                            _detailRow(
                              "Yemek Zamanı",
                              "${med.hoursBeforeOrAfterMeal} saat ${med.isAfterMeal! ? 'sonra' : 'önce'} alınmalı",
                            ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                onPressed: isDeleting
                                    ? null
                                    : () {
                                        Navigator.of(ctx).pop(); // Dialog'u kapat
                                        Future.microtask(() => context.push(
                                              MedicationEditRoute(id: med.id).location,
                                              extra: med,
                                            ));
                                      },
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                label: const Text("Düzenle",
                                    style: TextStyle(color: Colors.blue)),
                              ),
                              OutlinedButton.icon(
                                onPressed: isDeleting
                                    ? null
                                    : () async {
                                        final confirmed =
                                            await showConfirmDeleteMedicationDialog(ctx, med: med);
                                        if (confirmed == true) {
                                          setModalState(() => isDeleting = true);

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('İlaç siliniyor...'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                          ctx.read<MedicationBloc>().add(RemoveMedication(med.id));
                                          // Success gelince BlocListener kapatacak.
                                        }
                                      },
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text("Sil",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---- Silme sırasında overlay/progress ----
                  if (isDeleting)
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
            );
          },
        ),
      );
    },
  );
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
            "$label:",
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
