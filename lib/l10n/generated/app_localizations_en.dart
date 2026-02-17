// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RODB Delivery App';

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get signInTitle => 'Sign in to continue';

  @override
  String get signInButton => 'Sign in with Google';

  @override
  String get signInLoading => 'Signing in...';

  @override
  String get checkingConnection => 'Checking connection...';

  @override
  String get noInternetError => '📡 No internet connection.\nPlease check your network and try again.';

  @override
  String get slowConnectionError => '🐌 Connection is too slow.\nPlease try again on a better network.';

  @override
  String get authError => '🔄 Authentication error.\nPlease try again in a moment.';

  @override
  String get configError => '⚙️ Configuration error.\nPlease contact support.';

  @override
  String get genericError => '❌ Sign-in failed.\nPlease try again.';

  @override
  String get homeTitle => 'Home';

  @override
  String get welcomeMessage => 'Welcome Home!';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String orderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String paymentType(String type) {
    return 'Payment Type: $type';
  }

  @override
  String ticketType(String type) {
    return 'Ticket: $type';
  }

  @override
  String get deliveryInfo => 'Delivery Info';

  @override
  String address(String address) {
    return 'Address: $address';
  }

  @override
  String note(String note) {
    return 'Note: $note';
  }

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get getDirections => 'Get Directions';

  @override
  String platform(String platform) {
    return 'Platform: $platform';
  }

  @override
  String created(String date) {
    return 'Created: $date';
  }

  @override
  String integrationId(String id) {
    return 'Integration ID: $id';
  }

  @override
  String get profileTitle => 'Restaurant User Profile';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get notAuthenticated => 'Not authenticated';

  @override
  String get role => 'Role';

  @override
  String get associatedKeys => 'Associated Restaurant Keys:';

  @override
  String get noProfileFound => 'No restaurant user profile found';

  @override
  String get paymentAndTotal => 'Payment & Total';

  @override
  String get metaData => 'Metadata';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String phone(String phone) {
    return 'Phone: $phone';
  }

  @override
  String email(String email) {
    return 'Email: $email';
  }

  @override
  String get orderItems => 'Order Items';

  @override
  String get markAsDelivered => 'Mark as Delivered';

  @override
  String get markAsDeliveredConfirmation => 'Are you sure you want to mark this order as delivered?';

  @override
  String get confirm => 'Confirm';

  @override
  String get delivered => 'Delivered';

  @override
  String get performanceTitle => 'Performance';
}
