import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/medication_reminder/application/plan/plan_builder.dart';
import '../../features/medication_reminder/data/data_sources/local_medication_datasource.dart';
import '../../features/medication_reminder/data/mappers/medication_mapper.dart';
import '../../features/medication_reminder/infra/notifications/awesome_notifications_scheduler.dart';
import '../bootstrapper/hive_config.dart';

const String kMissedDoseTask = 'missed_dose_check';
const String kMissedDoseUniqueName = 'missed_dose_check_unique';

Future<void> registerMissedDoseWorker() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    kMissedDoseUniqueName,
    kMissedDoseTask,
    // Android en az ~15 dakika destekler; test için 15 dk seçildi
    frequency: const Duration(minutes: 15),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if (task != kMissedDoseTask) return Future.value(true);

    // Ensure notification channel exists (idempotent)
    await AwesomeNotificationsScheduler.initialize();

    try {
      final (medsBox, _) = await HiveConfig.init();
      final ds = LocalMedicationDataSource(medsBox);
      final medsModels = await ds.getAll();
      final meds = medsModels.map(MedicationMapper.toEntity).toList();

      final now = DateTime.now();
      final from = now.subtract(const Duration(hours: 5));

      var hasMissed = false;
      for (final med in meds) {
        final plan = PlanBuilder.buildOneOffHorizon(
          med,
          from: from,
          to: now,
        );
        final missed = plan.oneOffs.where((o) => !o.scheduledAt.isAfter(now));
        if (missed.isNotEmpty) {
          hasMissed = true;
          break;
        }
      }

      if (hasMissed) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 910001,
            channelKey: 'med_reminders',
            title: 'Kaçırılan dozlar',
            body: 'Cihazınız kapalıyken zamanı atlanmış dozlarınız bulunmaktadır!',
            category: NotificationCategory.Reminder,
          ),
        );
      }
    } catch (_) {}

    return Future.value(true);
  });
}
