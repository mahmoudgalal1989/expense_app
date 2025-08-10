import 'package:equatable/equatable.dart';
import '../../domain/entities/currency.dart';

class CurrencyModel extends Equatable {
  final String id;
  final String code;
  final String symbol;
  final bool isMostUsed;
  final String countryName;
  final String flagIconPath;

  const CurrencyModel({
    required this.id,
    required this.code,
    required this.symbol,
    required this.isMostUsed,
    required this.countryName,
    required this.flagIconPath,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] as String? ?? json['code'] as String, // Use code as fallback ID
      code: json['code'] as String,
      symbol: json['symbol'] as String? ?? json['code'] as String, // Fallback to code if symbol not provided
      isMostUsed: json['isMostUsed'] as bool? ?? false,
      countryName: json['countryName'] as String,
      flagIconPath: json['flagIconPath'] as String? ??
          'assets/flags/${(json['code'] as String).toLowerCase()}.png',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'symbol': symbol,
        'isMostUsed': isMostUsed,
        'countryName': countryName,
        'flagIconPath': flagIconPath,
      };

  CurrencyModel copyWith({
    String? id,
    String? code,
    String? symbol,
    bool? isMostUsed,
    String? countryName,
    String? flagIconPath,
  }) {
    return CurrencyModel(
      id: id ?? this.id,
      code: code ?? this.code,
      symbol: symbol ?? this.symbol,
      isMostUsed: isMostUsed ?? this.isMostUsed,
      countryName: countryName ?? this.countryName,
      flagIconPath: flagIconPath ?? this.flagIconPath,
    );
  }

  @override
  List<Object?> get props => [id, code, symbol, isMostUsed, countryName, flagIconPath];

  // Convert CurrencyModel to Currency entity
  Currency toEntity() {
    return Currency(
      id: id,
      code: code,
      symbol: symbol,
      isMostUsed: isMostUsed,
      countryName: countryName,
      flagIconPath: flagIconPath,
    );
  }

  // Create CurrencyModel from Currency entity
  factory CurrencyModel.fromEntity(Currency currency) {
    return CurrencyModel(
      id: currency.id,
      code: currency.code,
      symbol: currency.symbol,
      isMostUsed: currency.isMostUsed,
      countryName: currency.countryName,
      flagIconPath: currency.flagIconPath,
    );
  }
}
