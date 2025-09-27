// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
      $medicationFormRoute,
      $medicationEditRoute,
      $missedDosesRoute,
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
