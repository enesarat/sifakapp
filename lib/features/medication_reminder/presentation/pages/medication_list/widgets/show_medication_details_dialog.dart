import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/navigation/app_routes.dart';
import '../../../../domain/entities/medication.dart';

/// Helper: Detay diyaloğunu page-based dialog route ile açar.
/// Not: Typed route extension'larının `push` metodu `extra` kabul etmez.
/// Bu yüzden `route.location` ile `context.push(..., extra: ...)` kullanılmalı.
Future<void> showMedicationDetailsDialog(BuildContext context, Medication med) {
  final route = MedicationDetailsDialogRoute(id: med.id);
  return context.push<void>(route.location, extra: med);
}
