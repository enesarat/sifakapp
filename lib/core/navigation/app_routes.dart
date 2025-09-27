// lib/core/navigation/app_routes.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sifakapp/features/medication_reminder/domain/entities/medication.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_edit/medication_edit_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_list/medication_list_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/medication_form/medication_form_page.dart';
import 'package:sifakapp/features/medication_reminder/presentation/pages/missed/missed_doses_page.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();
  @override
  Widget build(BuildContext context, GoRouterState state)
    => const MedicationListPage();
}

@TypedGoRoute<MedicationFormRoute>(path: '/medications/new')
class MedicationFormRoute extends GoRouteData {
  const MedicationFormRoute();
  @override
  Widget build(BuildContext context, GoRouterState state)
    => const MedicationFormPage();
}

@TypedGoRoute<MedicationEditRoute>(path: '/medications/:id/edit')
class MedicationEditRoute extends GoRouteData {
  const MedicationEditRoute({required this.id}); // <- isim path ile aynÄ± olmalÄ±
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // Listeden gelirken extra ile Medication taÅŸÄ±yacaÄŸÄ±z
    final med = state.extra as Medication?;
    return MedicationEditPage(id: id, initialMedication: med);
  }
}

@TypedGoRoute<MissedDosesRoute>(path: '/missed')
class MissedDosesRoute extends GoRouteData {
  const MissedDosesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state)
    => const MissedDosesPage();
}

