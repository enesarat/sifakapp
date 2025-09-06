import 'package:flutter/material.dart';
import 'package:sifakapp/features/medication_reminder/application/plan/auto_time_util.dart';

/// Otomatik saat dağıtımı için tek kaynak: `autoDistributeTimes`.
/// UI tarafında TimeOfDay listesine dönüştürür ve sıralar.
/// Örn: dose=3 -> 08:00, 14:00, 20:00 (plan ile birebir aynı)
List<TimeOfDay> generateEvenlySpacedTimes(int dose) {
  final minutes = autoDistributeTimes(dose)..sort();
  return minutes
      .map((m) => TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60))
      .toList();
}

