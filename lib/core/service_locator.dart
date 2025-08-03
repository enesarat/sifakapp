import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../features/medication_reminder/data/data_sources/local_medication_datasource.dart';
import '../features/medication_reminder/data/repositories/medication_repository_impl.dart';
import '../features/medication_reminder/domain/repositories/medication_repository.dart';
import '../features/medication_reminder/data/models/medication_model.dart';
import '../features/medication_reminder/domain/use_cases/create_medication.dart';
import '../features/medication_reminder/domain/use_cases/delete_medication.dart';
import '../features/medication_reminder/domain/use_cases/get_all_medications.dart';

final sl = GetIt.instance;


void setupLocator(Box<MedicationModel> box) {
  // Data Source
  sl.registerLazySingleton<LocalMedicationDataSource>(() => LocalMedicationDataSource(box));

  // Repository
  sl.registerLazySingleton<MedicationRepository>(() => MedicationRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton<GetAllMedications>(() => GetAllMedications(sl()));
  sl.registerLazySingleton<CreateMedication>(() => CreateMedication(sl()));
  sl.registerLazySingleton<DeleteMedication>(() => DeleteMedication(sl()));
}
