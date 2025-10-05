import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:sifakapp/features/medication_reminder/application/notifications/notification_scheduler.dart';
import 'package:sifakapp/features/medication_reminder/application/plan/schedule_from_plan.dart';
import 'package:sifakapp/features/medication_reminder/data/data_sources/asset_medication_catalog_data_source.dart';
import 'package:sifakapp/features/medication_reminder/data/data_sources/local_medication_plan_datasource.dart';
import 'package:sifakapp/features/medication_reminder/data/repositories/medication_catalog_repository_impl.dart';
import 'package:sifakapp/features/medication_reminder/data/repositories/medication_plan_repository_impl.dart';
import 'package:sifakapp/features/medication_reminder/domain/repositories/medication_catalog_repository.dart';
import 'package:sifakapp/features/medication_reminder/domain/repositories/medication_plan_repository.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/get_medication_category_by_key.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/get_all_medication_categories.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/catalog/search_medication_catalog.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/plan/apply_plan_for_medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/plan/cancel_plan_for_medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/plan/reapply_plan_if_changed.dart';
import 'package:sifakapp/features/medication_reminder/infra/notifications/flutter_local_notifications_scheduler.dart';
import 'package:sifakapp/features/medication_reminder/infra/notifications/awesome_notifications_scheduler.dart';

import '../features/medication_reminder/data/data_sources/local_medication_datasource.dart';
import '../features/medication_reminder/data/models/medication_model.dart';
import '../features/medication_reminder/data/models/medication_plan_model.dart';
import '../features/medication_reminder/data/repositories/medication_repository_impl.dart';
import '../features/medication_reminder/domain/repositories/medication_repository.dart';
import '../features/medication_reminder/domain/use_cases/consume_dose.dart';
import '../features/medication_reminder/domain/use_cases/create_medication.dart';
import '../features/medication_reminder/domain/use_cases/delete_medication.dart';
import '../features/medication_reminder/domain/use_cases/edit_medication.dart';
import '../features/medication_reminder/domain/use_cases/get_all_medications.dart';
import '../features/medication_reminder/domain/use_cases/skip_dose.dart';

// Plan layer placeholder (enable when plan repo/datasource ready)
// import '../features/medication_reminder/data/data_sources/local_medication_plan_datasource.dart';
// import '../features/medication_reminder/data/repositories/medication_plan_repository_impl.dart';
// import '../features/medication_reminder/domain/repositories/medication_plan_repository.dart';

final sl = GetIt.instance;

void setupLocator(
    Box<MedicationModel> medsBox, Box<MedicationPlanModel> plansBox,
    {FlutterLocalNotificationsPlugin? notificationsPlugin,
    bool useAwesomeNotifications = false}) {
  // ---------- Notifications ----------
  if (useAwesomeNotifications) {
    AwesomeNotificationsScheduler.initialize();
    sl.registerLazySingleton<NotificationScheduler>(
        () => AwesomeNotificationsScheduler());
  } else {
    final plugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();
    sl.registerLazySingleton<NotificationScheduler>(
        () => FlutterLocalNotificationsScheduler(plugin));
  }
  sl.registerLazySingleton<ScheduleFromPlan>(() => ScheduleFromPlan(sl()));

  // ---------- Data Sources ----------
  sl.registerLazySingleton<LocalMedicationDataSource>(
    () => LocalMedicationDataSource(medsBox),
  );
  sl.registerLazySingleton<AssetMedicationCatalogDataSource>(
    () => AssetMedicationCatalogDataSource(),
  );

  // Plan data-source placeholder (keep until plan repo ready)
  sl.registerLazySingleton<LocalMedicationPlanDataSource>(
    () => LocalMedicationPlanDataSource(plansBox),
  );

  // ---------- Repositories ----------
  sl.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MedicationCatalogRepository>(
    () => MedicationCatalogRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<MedicationPlanRepository>(
    () => MedicationPlanRepositoryImpl(sl()),
  );

  // ---------- Use Cases ----------
  sl.registerLazySingleton<GetAllMedications>(() => GetAllMedications(sl()));
  sl.registerLazySingleton<CreateMedication>(() => CreateMedication(sl()));
  sl.registerLazySingleton<DeleteMedication>(() => DeleteMedication(sl()));
  sl.registerLazySingleton<EditMedication>(() => EditMedication(sl()));
  sl.registerLazySingleton<ConsumeDose>(() => ConsumeDose(sl()));
  sl.registerLazySingleton<SkipDose>(() => const SkipDose());

  sl.registerLazySingleton<SearchMedicationCatalog>(
      () => SearchMedicationCatalog(sl()));
  sl.registerLazySingleton<GetMedicationCategoryByKey>(
      () => GetMedicationCategoryByKey(sl()));
  sl.registerLazySingleton<GetAllMedicationCategories>(
      () => GetAllMedicationCategories(sl()));

  sl.registerLazySingleton<ApplyPlanForMedication>(
      () => ApplyPlanForMedication(sl(), sl()));
  sl.registerLazySingleton<ReapplyPlanIfChanged>(
      () => ReapplyPlanIfChanged(sl(), sl()));
  sl.registerLazySingleton<CancelPlanForMedication>(
      () => CancelPlanForMedication(sl(), sl()));
}
