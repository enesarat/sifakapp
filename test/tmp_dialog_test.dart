import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:sifakapp/core/navigation/app_routes.dart";

void main() {
  testWidgets('dialog route pushes', (tester) async {
    final router = GoRouter(
      routes: $appRoutes,
      initialLocation: '/',
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    router.go(AddCatalogEntryConfirmRoute(name: 'Foo', totalPills: 10).location);

    await tester.pumpAndSettle();

    expect(find.text('Foo'), findsOneWidget);
  });
}
