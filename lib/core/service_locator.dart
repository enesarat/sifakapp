import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:sifakapp/features/medication_reminder/application/notifications/notification_scheduler.dart';
import 'package:sifakapp/features/medication_reminder/application/plan/schedule_from_plan.dart';
import 'package:sifakapp/features/medication_reminder/data/data_sources/local_medication_plan_datasource.dart';
import 'package:sifakapp/features/medication_reminder/data/repositories/medication_plan_repository_impl.dart';
import 'package:sifakapp/features/medication_reminder/domain/repositories/medication_plan_repository.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/plan/apply_plan_for_medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/plan/cancel_plan_for_medication.dart';
import 'package:sifakapp/features/medication_reminder/domain/use_cases/plan/reapply_plan_if_changed.dart';
import 'package:sifakapp/features/medication_reminder/infra/notifications/flutter_local_notifications_scheduler.dart';
import 'package:sifakapp/features/medication_reminder/infra/notifications/awesome_notifications_scheduler.dart';

import '../features/medication_reminder/data/data_sources/local_medication_datasource.dart';
import '../features/medication_reminder/data/repositories/medication_repository_impl.dart';
import '../features/medication_reminder/domain/repositories/medication_repository.dart';
import '../features/medication_reminder/data/models/medication_model.dart';

import '../features/medication_reminder/domain/use_cases/create_medication.dart';
import '../features/medication_reminder/domain/use_cases/delete_medication.dart';
import '../features/medication_reminder/domain/use_cases/edit_medication.dart';
import '../features/medication_reminder/domain/use_cases/get_all_medications.dart';

// Plan tarafı (kutuyu alacağız; repo/datasource’u ekleyince burayı açarız)
import '../features/medication_reminder/data/models/medication_plan_model.dart';
// import '../features/medication_reminder/data/data_sources/local_medication_plan_datasource.dart';
// import '../features/medication_reminder/data/repositories/medication_plan_repository_impl.dart';
// import '../features/medication_reminder/domain/repositories/medication_plan_repository.dart';

final sl = GetIt.instance;

void setupLocator(
  Box<MedicationModel> medsBox,
  Box<MedicationPlanModel> plansBox,
  {FlutterLocalNotificationsPlugin? notificationsPlugin, bool useAwesomeNotifications = false}
) {

  // ---------- Notifications ----------
  if (useAwesomeNotifications) {
    AwesomeNotificationsScheduler.initialize();
    sl.registerLazySingleton<NotificationScheduler>(() => AwesomeNotificationsScheduler());
  } else {
    final plugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();
    sl.registerLazySingleton<NotificationScheduler>(() => FlutterLocalNotificationsScheduler(plugin));
  }
  sl.registerLazySingleton<ScheduleFromPlan>(() => ScheduleFromPlan(sl()));

  // ---------- Data Sources ----------
  sl.registerLazySingleton<LocalMedicationDataSource>(
    () => LocalMedicationDataSource(medsBox),
  );

  // Plan DS/Repo hazır olduğunda (şimdilik yorumda bırakıyoruz)
  sl.registerLazySingleton<LocalMedicationPlanDataSource>(
    () => LocalMedicationPlanDataSource(plansBox),
  );

  // ---------- Repositories ----------
  sl.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<MedicationPlanRepository>(
    () => MedicationPlanRepositoryImpl(sl()),
  );

  // ---------- Use Cases ----------
  sl.registerLazySingleton<GetAllMedications>(() => GetAllMedications(sl()));
  sl.registerLazySingleton<CreateMedication>(() => CreateMedication(sl()));
  sl.registerLazySingleton<DeleteMedication>(() => DeleteMedication(sl()));
  sl.registerLazySingleton<EditMedication>(() => EditMedication(sl()));

  sl.registerLazySingleton<ApplyPlanForMedication>(() => ApplyPlanForMedication(sl(), sl()));
  sl.registerLazySingleton<ReapplyPlanIfChanged>(() => ReapplyPlanIfChanged(sl(), sl()));
  sl.registerLazySingleton<CancelPlanForMedication>(() => CancelPlanForMedication(sl(), sl()));
}
