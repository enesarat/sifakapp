import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sifakapp/core/bootstrapper/hive_config.dart';

import 'core/service_locator.dart';
import 'core/navigation/app_routes.dart';

import 'features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'features/medication_reminder/presentation/blocs/medication/medication_event.dart';

import 'features/medication_reminder/application/notifications/notification_initializer.dart';
// scheduler arayüzü (izin isteyeceğiz)
import 'features/medication_reminder/application/notifications/notification_scheduler.dart';
import 'features/medication_reminder/infra/notifications/flutter_local_notifications_scheduler.dart';
import 'features/medication_reminder/infra/notifications/awesome_notifications_scheduler.dart';
const bool kUseAwesomeNotifications = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kUseAwesomeNotifications) {
    await AwesomeNotificationsScheduler.initialize();
  }

  // 1) Hive init + kutular
  final (medsBox, plansBox) = await HiveConfig.init();

  // 2) Bildirim plugin init (tz dahil)
  final FlutterLocalNotificationsPlugin plugin =
      await NotificationInitializer.initialize(
    onTap: (payload) async {
      // TODO: payload parse edip ilgili sayfaya yÃ¶nlendir (navigationKey vs.)
    },
  );

  // Debug flagler kapalÄ± (prod)
  // 3) Service locator (plugin'i enjekte ediyoruz)
  setupLocator(medsBox, plansBox, notificationsPlugin: plugin, useAwesomeNotifications: kUseAwesomeNotifications);

  // 4) Android 13+ ve iOS izinleri (uygulama ilk aÃ§Ä±lÄ±ÅŸta ya da ayarlardan tetikleyebilirsin)
  await sl<NotificationScheduler>().requestPermissions();

  // 5) UygulamayÄ± baÅŸlat
  runApp(
    BlocProvider(
      create: (_) => MedicationBloc(
        getAllMedications: sl(),
        createMedication: sl(),
        deleteMedication: sl(),
        editMedication: sl(),
        applyPlanForMedication: sl(),
        reapplyPlanIfChanged: sl(),
        cancelPlanForMedication: sl(),
      )..add(FetchAllMedications()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(routes: $appRoutes);

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

