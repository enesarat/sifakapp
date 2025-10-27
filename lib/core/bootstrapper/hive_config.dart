import 'package:hive_flutter/hive_flutter.dart';
import '../../features/medication_reminder/data/models/medication_model.dart';
import '../../features/medication_reminder/data/models/medication_plan_model.dart';

class HiveConfig {
  static Future<(Box<MedicationModel>, Box<MedicationPlanModel>)> init() async {
    await Hive.initFlutter();

    // Adapterler
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ScheduleModeAdapter());
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MedicationModelAdapter());

    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(RepeatPatternModelAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(LocalTimeModelAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(DailySlotModelAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(WeeklySlotModelAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(OneOffOccurrenceModelAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(MedicationPlanModelAdapter());

    // Box aç
    final medsBox = await _openBoxSafe<MedicationModel>('medications');
    final plansBox = await _openBoxSafe<MedicationPlanModel>('medication_plans');

    return (medsBox, plansBox);
  }

  // Güvenli açıcı: PROD ortamında veri silme yok; hata fırlatılır
  static Future<Box<T>> _openBoxSafe<T>(String name) async {
    try {
      return await Hive.openBox<T>(name);
    } catch (e) {
      // Daha önce burada kutu diski siliniyordu. Bu veri kaybına yol açıyordu.
      // Prod’da asla sessizce silme yapmayalım; hatayı yukarı taşıyalım.
      // Gerekirse migration/compact gibi stratejiler eklenir.
      // ignore: only_throw_errors
      throw e;
    }
  }
}
