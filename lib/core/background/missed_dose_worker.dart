import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/medication_reminder/application/plan/plan_builder.dart';
import '../../features/medication_reminder/data/data_sources/local_medication_datasource.dart';
import '../../features/medication_reminder/data/mappers/medication_mapper.dart';
import '../../features/medication_reminder/infra/notifications/awesome_notifications_scheduler.dart';
import '../../features/medication_reminder/data/repositories/dose_log_repository_impl.dart';
import '../../features/medication_reminder/domain/entities/dose_log.dart';
import '../../features/medication_reminder/data/mappers/dose_log_mapper.dart' as mapper;
import '../bootstrapper/hive_config.dart';

const String kMissedDoseTask = 'missed_dose_check';
const String kMissedDoseUniqueName = 'missed_dose_check_unique';

Future<void> registerMissedDoseWorker() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    kMissedDoseUniqueName,
    kMissedDoseTask,
    frequency: const Duration(minutes: 15),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if (task != kMissedDoseTask) return Future.value(true);

    await AwesomeNotificationsScheduler.initialize();

    try {
      final (medsBox, _, logsBox) = await HiveConfig.init();
      final ds = LocalMedicationDataSource(medsBox);
      final medsModels = await ds.getAll();
      final meds = medsModels.map(MedicationMapper.toEntity).toList();

      final now = DateTime.now();
      final from = now.subtract(const Duration(hours: 24));

      var missedCount = 0;
      final logsRepo = DoseLogRepositoryImpl(logsBox);
      for (final med in meds) {
        final plan = PlanBuilder.buildOneOffHorizon(
          med,
          from: from,
          to: now,
        );
        final missed = plan.oneOffs.where((o) => !o.scheduledAt.isAfter(now));
        missedCount += missed.length;

        // Yazılmamış kaçanları skipped olarak logla
        for (final o in missed) {
          final existing = await logsRepo.getByOccurrence(med.id, o.scheduledAt);
          if (existing == null) {
            final id = mapper.buildDoseLogId(med.id, o.scheduledAt);
            final log = DoseLog(
              id: id,
              medId: med.id,
              plannedAt: o.scheduledAt,
              resolvedAt: DateTime.now(),
              status: DoseLogStatus.skipped,
            );
            await logsRepo.upsert(log);
          }
        }
      }

      // Snooze baseline: notify only if count increased since last baseline
      final prefs = await Hive.openBox('app_prefs');
      final baseline = (prefs.get('missed_baseline') as int?) ?? 0;
      if (missedCount > 0 && missedCount > baseline) {
        final body = 'Kaçırılan dozlar var.\nSon 24 saatte $missedCount doz kaçırıldı';
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 910001,
            channelKey: 'med_reminders',
            title: 'Kaçırılan dozlar',
            body: body,
            category: NotificationCategory.Reminder,
            payload: const {'type': 'missed_dose'},
          ),
        );
        await prefs.put('missed_baseline', missedCount);
        await prefs.put('missed_baseline_set_at', DateTime.now().millisecondsSinceEpoch);
      }
    } catch (_) {}

    return Future.value(true);
  });
}

