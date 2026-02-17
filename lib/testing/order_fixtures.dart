import 'package:rodb_delivery_app/features/order-feature/domain/order.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/customer.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order_delivery.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order_item.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order_meta.dart';
import 'package:rodb_delivery_app/features/order-feature/domain/order_payment.dart';

/// Test fixtures for order data, based on the Firebase RTDB export.
///
/// Contains 3 representative orders from store 318920 covering:
/// - Order 1: Combo meal, 4 items, single quantities
/// - Order 2: Tenders menü, 4 items, includes multi-quantity item
/// - Order 3: Multi-category (burger + tenders + sauces), 6 items
class OrderFixtures {
  // --- Shared constants ---
  static const String storeId = '318920';
  static const String storeName = 'Trendyol Yemek';
  static const String currencyCode = 'TRY';
  static const String currencySymbol = '₺';
  static const String platform = 'TRENDYOLYEMEK';
  static const String integrationType = 'EXTENSION';
  static const String warmthType = 'HOT';

  // ═══════════════════════════════════════════════════════════════════════
  // ORDER 1 — Combo meal (10950695020)
  // ═══════════════════════════════════════════════════════════════════════

  static const String order1Id = '10950695020';
  static const String order1CardNumber = '007';
  static const double order1TotalPrice = 319.9;
  static const String order1CreationDate = '2026-02-10T13:02:26.440Z';

  static const Map<String, dynamic> order1Map = {
    'currency': {'code': currencyCode, 'symbol': currencySymbol},
    'customer': {
      'address': 'İsmetpaşa, Neşeli Sk. No:14 Daire:5 Zil:4',
      'addressDescription': 'Zil:4',
      'email': 'placeholder@trendyol.com',
      'firstName': 'Emirhan',
      'lastName': 'K.',
      'phone': '0212 365 34 03',
    },
    'delivery': {
      'address': 'İsmetpaşa, Neşeli Sk. No:14 Daire:5 Zil:4',
      'addressNote': 'ZİL:4 - Servis İstiyorum',
      'distance': 1500,
      'duration': 10,
      'latitude': 0,
      'longitude': 0,
    },
    'firebaseId': order1Id,
    'id': order1Id,
    'integrationOrderId': order1Id,
    'meta': {
      'clickingTime': order1CreationDate,
      'cookingTime': 10,
      'creationDate': order1CreationDate,
      'integrationOrderId': order1Id,
      'integrationType': integrationType,
      'isDelivered': false,
      'orderCardNumber': order1CardNumber,
      'platform': platform,
      'status': 'NEW',
      'warmthType': warmthType,
    },
    'orderCardNumber': order1CardNumber,
    'orderItems': [
      {
        'orderItemCount': 1,
        'orderItemDescription':
            '(Seçilen NFC tavuk burger, 2 tenders, patates kızartması, seçilen 2 sos)',
        'orderItemName': 'Combo 1',
        'orderItemPrice': '519,90₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'BBQ Kiss Burger Menü',
        'orderItemPrice': '0,00₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'El Yapımı Tatlı Acı Sos',
        'orderItemPrice': '0,00₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'El Yapımı Ballı Hardal Sos',
        'orderItemPrice': '0,00₺',
      },
    ],
    'orderPayment': {
      'date': order1CreationDate,
      'paymentType': 'PAID',
      'price': order1TotalPrice,
    },
    'receivedAt': '2026-02-10T13:02:27.083Z',
    'storeId': storeId,
    'storeName': storeName,
    'totalOrderPrice': order1TotalPrice,
  };

  // ═══════════════════════════════════════════════════════════════════════
  // ORDER 2 — NFC Tenders Menü with multi-quantity (10954466658)
  // ═══════════════════════════════════════════════════════════════════════

  static const String order2Id = '10954466658';
  static const String order2CardNumber = '00E';
  static const double order2TotalPrice = 602.9;
  static const String order2CreationDate = '2026-02-10T19:22:21.053Z';

