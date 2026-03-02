import 'package:bootstrap/extensions/iterable_extension.dart';
import 'package:bootstrap/interfaces/modules/module/module.dart';
import 'package:bootstrap/interfaces/modules/router/router_factory.dart';
import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

class GoRouterFactory extends RouterFactory<RouteBase, GoRouter> {
  GoRouterFactory({
    this.initialLocation,
    this.restorationScopeId,
    this.observers,
    this.redirect,
  });

  final String? initialLocation;
  final String? restorationScopeId;
  final List<NavigatorObserver>? observers;
  final GoRouterRedirect? redirect;

  @override
  GoRouter buildRouter(List<ModuleRoutes<RouteBase>> modules) {
    final routes = modules.map((e) => e.routes).flatten().toList();

    return GoRouter(
      initialLocation: initialLocation,
      restorationScopeId: restorationScopeId,
      observers: observers,
      routes: routes,
      redirect: redirect,
    );
  }
}
