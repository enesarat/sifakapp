import 'package:flutter/material.dart';

/// 24 saate eşit aralıklı saatler üretir.
/// Örn: dose=3 -> 00:00, 08:00, 16:00
List<TimeOfDay> generateEvenlySpacedTimes(int dose) {
  final d = (dose <= 0) ? 1 : dose;
  final List<TimeOfDay> times = [];
  final interval = (24 / d).floor();
  for (int i = 0; i < d; i++) {
    times.add(TimeOfDay(hour: (i * interval) % 24, minute: 0));
  }
  return times;
}
