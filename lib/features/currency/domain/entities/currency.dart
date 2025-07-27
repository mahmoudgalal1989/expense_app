import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String code;
  final bool isMostUsed;
  final String countryName;
  final String flagIconPath;
  final bool isSelected;

  const Currency({
    required this.code,
    required this.isMostUsed,
    required this.countryName,
    required this.flagIconPath,
    this.isSelected = false,
  });

  @override
  List<Object?> get props => [code, isMostUsed, countryName, flagIconPath, isSelected];

  Currency copyWith({
    String? code,
    bool? isMostUsed,
    String? countryName,
    String? flagIconPath,
    bool? isSelected,
  }) {
    return Currency(
      code: code ?? this.code,
      isMostUsed: isMostUsed ?? this.isMostUsed,
      countryName: countryName ?? this.countryName,
      flagIconPath: flagIconPath ?? this.flagIconPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
