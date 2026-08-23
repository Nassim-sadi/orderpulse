import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/register_screen.dart';
import '../features/orders/domain/entities/order_entity.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  return switch (settings.name) {
    '/register' => MaterialPageRoute<void>(
        builder: (_) => const RegisterScreen(),
        settings: settings,
      ),
    '/order-detail' => MaterialPageRoute<void>(
        builder: (_) =>
            OrderDetailScreen(order: settings.arguments as OrderEntity),
        settings: settings,
      ),
    _ => null,
  };
}
