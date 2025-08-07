import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sifakapp/core/service_locator.dart';
import 'features/medication_reminder/data/models/medication_model.dart';
import 'features/medication_reminder/presentation/bloc/medication_bloc.dart';
import 'features/medication_reminder/presentation/bloc/medication_event.dart';
import 'features/medication_reminder/presentation/pages/medication_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(MedicationModelAdapter());

  final box = await Hive.openBox<MedicationModel>('medications');

  setupLocator(box);

  runApp(
    BlocProvider(
      create: (_) => MedicationBloc(
        getAllMedications: sl(),
        createMedication: sl(),
        deleteMedication: sl(),
        editMedication: sl(),
      )..add(FetchAllMedications()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İlaç Hatırlatıcı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MedicationListPage(),
    );
  }
}
