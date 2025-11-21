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
      // New rule: mark as missed if an occurrence is at least 1 hour overdue
      final cutoff = now.subtract(const Duration(hours: 1));

      // Keep a moving watermark so we don't rescan endlessly
      final prefs = await Hive.openBox('app_prefs');
      final lastProcessedMillis = prefs.get('missed_last_processed_to') as int?;
      DateTime lastProcessed = lastProcessedMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(lastProcessedMillis)
          : now.subtract(const Duration(days: 7)); // safety horizon for first run
      if (lastProcessed.isAfter(cutoff)) {
        // Ensure we always have a non-empty window to scan
        lastProcessed = cutoff.subtract(const Duration(minutes: 1));
      }

      final logsRepo = DoseLogRepositoryImpl(logsBox);
      if (!cutoff.isAfter(lastProcessed)) {
        // Nothing to process for missed marking; continue to notifications logic
      } else {
        for (final med in meds) {
          final plan = PlanBuilder.buildOneOffHorizon(
            med,
            from: lastProcessed,
            to: cutoff,
          );
          final occurrences = plan.oneOffs.where(
            (o) => !o.scheduledAt.isAfter(cutoff),
          );

          // Mark as missed if no prior log exists
          // Resolve creation time from id if possible (fallback: med.startDate)
          DateTime createdAt;
          final idMillis = int.tryParse(med.id);
          if (idMillis != null) {
            createdAt = DateTime.fromMillisecondsSinceEpoch(idMillis);
          } else {
            createdAt = med.startDate;
          }

          for (final o in occurrences) {
            // If this is the medication's creation day, ignore occurrences before creation time
            final sameCreationDay = o.scheduledAt.year == createdAt.year &&
                o.scheduledAt.month == createdAt.month &&
                o.scheduledAt.day == createdAt.day;
            if (sameCreationDay && !o.scheduledAt.isAfter(createdAt)) {
              continue;
            }

            final existing = await logsRepo.getByOccurrence(med.id, o.scheduledAt);
            if (existing == null) {
              final id = mapper.buildDoseLogId(med.id, o.scheduledAt);
              final log = DoseLog(
                id: id,
                medId: med.id,
                plannedAt: o.scheduledAt,
                resolvedAt: DateTime.now(),
                status: DoseLogStatus.missed,
                acknowledged: false,
              );
              await logsRepo.upsert(log);
            }
          }
        }
        await prefs.put('missed_last_processed_to', cutoff.millisecondsSinceEpoch);
      }

      // Unacknowledged missed count (for notifications)
      final notifWindowStart = now.subtract(const Duration(hours: 24));
      final logsInRange = await logsRepo.getInRange(notifWindowStart, now);
      final missedCount = logsInRange
          .where((l) => l.status == DoseLogStatus.missed && !l.acknowledged)
          .length;

      // Snooze baseline: notify only if count increased since last baseline
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

