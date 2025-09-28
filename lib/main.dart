import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'core/bootstrapper/hive_config.dart';
import 'core/navigation/app_routes.dart';
import 'core/background/missed_dose_worker.dart';
import 'core/service_locator.dart';

import 'features/medication_reminder/application/notifications/notification_initializer.dart';
import 'features/medication_reminder/application/notifications/notification_scheduler.dart';
import 'features/medication_reminder/domain/use_cases/get_all_medications.dart';
import 'features/medication_reminder/domain/use_cases/plan/reapply_plan_if_changed.dart';
import 'features/medication_reminder/presentation/blocs/medication/medication_bloc.dart';
import 'features/medication_reminder/presentation/blocs/medication/medication_event.dart';
import 'features/medication_reminder/infra/notifications/awesome_notifications_scheduler.dart';

import 'dart:convert';

Map<String, dynamic>? _extractPayload(dynamic payload) {
  if (payload == null) return null;
  if (payload is Map<String, dynamic>) {
    if (payload['type'] != null) return Map<String, dynamic>.from(payload);
    final data = payload['data'];
    if (data is String) {
      try { return Map<String, dynamic>.from((jsonDecode(data) as Map)); } catch (_) {}
    }
  }
  return null;
}

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
        .getInitialNotificationAction(removeFromActionEvents: true);
  }

  // Register hot-tap listener
  if (kUseAwesomeNotifications) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (action) async {
        final ctx = rootNavigatorKey.currentContext;
        final parsed = _extractPayload(action.payload);
        if (parsed == null) return;
        final type = parsed['type'];
        if (type == 'missed_dose') {
          ctx?.go(const MissedDosesRoute().location);
        } else if (type == 'take_dose') {
          final medId = parsed['medId'];
          if (medId is String && medId.isNotEmpty) {
            ctx?.go(DoseIntakeRoute(id: medId).location);
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
        consumeDose: sl(),
        skipDose: sl(),
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
      final action = widget.initialAction;
      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null || action == null) return;
      final parsed = _extractPayload(action.payload);
      if (parsed == null) return;
      final type = parsed['type'];
      if (type == 'missed_dose') {
        ctx.go(const MissedDosesRoute().location);
      } else if (type == 'take_dose') {
        final medId = parsed['medId'];
        if (medId is String && medId.isNotEmpty) {
          ctx.go(DoseIntakeRoute(id: medId).location);
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