  static const Map<String, dynamic> order2Map = {
    'currency': {'code': currencyCode, 'symbol': currencySymbol},
    'customer': {
      'address':
          'Cevat Paşa Mh Havan Tabya 1. Sk. Çelik Apt. No:12 Merkez',
      'addressDescription': '-',
      'email': 'placeholder@trendyol.com',
      'firstName': 'Mutlu',
      'lastName': 'Ç.',
      'phone': '0212 365 34 03',
    },
    'delivery': {
      'address':
          'Cevat Paşa Mh Havan Tabya 1. Sk. Çelik Apt. No:12 Merkez',
      'addressNote': 'Servis İstiyorum',
      'distance': 1500,
      'duration': 10,
      'latitude': 0,
      'longitude': 0,
    },
    'firebaseId': order2Id,
    'id': order2Id,
    'integrationOrderId': order2Id,
    'meta': {
      'clickingTime': order2CreationDate,
      'cookingTime': 10,
      'creationDate': order2CreationDate,
      'integrationOrderId': order2Id,
      'integrationType': integrationType,
      'isDelivered': false,
      'orderCardNumber': order2CardNumber,
      'platform': platform,
      'status': 'NEW',
      'warmthType': warmthType,
    },
    'orderCardNumber': order2CardNumber,
    'orderItems': [
      {
        'orderItemCount': 1,
        'orderItemDescription':
            '(3 çıtır tenders, 10 çıtır shot, patates kızartması, seçilen 2 el yapımı sos)',
        'orderItemName': 'NFC Tenders Menü',
        'orderItemPrice': '599,90₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'El Yapımı Kam Acı Sos',
        'orderItemPrice': '0,00₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'El Yapımı Kam Acı Sos',
        'orderItemPrice': '0,00₺',
      },
      {
        'orderItemCount': 2,
        'orderItemDescription': '',
        'orderItemName': 'Pepsi Pet (33 cl)',
        'orderItemPrice': '178,00₺',
      },
    ],
    'orderPayment': {
      'date': order2CreationDate,
      'paymentType': 'PAID',
      'price': order2TotalPrice,
    },
    'receivedAt': '2026-02-10T19:22:21.620Z',
    'storeId': storeId,
    'storeName': storeName,
    'totalOrderPrice': order2TotalPrice,
  };

  // ═══════════════════════════════════════════════════════════════════════
  // ORDER 3 — Multi-category: burger + tenders + sauces (10962634803)
  // ═══════════════════════════════════════════════════════════════════════

  static const String order3Id = '10962634803';
  static const String order3CardNumber = '004';
  static const double order3TotalPrice = 599.8;
  static const String order3CreationDate = '2026-02-13T15:58:03.248Z';

  static const Map<String, dynamic> order3Map = {
    'currency': {'code': currencyCode, 'symbol': currencySymbol},
    'customer': {
      'address':
          'Barbaros Mahallesi / Mehmet Çavuş Sokak / Salman Apartmanı',
      'addressDescription': '-',
      'email': 'placeholder@trendyol.com',
      'firstName': 'İnanç',
      'lastName': 'M.',
      'phone': '0212 365 34 03',
    },
    'delivery': {
      'address':
          'Barbaros Mahallesi / Mehmet Çavuş Sokak / Salman Apartmanı',
      'addressNote':
          'Ranch sosu biraz daha az koyarsanız sevinirim - Servis İstiyorum',
      'distance': 1500,
      'duration': 10,
      'latitude': 0,
      'longitude': 0,
    },
    'firebaseId': order3Id,
    'id': order3Id,
    'integrationOrderId': order3Id,
    'meta': {
      'clickingTime': order3CreationDate,
      'cookingTime': 10,
      'creationDate': order3CreationDate,
      'integrationOrderId': order3Id,
      'integrationType': integrationType,
      'isDelivered': false,
      'orderCardNumber': order3CardNumber,
      'platform': platform,
      'status': 'NEW',
      'warmthType': warmthType,
    },
    'orderCardNumber': order3CardNumber,
    'orderItems': [
      {
        'orderItemCount': 1,
        'orderItemDescription':
            '(NFC tavuk burger, el yapımı ranch sos, turşu,cheddar peynir, patates kızartması, seçilen 2 sos)',
        'orderItemName': 'Golden Rancher Burger Menü',
        'orderItemPrice': '399,90₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'El Yapımı Ballı Hardal Sos',
        'orderItemPrice': '0,00₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'Ketçap',
        'orderItemPrice': '0,00₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': "5'li Tenders",
        'orderItemPrice': '399,90₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'El Yapımı Tatlı Acı Sos',
        'orderItemPrice': '0,00₺',
      },
      {
        'orderItemCount': 1,
        'orderItemDescription': '',
        'orderItemName': 'Mayonez',
        'orderItemPrice': '0,00₺',
      },
    ],
    'orderPayment': {
      'date': order3CreationDate,
      'paymentType': 'PAID',
      'price': order3TotalPrice,
    },
    'receivedAt': '2026-02-13T15:58:03.765Z',
    'storeId': storeId,
    'storeName': storeName,
    'totalOrderPrice': order3TotalPrice,
  };

