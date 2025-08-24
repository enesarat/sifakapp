import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sifakapp/core/bootstrapper/hive_config.dart';

import 'core/service_locator.dart';
import 'core/navigation/app_routes.dart';

import 'features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'features/medication_reminder/presentation/blocs/medication/medication_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tüm Hive init + adapter kayıt + box açma burada
  final (medsBox, plansBox) = await HiveConfig.init();

  // Service locator’ı iki kutu ile başlat
  setupLocator(medsBox, plansBox);

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
    routes: $appRoutes,
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
