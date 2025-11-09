import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          ctx?.go('${const MissedDosesRoute().location}?src=notif');
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
        ctx.go('${const MissedDosesRoute().location}?src=notif');
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
      title: 'İlaç Hatırlatıcı',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: _router,
    );
  }
}






ThemeData _buildTheme(Brightness brightness) {
  const primary = Color(0xFF13B6EC);
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
  );
  final schemeFixed = scheme.copyWith(primary: primary);
  return base.copyWith(
    colorScheme: schemeFixed,
    primaryColor: primary,
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: schemeFixed.surfaceVariant.withOpacity(brightness == Brightness.light ? 0.6 : 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(width: 2, color: primary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: primary,
      thumbColor: primary,
      overlayColor: primary.withOpacity(0.15),
      inactiveTrackColor: schemeFixed.surfaceVariant,
    ),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
    ),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    cardTheme: base.cardTheme.copyWith(
      color: brightness == Brightness.light ? Colors.white : const Color(0xFF2D2F34),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
  );
}



