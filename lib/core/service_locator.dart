import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

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
) {
  // ---------- Data Sources ----------
  sl.registerLazySingleton<LocalMedicationDataSource>(
    () => LocalMedicationDataSource(medsBox),
  );

  // Plan DS/Repo hazır olduğunda (şimdilik yorumda bırakıyoruz)
  // sl.registerLazySingleton<LocalMedicationPlanDataSource>(
  //   () => LocalMedicationPlanDataSource(plansBox),
  // );

  // ---------- Repositories ----------
  sl.registerLazySingleton<MedicationRepository>(
    () => MedicationRepositoryImpl(sl()),
  );

  // sl.registerLazySingleton<MedicationPlanRepository>(
  //   () => MedicationPlanRepositoryImpl(sl()),
  // );

  // ---------- Use Cases ----------
  sl.registerLazySingleton<GetAllMedications>(() => GetAllMedications(sl()));
  sl.registerLazySingleton<CreateMedication>(() => CreateMedication(sl()));
  sl.registerLazySingleton<DeleteMedication>(() => DeleteMedication(sl()));
  sl.registerLazySingleton<EditMedication>(() => EditMedication(sl()));

  // Plan tarafı use case’leri eklenince:
  // sl.registerLazySingleton<BuildAndApplyPlan>(() => BuildAndApplyPlan(sl(), sl(), sl()));
  // sl.registerLazySingleton<CancelPlan>(() => CancelPlan(sl(), sl()));
  // vb.
}
