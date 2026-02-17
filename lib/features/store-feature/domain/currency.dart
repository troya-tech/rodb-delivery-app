import 'package:equatable/equatable.dart';

/// Value object representing a monetary currency.
class Currency extends Equatable {
  final String code;
  final String symbol;

  const Currency({
    required this.code,
    required this.symbol,
  });

  /// Default currency used when none is specified.
  static const Currency defaultCurrency = Currency(code: 'TRY', symbol: '₺');

  factory Currency.fromMap(Map<dynamic, dynamic> map) {
    return Currency(
      code: map['code'] as String? ?? 'TRY',
      symbol: map['symbol'] as String? ?? '₺',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'symbol': symbol,
    };
  }

  @override
  List<Object?> get props => [code, symbol];
}
