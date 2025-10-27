import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/navigation/app_routes.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';

Future<bool?> showConfirmDeleteMedicationDialog(
  BuildContext context, {
  required Medication med,
}) {
  final route = ConfirmDeleteMedicationRoute(id: med.id);
  return context.push<bool>(route.location, extra: med);
}

