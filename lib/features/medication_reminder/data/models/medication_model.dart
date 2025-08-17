import 'package:hive/hive.dart';

part 'medication_model.g.dart';

/// Planlama modu: otomatik/manuel (gün & saat için ayrı ayrı)
@HiveType(typeId: 1)
enum ScheduleMode {
  @HiveField(0)
  automatic,
  @HiveField(1)
  manual,
}

@HiveType(typeId: 0)
class MedicationModel extends HiveObject {
  // --- Kimlik & Temel ---
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// Teşhis / kullanım amacı (opsiyonel metinsel açıklama yerine domain’de anlamlı alan)
  @HiveField(2)
  final String diagnosis;

  /// Tablet, kapsül, şurup vb.
  @HiveField(3)
  final String type;

  // --- Tarihler ---
  /// Kullanımın planlanan başlangıç tarihi
  @HiveField(4)
  final DateTime startDate;

  /// Kullanım süresinin planlanan bitiş tarihi (opsiyonel)
  @HiveField(5)
  final DateTime? endDate;

  /// İlacın kutu üzerindeki son kullanma tarihi (opsiyonel)
  @HiveField(6)
  final DateTime? expirationDate;

  // --- Miktarlar ---
  /// Başlangıçtaki toplam adet (kutu içindeki toplam)
  @HiveField(7)
  final int totalPills;

  /// Kalan güncel adet (bildirim onayıyla azaltılır)
  @HiveField(8)
  final int remainingPills;

  /// Günlük alınacak doz sayısı (örn. günde 3 kez)
  @HiveField(9)
  final int dailyDosage;

  // --- Zamanlama Modları & Değerleri ---
  /// Saat planlaması: otomatik mi manuel mi?
  @HiveField(10)
  final ScheduleMode timeScheduleMode;

  /// Gün planlaması: otomatik mi manuel mi?
  @HiveField(11)
  final ScheduleMode dayScheduleMode;

  /// Manuel saat seçimi yapıldıysa: "08:00", "13:00" gibi HH:mm string’leri
  @HiveField(12)
  final List<String>? reminderTimes;

  /// Her gün mü kullanılıyor? true ise usageDays yok sayılır
  @HiveField(13)
  final bool isEveryDay;

  /// Belirli günlerde kullanım: 1=Mon, 2=Tue, ..., 7=Sun (ISO-8601)
  /// (isEveryDay=false ve dayScheduleMode=manual ise zorunlu)
  @HiveField(14)
  final List<int>? usageDays;

  // --- Yemek ilişkisi (opsiyonel) ---
  /// Yemekten önce/sonra kaç saat?
  @HiveField(15)
  final int? hoursBeforeOrAfterMeal;

  /// true: yemekten sonra, false: yemekten önce, null: önemsiz
  @HiveField(16)
  final bool? isAfterMeal;

  MedicationModel({
    // Kimlik & temel
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.type,

    // Tarihler
    required this.startDate,
    this.endDate,
    this.expirationDate,

    // Miktarlar
    required this.totalPills,
    required this.remainingPills,
    required this.dailyDosage,

    // Planlama
    required this.timeScheduleMode,
    required this.dayScheduleMode,
    this.reminderTimes,
    required this.isEveryDay,
    this.usageDays,

    // Yemek ilişkisi
    this.hoursBeforeOrAfterMeal,
    this.isAfterMeal,
  });
}
