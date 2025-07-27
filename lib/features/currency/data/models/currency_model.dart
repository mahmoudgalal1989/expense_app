import 'package:equatable/equatable.dart';
import '../../domain/entities/currency.dart';

class CurrencyModel extends Equatable {
  final String code;
  final bool isMostUsed;
  final String countryName;
  final String flagIconPath;
  final bool isSelected;

  const CurrencyModel({
    required this.code,
    required this.isMostUsed,
    required this.countryName,
    required this.flagIconPath,
    this.isSelected = false,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] as String,
      isMostUsed: json['isMostUsed'] as bool? ?? false,
      countryName: json['countryName'] as String,
      flagIconPath: json['flagIconPath'] as String? ?? 'assets/flags/${(json['code'] as String).toLowerCase()}.png',
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'isMostUsed': isMostUsed,
        'countryName': countryName,
        'flagIconPath': flagIconPath,
        'isSelected': isSelected,
      };

  CurrencyModel copyWith({
    String? code,
    bool? isMostUsed,
    String? countryName,
    String? flagIconPath,
    bool? isSelected,
  }) {
    return CurrencyModel(
      code: code ?? this.code,
      isMostUsed: isMostUsed ?? this.isMostUsed,
      countryName: countryName ?? this.countryName,
      flagIconPath: flagIconPath ?? this.flagIconPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [code, isMostUsed, countryName, flagIconPath, isSelected];
  
  // Convert CurrencyModel to Currency entity
  Currency toEntity() {
    return Currency(
      code: code,
      isMostUsed: isMostUsed,
      countryName: countryName,
      flagIconPath: flagIconPath,
      isSelected: isSelected,
    );
  }
  
  // Create CurrencyModel from Currency entity
  factory CurrencyModel.fromEntity(Currency currency) {
    return CurrencyModel(
      code: currency.code,
      isMostUsed: currency.isMostUsed,
      countryName: currency.countryName,
      flagIconPath: currency.flagIconPath,
      isSelected: currency.isSelected,
    );
  }
}
