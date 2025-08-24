// Basit ve deterministik otomatik saat dağıtımı.
// Çıktı: minutesSinceMidnight (0..1439)
List<int> autoDistributeTimes(int dailyDosage) {
  assert(dailyDosage > 0);

  // “yaygın” reçete örüntüleri:
  if (dailyDosage == 1) return [9 * 60]; // 09:00
  if (dailyDosage == 2) return [9 * 60, 21 * 60]; // 09:00 - 21:00
  if (dailyDosage == 3) return [8 * 60, 14 * 60, 20 * 60]; // 08,14,20
  if (dailyDosage == 4) return [8 * 60, 12 * 60, 16 * 60, 20 * 60]; // 4'lük

  // 5+ doz: eşit aralıklarla, 08:00 başlangıç baz alınarak.
  final start = 8 * 60; // 08:00
  final step = (24 * 60) ~/ dailyDosage; // 24 saat / doz sayısı
  return List<int>.generate(dailyDosage, (i) => (start + i * step) % (24 * 60));
}
