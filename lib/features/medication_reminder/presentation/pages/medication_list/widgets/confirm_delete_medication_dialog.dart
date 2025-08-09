import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';

Future<bool?> showConfirmDeleteMedicationDialog(
  BuildContext context, {
  required Medication med,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Silme işlemi'),
        content: Text(
          '“${med.name}” ilacını silmek istediğinizden emin misiniz?\n'
          'Bu işlem geri alınamaz ve ilgili hatırlatmalar kaldırılacaktır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton.tonal( // Material 3 için daha “destructive” hissi verir
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil'),
          ),
        ],
      );
    },
  );
}
