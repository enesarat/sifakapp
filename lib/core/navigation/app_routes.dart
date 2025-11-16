// lib/core/navigation/app_routes.dart
import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:go_router/go_router.dart';

import 'package:sifakapp/core/navigation/app_route_paths.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/catalog/add_to_catalog_dialog.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/catalog/models/catalog_add_confirmation.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/dose_intake/dose_intake_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_edit/medication_edit_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_form/medication_form_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/steps/step1_medication_info_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/steps/step2_dosage_schedule_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/steps/step3_reminder_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_wizard/medication_wizard_state.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_list/medication_list_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/dashboard/medication_dashboard_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_list/widgets/medication_details_dialog.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_list/widgets/confirm_delete_medication_dialog.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_list/widgets/delete_medication_dialog.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/missed/missed_doses_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/dose_now/dose_now_page.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(path: AppRoutePaths.home)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MedicationDashboardPage();
}

@TypedGoRoute<PlansRoute>(path: AppRoutePaths.plans)
class PlansRoute extends GoRouteData {
  const PlansRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MedicationListPage();
}

@TypedGoRoute<MedicationFormRoute>(path: AppRoutePaths.medicationsNew)
class MedicationFormRoute extends GoRouteData {
  const MedicationFormRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const Step1MedicationInfoPage();
}

// Wizard step routes (typed)
@TypedGoRoute<MedicationWizardStep1Route>(
  path: AppRoutePaths.medicationsNewStep1,
)
class MedicationWizardStep1Route extends GoRouteData {
  const MedicationWizardStep1Route();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const Step1MedicationInfoPage();
}

@TypedGoRoute<MedicationWizardStep2Route>(
  path: AppRoutePaths.medicationsNewStep2,
)
class MedicationWizardStep2Route extends GoRouteData {
  const MedicationWizardStep2Route();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final wiz = state.extra as MedicationWizardState?;
    return Step2DosageSchedulePage(wiz: wiz);
  }
}

@TypedGoRoute<MedicationWizardStep3Route>(
  path: AppRoutePaths.medicationsNewStep3,
)
class MedicationWizardStep3Route extends GoRouteData {
  const MedicationWizardStep3Route();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final wiz = state.extra as MedicationWizardState?;
    return Step3ReminderPage(wiz: wiz);
  }
}

@TypedGoRoute<AddCatalogEntryConfirmRoute>(
  path: AppRoutePaths.catalogAddConfirmation,
)
class AddCatalogEntryConfirmRoute extends GoRouteData {
  const AddCatalogEntryConfirmRoute({
    required this.name,
    required this.totalPills,
    this.typeLabel,
  });

  final String name;
  final int totalPills;
  final String? typeLabel;

  @override
  Page<CatalogAddDecision> buildPage(
    BuildContext context,
    GoRouterState state,
  ) {
    return DialogPage<CatalogAddDecision>(
      builder: (context) => AddToCatalogDialog(
        name: name,
        totalPills: totalPills,
        typeLabel: typeLabel,
      ),
    );
  }
}

@TypedGoRoute<MedicationEditRoute>(path: AppRoutePaths.medicationsEdit)
class MedicationEditRoute extends GoRouteData {
  const MedicationEditRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final medication = state.extra as Medication?;
    return MedicationEditPage(id: id, initialMedication: medication);
  }
}

@TypedGoRoute<DoseIntakeRoute>(path: AppRoutePaths.doseIntake)
class DoseIntakeRoute extends GoRouteData {
  const DoseIntakeRoute({required this.id, this.occurrenceAt});

  final String id;
  final DateTime? occurrenceAt;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DoseIntakePage(id: id, occurrenceAt: occurrenceAt);
}

@TypedGoRoute<MissedDosesRoute>(path: AppRoutePaths.missed)
class MissedDosesRoute extends GoRouteData {
  const MissedDosesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final src = state.uri.queryParameters['src'];
    final fromNotif = src == 'notif';
    return MissedDosesPage(fromNotification: fromNotif);
  }
}

@TypedGoRoute<DoseNowRoute>(path: AppRoutePaths.doseNow)
class DoseNowRoute extends GoRouteData {
  const DoseNowRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DoseNowPage();
}

@TypedGoRoute<MedicationDetailsDialogRoute>(path: AppRoutePaths.medicationDetails)
class MedicationDetailsDialogRoute extends GoRouteData {
  const MedicationDetailsDialogRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final med = state.extra as Medication?;
    return DialogPage<void>(
      builder: (context) => MedicationDetailsDialog(medication: med, id: id),
      barrierDismissible: true,
      // Cam/blur arkaplanlÄ± modal
      useGlassBackground: true,
      barrierColor: Colors.transparent,
      blurSigma: 14,
      overlayColor: Colors.black.withOpacity(0.35),
    );
  }
}

@TypedGoRoute<ConfirmDeleteMedicationRoute>(
  path: AppRoutePaths.medicationConfirmDelete,
)
class ConfirmDeleteMedicationRoute extends GoRouteData {
  const ConfirmDeleteMedicationRoute({required this.id});

  final String id;

  @override
  Page<bool> buildPage(BuildContext context, GoRouterState state) {
    final med = state.extra as Medication?;
    return DialogPage<bool>(
      builder: (context) => DeleteMedicationDialog(id: id, medication: med),
      barrierDismissible: true,
      useGlassBackground: true,
      barrierColor: Colors.transparent,
      blurSigma: 14,
      overlayColor: Colors.black.withOpacity(0.35),
    );
  }
}

class DialogPage<T> extends Page<T> {
  const DialogPage({
    required this.builder,
    this.barrierDismissible = true,
    this.barrierColor,
    this.useGlassBackground = false,
    this.blurSigma = 10,
    this.overlayColor,
    super.key,
  });

  final WidgetBuilder builder;
  final bool barrierDismissible;
  final Color? barrierColor;
  final bool useGlassBackground;
  final double blurSigma;
  final Color? overlayColor;

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      // Important for Navigator 2.0 (page-based) navigators:
      // ensure the created route carries this Page as its settings.
      settings: this,
      builder: (ctx) {
        final child = builder(ctx);
        if (!useGlassBackground) return child;
        return Stack(
          children: [
            // Arkaplanda cam/blur efektli katman
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(color: overlayColor ?? Colors.black.withOpacity(0.25)),
              ),
            ),
            // Diyalog iÃ§erik
            Center(child: child),
          ],
        );
      },
    );
  }
}
