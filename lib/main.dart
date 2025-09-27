import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'core/bootstrapper/hive_config.dart';
import 'core/navigation/app_routes.dart';
import 'core/service_locator.dart';

import 'features/medication_reminder/application/notifications/notification_initializer.dart';
import 'features/medication_reminder/application/notifications/notification_scheduler.dart';
import 'features/medication_reminder/domain/use_cases/get_all_medications.dart';
import 'features/medication_reminder/domain/use_cases/plan/reapply_plan_if_changed.dart';
import 'features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'features/medication_reminder/presentation/blocs/medication/medication_event.dart';
import 'features/medication_reminder/infra/notifications/awesome_notifications_scheduler.dart';
import 'core/background/missed_dose_worker.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
const bool kUseAwesomeNotifications = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kUseAwesomeNotifications) {
    await AwesomeNotificationsScheduler.initialize();
  }

  final (medsBox, plansBox) = await HiveConfig.init();

  final FlutterLocalNotificationsPlugin plugin =
      await NotificationInitializer.initialize(onTap: (payload) async {});

  setupLocator(
    medsBox,
    plansBox,
    notificationsPlugin: plugin,
    useAwesomeNotifications: kUseAwesomeNotifications,
  );

  await sl<NotificationScheduler>().requestPermissions();
  await registerMissedDoseWorker();

  try {
    final meds = await sl<GetAllMedications>()();
    final reapply = sl<ReapplyPlanIfChanged>();
    for (final m in meds) {
      await reapply(m);
    }
  } catch (_) {}

  // Read initial action without removing from stream
  ReceivedAction? initialAction;
  if (kUseAwesomeNotifications) {
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  // Register hot-tap listener
  if (kUseAwesomeNotifications) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (action) async {
        if (action.payload?['type'] == 'missed_dose') {
          final ctx = rootNavigatorKey.currentContext;
          if (ctx != null) {
            ctx.go(const MissedDosesRoute().location);
          }
        }
      },
    );
  }

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
      child: MyApp(initialAction: initialAction),
    ),
  );
}

class MyApp extends StatefulWidget {
  final ReceivedAction? initialAction;
  const MyApp({super.key, this.initialAction});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final _router =
      GoRouter(navigatorKey: rootNavigatorKey, routes: $appRoutes);

  @override
  void initState() {
    super.initState();
    // Cold-start navigation (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initialAction?.payload?['type'] == 'missed_dose') {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null) {
          ctx.go(const MissedDosesRoute().location);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ilac Hatirlatici',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}