  // ═══════════════════════════════════════════════════════════════════════
  // DOMAIN MODEL INSTANCES
  // ═══════════════════════════════════════════════════════════════════════

  static const OrderCurrency defaultCurrency = OrderCurrency(
    code: currencyCode,
    symbol: currencySymbol,
  );

  static final Order testOrder1 = Order(
    id: order1Id,
    storeName: storeName,
    customer: const Customer(
      firstName: 'Emirhan',
      lastName: 'K.',
      phone: '0212 365 34 03',
      email: 'placeholder@trendyol.com',
      address: 'İsmetpaşa, Neşeli Sk. No:14 Daire:5 Zil:4',
      addressDescription: 'Zil:4',
    ),
    orderPayment: OrderPayment(
      paymentType: 'PAID',
      price: order1TotalPrice,
      date: DateTime.parse(order1CreationDate),
    ),
    orderItems: const [
      OrderItem(
        orderItemName: 'Combo 1',
        orderItemDescription:
            '(Seçilen NFC tavuk burger, 2 tenders, patates kızartması, seçilen 2 sos)',
        orderItemCount: 1,
        orderItemPrice: '519,90₺',
      ),
      OrderItem(
        orderItemName: 'BBQ Kiss Burger Menü',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
      OrderItem(
        orderItemName: 'El Yapımı Tatlı Acı Sos',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
      OrderItem(
        orderItemName: 'El Yapımı Ballı Hardal Sos',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
    ],
    delivery: const OrderDelivery(
      address: 'İsmetpaşa, Neşeli Sk. No:14 Daire:5 Zil:4',
      addressNote: 'ZİL:4 - Servis İstiyorum',
      latitude: 0,
      longitude: 0,
      distance: 1500,
      duration: 10,
    ),
    meta: const OrderMeta(
      integrationOrderId: order1Id,
      integrationType: integrationType,
      platform: platform,
      creationDate: order1CreationDate,
      clickingTime: order1CreationDate,
      warmthType: warmthType,
      cookingTime: 10,
      status: 'NEW',
      orderCardNumber: order1CardNumber,
      isDelivered: false,
    ),
    totalOrderPrice: order1TotalPrice,
    currency: defaultCurrency,
    integrationOrderId: order1Id,
    orderCardNumber: order1CardNumber,
  );

  static final Order testOrder2 = Order(
    id: order2Id,
    storeName: storeName,
    customer: const Customer(
      firstName: 'Mutlu',
      lastName: 'Ç.',
      phone: '0212 365 34 03',
      email: 'placeholder@trendyol.com',
      address: 'Cevat Paşa Mh Havan Tabya 1. Sk. Çelik Apt. No:12 Merkez',
      addressDescription: '-',
    ),
    orderPayment: OrderPayment(
      paymentType: 'PAID',
      price: order2TotalPrice,
      date: DateTime.parse(order2CreationDate),
    ),
    orderItems: const [
      OrderItem(
        orderItemName: 'NFC Tenders Menü',
        orderItemDescription:
            '(3 çıtır tenders, 10 çıtır shot, patates kızartması, seçilen 2 el yapımı sos)',
        orderItemCount: 1,
        orderItemPrice: '599,90₺',
      ),
      OrderItem(
        orderItemName: 'El Yapımı Kam Acı Sos',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
      OrderItem(
        orderItemName: 'El Yapımı Kam Acı Sos',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
      OrderItem(
        orderItemName: 'Pepsi Pet (33 cl)',
        orderItemDescription: '',
        orderItemCount: 2,
        orderItemPrice: '178,00₺',
      ),
    ],
    delivery: const OrderDelivery(
      address: 'Cevat Paşa Mh Havan Tabya 1. Sk. Çelik Apt. No:12 Merkez',
      addressNote: 'Servis İstiyorum',
      latitude: 0,
      longitude: 0,
      distance: 1500,
      duration: 10,
    ),
    meta: const OrderMeta(
      integrationOrderId: order2Id,
      integrationType: integrationType,
      platform: platform,
      creationDate: order2CreationDate,
      clickingTime: order2CreationDate,
      warmthType: warmthType,
      cookingTime: 10,
      status: 'NEW',
      orderCardNumber: order2CardNumber,
      isDelivered: false,
    ),
    totalOrderPrice: order2TotalPrice,
    currency: defaultCurrency,
    integrationOrderId: order2Id,
    orderCardNumber: order2CardNumber,
  );

  static final Order testOrder3 = Order(
    id: order3Id,
    storeName: storeName,
    customer: const Customer(
      firstName: 'İnanç',
      lastName: 'M.',
      phone: '0212 365 34 03',
      email: 'placeholder@trendyol.com',
      address: 'Barbaros Mahallesi / Mehmet Çavuş Sokak / Salman Apartmanı',
      addressDescription: '-',
    ),
    orderPayment: OrderPayment(
      paymentType: 'PAID',
      price: order3TotalPrice,
      date: DateTime.parse(order3CreationDate),
    ),
    orderItems: const [
      OrderItem(
        orderItemName: 'Golden Rancher Burger Menü',
        orderItemDescription:
            '(NFC tavuk burger, el yapımı ranch sos, turşu,cheddar peynir, patates kızartması, seçilen 2 sos)',
        orderItemCount: 1,
        orderItemPrice: '399,90₺',
      ),
      OrderItem(
        orderItemName: 'El Yapımı Ballı Hardal Sos',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
      OrderItem(
        orderItemName: 'Ketçap',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
      OrderItem(
        orderItemName: "5'li Tenders",
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '399,90₺',
      ),
      OrderItem(
        orderItemName: 'El Yapımı Tatlı Acı Sos',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
      OrderItem(
        orderItemName: 'Mayonez',
        orderItemDescription: '',
        orderItemCount: 1,
        orderItemPrice: '0,00₺',
      ),
    ],
    delivery: const OrderDelivery(
      address: 'Barbaros Mahallesi / Mehmet Çavuş Sokak / Salman Apartmanı',
      addressNote:
          'Ranch sosu biraz daha az koyarsanız sevinirim - Servis İstiyorum',
      latitude: 0,
      longitude: 0,
      distance: 1500,
      duration: 10,
    ),
    meta: const OrderMeta(
      integrationOrderId: order3Id,
      integrationType: integrationType,
      platform: platform,
      creationDate: order3CreationDate,
      clickingTime: order3CreationDate,
      warmthType: warmthType,
      cookingTime: 10,
      status: 'NEW',
      orderCardNumber: order3CardNumber,
      isDelivered: false,
    ),
    totalOrderPrice: order3TotalPrice,
    currency: defaultCurrency,
    integrationOrderId: order3Id,
    orderCardNumber: order3CardNumber,
  );

  /// All test orders as a list — sorted newest first (matching OrderService).
  static final List<Order> allOrders = [testOrder3, testOrder2, testOrder1];

  // ═══════════════════════════════════════════════════════════════════════
  // FULL "orders" NODE (matches Firebase JSON structure)
  // ═══════════════════════════════════════════════════════════════════════

  /// Mirrors the RTDB path: `orders/{storeId}/{orderId}`.
  static const Map<String, dynamic> ordersNode = {
    storeId: {
      order1Id: order1Map,
      order2Id: order2Map,
      order3Id: order3Map,
    },
  };
}
