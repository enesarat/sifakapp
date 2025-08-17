/// Haftaya eşit/aralıklı dağıtılmış günler üretir.
/// count: 0..6 (0 => boş), 7 ve üzeri => tüm günler
/// startWeekday: 1=Mon .. 7=Sun (ISO-8601)
List<int> generateAutomaticUsageDays(int count, {int startWeekday = 1}) {
  if (count <= 0) return <int>[];
  if (count >= 7) return [1, 2, 3, 4, 5, 6, 7];

  final step = 7 / count;
  final set = <int>{};

  for (int i = 0; i < count; i++) {
    final offset = (i * step).round();
    final day = ((startWeekday - 1 + offset) % 7) + 1; // 1..7
    set.add(day);
  }

  int cursor = startWeekday;
  while (set.length < count) {
    cursor = (cursor % 7) + 1;
    set.add(cursor);
  }

  final list = set.toList()..sort();
  return list;
}

/// Otomatik gün önizlemesini üretir; koşullar uygun değilse boş döner.
/// (UI tarafında state ataması için kullan)
List<int> previewAutomaticUsageDays({
  required bool isEveryDay,
  required bool isAutomaticDayMode,
  required int autoDaysPerWeek,   // 0..6
  required int startWeekday,      // 1..7
}) {
  if (isEveryDay || !isAutomaticDayMode) return <int>[];
  return generateAutomaticUsageDays(autoDaysPerWeek, startWeekday: startWeekday);
}
