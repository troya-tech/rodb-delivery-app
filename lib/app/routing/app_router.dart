import 'package:flutter/material.dart';
import '../../features/order-feature/domain/order.dart';
import '../pages/auth-gate-page/auth_gate_page.dart';
import '../pages/home_page/home_page.dart';
import '../pages/orders-page/orders-page.dart';
import '../pages/order-details-page/order_details_page.dart';
import '../pages/profile-page/profile-page.dart';
import '../pages/login-page/login_page.dart';
import 'app_routes.dart';

/// Centralized app router configuration
class AppRouter {
  AppRouter._();

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.authGate:
        return MaterialPageRoute(
          builder: (_) => const AuthGatePage(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case AppRoutes.orders:
        return MaterialPageRoute(
          builder: (_) => const OrdersPage(),
          settings: settings,
        );

      case AppRoutes.orderDetails:
        final order = settings.arguments as Order;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsPage(order: order),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      default:
        return _errorRoute(settings.name);
    }
  }

  /// Error route for undefined routes
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Route not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                routeName ?? 'Unknown route',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
