// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
      $medicationFormRoute,
      $addCatalogEntryConfirmRoute,
      $medicationEditRoute,
      $doseIntakeRoute,
      $missedDosesRoute,
      $medicationDetailsDialogRoute,
      $confirmDeleteMedicationRoute,
    ];

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: $HomeRouteExtension._fromState,
    );

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $medicationFormRoute => GoRouteData.$route(
      path: '/medications/new',
      factory: $MedicationFormRouteExtension._fromState,
    );

extension $MedicationFormRouteExtension on MedicationFormRoute {
  static MedicationFormRoute _fromState(GoRouterState state) =>
      const MedicationFormRoute();

  String get location => GoRouteData.$location(
        '/medications/new',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $addCatalogEntryConfirmRoute => GoRouteData.$route(
      path: '/catalog/add-confirmation',
      factory: $AddCatalogEntryConfirmRouteExtension._fromState,
    );

extension $AddCatalogEntryConfirmRouteExtension on AddCatalogEntryConfirmRoute {
  static AddCatalogEntryConfirmRoute _fromState(GoRouterState state) =>
      AddCatalogEntryConfirmRoute(
        name: state.uri.queryParameters['name']!,
        totalPills: int.parse(state.uri.queryParameters['total-pills']!)!,
        typeLabel: state.uri.queryParameters['type-label'],
      );

  String get location => GoRouteData.$location(
        '/catalog/add-confirmation',
        queryParams: {
          'name': name,
          'total-pills': totalPills.toString(),
          if (typeLabel != null) 'type-label': typeLabel,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $medicationEditRoute => GoRouteData.$route(
      path: '/medications/:id/edit',
      factory: $MedicationEditRouteExtension._fromState,
    );

extension $MedicationEditRouteExtension on MedicationEditRoute {
  static MedicationEditRoute _fromState(GoRouterState state) =>
      MedicationEditRoute(
        id: state.pathParameters['id']!,
      );

  String get location => GoRouteData.$location(
        '/medications/${Uri.encodeComponent(id)}/edit',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $doseIntakeRoute => GoRouteData.$route(
      path: '/dose/:id',
      factory: $DoseIntakeRouteExtension._fromState,
    );

extension $DoseIntakeRouteExtension on DoseIntakeRoute {
  static DoseIntakeRoute _fromState(GoRouterState state) => DoseIntakeRoute(
        id: state.pathParameters['id']!,
        occurrenceAt: _$convertMapValue(
            'occurrence-at', state.uri.queryParameters, DateTime.tryParse),
      );

  String get location => GoRouteData.$location(
        '/dose/${Uri.encodeComponent(id)}',
        queryParams: {
          if (occurrenceAt != null) 'occurrence-at': occurrenceAt!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

RouteBase get $missedDosesRoute => GoRouteData.$route(
      path: '/missed',
      factory: $MissedDosesRouteExtension._fromState,
    );

extension $MissedDosesRouteExtension on MissedDosesRoute {
  static MissedDosesRoute _fromState(GoRouterState state) =>
      const MissedDosesRoute();

  String get location => GoRouteData.$location(
        '/missed',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $medicationDetailsDialogRoute => GoRouteData.$route(
      path: '/medications/:id/details',
      factory: $MedicationDetailsDialogRouteExtension._fromState,
    );

extension $MedicationDetailsDialogRouteExtension
    on MedicationDetailsDialogRoute {
  static MedicationDetailsDialogRoute _fromState(GoRouterState state) =>
      MedicationDetailsDialogRoute(
        id: state.pathParameters['id']!,
      );

  String get location => GoRouteData.$location(
        '/medications/${Uri.encodeComponent(id)}/details',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $confirmDeleteMedicationRoute => GoRouteData.$route(
      path: '/medications/:id/confirm-delete',
      factory: $ConfirmDeleteMedicationRouteExtension._fromState,
    );

extension $ConfirmDeleteMedicationRouteExtension
    on ConfirmDeleteMedicationRoute {
  static ConfirmDeleteMedicationRoute _fromState(GoRouterState state) =>
      ConfirmDeleteMedicationRoute(
        id: state.pathParameters['id']!,
      );

  String get location => GoRouteData.$location(
        '/medications/${Uri.encodeComponent(id)}/confirm-delete',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
