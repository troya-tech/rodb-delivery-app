// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'RODB Teslimat Uygulaması';

  @override
  String get helloWorld => 'Merhaba Dünya!';

  @override
  String get signInTitle => 'Devam etmek için giriş yapın';

  @override
  String get signInButton => 'Google ile giriş yap';

  @override
  String get signInLoading => 'Giriş yapılıyor...';

  @override
  String get checkingConnection => 'Bağlantı kontrol ediliyor...';

  @override
  String get noInternetError => '📡 İnternet bağlantısı yok.\nLütfen ağınızı kontrol edip tekrar deneyin.';

  @override
  String get slowConnectionError => '🐌 Bağlantı çok yavaş.\nLütfen daha iyi bir ağda tekrar deneyin.';

  @override
  String get authError => '🔄 Kimlik doğrulama hatası.\nLütfen bir süre sonra tekrar deneyin.';

  @override
  String get configError => '⚙️ Yapılandırma hatası.\nLütfen destek ekibiyle iletişime geçin.';

  @override
  String get genericError => '❌ Giriş başarısız.\nLütfen tekrar deneyin.';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get welcomeMessage => 'Eve Hoşgeldiniz!';

  @override
  String get ordersTitle => 'Siparişler';

  @override
  String get noOrdersFound => 'Sipariş bulunamadı';

  @override
  String orderNumber(String number) {
    return 'Sipariş #$number';
  }

  @override
  String paymentType(String type) {
    return 'Ödeme Tipi: $type';
  }

  @override
  String ticketType(String type) {
    return 'Fiş: $type';
  }

  @override
  String get deliveryInfo => 'Teslimat Bilgileri';

  @override
  String address(String address) {
    return 'Adres: $address';
  }

  @override
  String note(String note) {
    return 'Not: $note';
  }

  @override
  String get openInMaps => 'Haritalarda Aç';

  @override
  String get getDirections => 'Yol Tarifi Al';

  @override
  String platform(String platform) {
    return 'Platform: $platform';
  }

  @override
  String created(String date) {
    return 'Oluşturulma: $date';
  }

  @override
  String integrationId(String id) {
    return 'Entegrasyon ID: $id';
  }

  @override
  String get profileTitle => 'Restoran Kullanıcı Profili';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirmation => 'Çıkış yapmak istediğinize emin misiniz?';

  @override
  String get cancel => 'İptal';

  @override
  String get notAuthenticated => 'Kimlik doğrulanmadı';

  @override
  String get role => 'Rol';

  @override
  String get associatedKeys => 'İlişkili Restoran Anahtarları:';

  @override
  String get noProfileFound => 'Restoran kullanıcı profili bulunamadı';

  @override
  String get paymentAndTotal => 'Ödeme ve Toplam';

  @override
  String get metaData => 'Üstveri';

  @override
  String get customerDetails => 'Müşteri Bilgileri';

  @override
  String phone(String phone) {
    return 'Telefon: $phone';
  }

  @override
  String email(String email) {
    return 'E-posta: $email';
  }

  @override
  String get orderItems => 'Sipariş Ürünleri';

  @override
  String get markAsDelivered => 'Teslim Edildi Olarak İşaretle';

  @override
  String get markAsDeliveredConfirmation => 'Bu siparişi teslim edildi olarak işaretlemek istediğinize emin misiniz?';

  @override
  String get confirm => 'Onayla';

  @override
  String get delivered => 'Teslim Edildi';

  @override
  String get performanceTitle => 'Performans';
}
