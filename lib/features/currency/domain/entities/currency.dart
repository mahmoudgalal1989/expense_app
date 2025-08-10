import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String id;
  final String code;
  final String symbol;
  final bool isMostUsed;
  final String countryName;
  final String flagIconPath;
  final bool isSelected;

  const Currency({
    required this.id,
    required this.code,
    required this.symbol,
    required this.isMostUsed,
    required this.countryName,
    required this.flagIconPath,
    this.isSelected = false,
  });

  @override
  List<Object?> get props =>
      [id, code, symbol, isMostUsed, countryName, flagIconPath, isSelected];

  Currency copyWith({
    String? id,
    String? code,
    String? symbol,
    bool? isMostUsed,
    String? countryName,
    String? flagIconPath,
    bool? isSelected,
  }) {
    return Currency(
      id: id ?? this.id,
      code: code ?? this.code,
      symbol: symbol ?? this.symbol,
      isMostUsed: isMostUsed ?? this.isMostUsed,
      countryName: countryName ?? this.countryName,
      flagIconPath: flagIconPath ?? this.flagIconPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
