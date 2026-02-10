/// App route name constants
/// Centralized route definitions to avoid string literals
class AppRoutes {
  AppRoutes._();

  // Auth & Gate
  static const String authGate = '/';
  static const String login = '/login';
  
  // Main routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';

  // Feature routes
  static const String menu = '/menu';
  static const String categories = '/categories';
  static const String settings = '/settings';
}
