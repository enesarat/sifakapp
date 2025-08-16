// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sifakapp/core/navigation/app_routes.dart';

import 'core/service_locator.dart';
import 'features/medication_reminder/data/models/medication_model.dart';
import 'features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'features/medication_reminder/presentation/blocs/medication/medication_event.dart';

import 'package:go_router/go_router.dart';

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

  static final _router = GoRouter(
    routes: $appRoutes, // app_routes.g.dart içinden geliyor
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'İlaç Hatırlatıcı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}
