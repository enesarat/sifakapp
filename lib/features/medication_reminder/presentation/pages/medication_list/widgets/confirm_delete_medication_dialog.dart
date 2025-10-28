import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'delete_medication_dialog.dart';

Future<bool?> showConfirmDeleteMedicationDialog(
  BuildContext context, {
  required Medication med,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Silme İşlemi',
    barrierColor: Colors.transparent,
    pageBuilder: (ctx, a1, a2) {
      return Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),
          Center(
            child: DeleteMedicationDialog(id: med.id, medication: med),
          ),
        ],
      );
    },
  );
}
