import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/medication.dart';
import '../../../blocs/medication/medication_bloc.dart';
import '../../../blocs/medication/medication_event.dart';
import '../../medication_edit/medication_edit_page.dart';
import 'confirm_delete_medication_dialog.dart';

void showMedicationDetailsDialog(BuildContext context, Medication med) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  med.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Divider(),
                const SizedBox(height: 12),
                _detailRow("Tanı", med.diagnosis),
                _detailRow("Tür", med.type),
                _detailRow("Son Kullanma", med.expirationDate.toLocal().toString().split(' ')[0]),
                _detailRow("Toplam Hap", med.totalPills.toString()),
                _detailRow("Günlük Doz", med.dailyDosage.toString()),
                _detailRow("Zaman Türü", med.isManualSchedule ? "Manuel" : "Otomatik"),
                if (med.reminderTimes != null && med.reminderTimes!.isNotEmpty)
                  _detailRow("Hatırlatıcı Saatler", med.reminderTimes!.map((e) => e.format(context)).join(', ')),
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
                      onPressed: () {
                        Navigator.pop(context); // Dialog'u kapat
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicationEditPage(medication: med),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit, color: Colors.blue),
                      label: Text("Düzenle", style: TextStyle(color: Colors.blue)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        // Silme işlemi için onay diyaloğunu göster
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
                          Navigator.pop(context); // Dialog'u kapat
                        }
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text("Sil", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        Expanded(
            flex: 4,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            )),
        Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            )),
      ],
    ),
  );
}
