import 'package:equatable/equatable.dart';
import '../../domain/entities/currency.dart';

class CurrencyModel extends Equatable {
  final String code;
  final bool isMostUsed;
  final String countryName;
  final String flagIconPath;

  const CurrencyModel({
    required this.code,
    required this.isMostUsed,
    required this.countryName,
    required this.flagIconPath,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] as String,
      isMostUsed: json['isMostUsed'] as bool? ?? false,
      countryName: json['countryName'] as String,
      flagIconPath: json['flagIconPath'] as String? ??
          'assets/flags/${(json['code'] as String).toLowerCase()}.png',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'isMostUsed': isMostUsed,
        'countryName': countryName,
        'flagIconPath': flagIconPath,
      };

  CurrencyModel copyWith({
    String? code,
    bool? isMostUsed,
    String? countryName,
    String? flagIconPath,
  }) {
    return CurrencyModel(
      code: code ?? this.code,
      isMostUsed: isMostUsed ?? this.isMostUsed,
      countryName: countryName ?? this.countryName,
      flagIconPath: flagIconPath ?? this.flagIconPath,
    );
  }

  @override
  List<Object?> get props => [code, isMostUsed, countryName, flagIconPath];

  // Convert CurrencyModel to Currency entity
  Currency toEntity() {
    return Currency(
      code: code,
      isMostUsed: isMostUsed,
      countryName: countryName,
      flagIconPath: flagIconPath,
    );
  }

  // Create CurrencyModel from Currency entity
  factory CurrencyModel.fromEntity(Currency currency) {
    return CurrencyModel(
      code: currency.code,
      isMostUsed: currency.isMostUsed,
      countryName: currency.countryName,
      flagIconPath: currency.flagIconPath,
    );
  }
}
