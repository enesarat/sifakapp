// lib/features/medication_reminder/presentation/utils/medication_formatters.dart
import '../../domain/entities/medication.dart';

/// Basit tarih formatı (YYYY-MM-DD). Locale gerektirmiyor.
/// İstersen Intl kullanarak genişletebilirsin (aşağıda not var).
String formatDateYmd(DateTime? dt, {String placeholder = '—'}) {
  if (dt == null) return placeholder;
  final d = dt.toLocal();
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

String scheduleModeLabel(ScheduleMode mode) {
  switch (mode) {
    case ScheduleMode.automatic:
      return 'Otomatik';
    case ScheduleMode.manual:
      return 'Manuel';
  }
}

/// 1..7 (1=Pzt … 7=Paz) için kısa etiketler.
/// (İstersen burayı Intl ile locale bazlı hale getirebilirsin.)
const Map<int, String> _weekdayShortTr = {
  1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cts', 7: 'Paz',
};

String formatUsageDays(List<int>? days, {String placeholder = '—'}) {
  if (days == null || days.isEmpty) return placeholder;
  return days.map((d) => _weekdayShortTr[d] ?? d.toString()).join(', ');
}

/// Yemek bilgisi etiketi. `null` dönebilir.
String? formatMeal({bool? isAfterMeal, int? hoursBeforeOrAfterMeal}) {
  if (isAfterMeal == null) return null;
  final delta = (hoursBeforeOrAfterMeal != null && hoursBeforeOrAfterMeal != 0)
      ? ' ${hoursBeforeOrAfterMeal}sa'
      : '';
  return isAfterMeal ? 'Yemekten: Sonra$delta' : 'Yemekten: Önce$delta';
}

/// Convenience: Entity üzerinden formatlama
String? formatMealFromMedication(Medication m) =>
    formatMeal(
      isAfterMeal: m.isAfterMeal,
      hoursBeforeOrAfterMeal: m.hoursBeforeOrAfterMeal,
    );
