import 'package:equatable/equatable.dart';

/// Value object representing a range of amounts for filtering transactions
class AmountRange extends Equatable {
  /// Minimum amount (null means no minimum limit)
  final double? minAmount;
  
  /// Maximum amount (null means no maximum limit)
  final double? maxAmount;
  
  /// Whether to include transactions with amount equal to minAmount
  final bool includeMin;
  
  /// Whether to include transactions with amount equal to maxAmount
  final bool includeMax;

  const AmountRange({
    this.minAmount,
    this.maxAmount,
    this.includeMin = true,
    this.includeMax = true,
  });

  /// Creates an amount range with only minimum value
  const AmountRange.minimum(
    double minAmount, {
    bool includeMin = true,
  }) : this(
          minAmount: minAmount,
          maxAmount: null,
          includeMin: includeMin,
          includeMax: true,
        );

  /// Creates an amount range with only maximum value
  const AmountRange.maximum(
    double maxAmount, {
    bool includeMax = true,
  }) : this(
          minAmount: null,
          maxAmount: maxAmount,
          includeMin: true,
          includeMax: includeMax,
        );

  /// Creates an exact amount range (min == max)
  const AmountRange.exact(double amount)
      : this(
          minAmount: amount,
          maxAmount: amount,
          includeMin: true,
          includeMax: true,
        );

  /// Creates an amount range between two values
  const AmountRange.between(
    double minAmount,
    double maxAmount, {
    bool includeMin = true,
    bool includeMax = true,
  }) : this(
          minAmount: minAmount,
          maxAmount: maxAmount,
          includeMin: includeMin,
          includeMax: includeMax,
        );

  /// Returns true if this range has a minimum limit
  bool get hasMinLimit => minAmount != null;
  
  /// Returns true if this range has a maximum limit
  bool get hasMaxLimit => maxAmount != null;
  
  /// Returns true if this range has both min and max limits
  bool get hasBothLimits => hasMinLimit && hasMaxLimit;
  
  /// Returns true if this range represents an exact amount
  bool get isExact => hasBothLimits && minAmount == maxAmount;
  
  /// Returns true if the range is valid (min <= max when both are present)
  bool get isValid {
    if (!hasBothLimits) return true;
    return minAmount! <= maxAmount!;
  }

  /// Checks if the given amount falls within this range
  bool contains(double amount) {
    if (!isValid) return false;
    
    // Check minimum constraint
    if (hasMinLimit) {
      if (includeMin) {
        if (amount < minAmount!) return false;
      } else {
        if (amount <= minAmount!) return false;
      }
    }
    
    // Check maximum constraint
    if (hasMaxLimit) {
      if (includeMax) {
        if (amount > maxAmount!) return false;
      } else {
        if (amount >= maxAmount!) return false;
      }
    }
    
    return true;
  }

  /// Creates a copy of this range with updated values
  AmountRange copyWith({
    double? minAmount,
    double? maxAmount,
    bool? includeMin,
    bool? includeMax,
  }) {
    return AmountRange(
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      includeMin: includeMin ?? this.includeMin,
      includeMax: includeMax ?? this.includeMax,
    );
  }

  @override
  List<Object?> get props => [minAmount, maxAmount, includeMin, includeMax];

  @override
  String toString() {
    if (isExact) {
      return 'AmountRange.exact($minAmount)';
    }
    
    final minStr = hasMinLimit 
        ? '${includeMin ? '[' : '('}$minAmount'
        : '(-∞';
    final maxStr = hasMaxLimit 
        ? '$maxAmount${includeMax ? ']' : ')'}'
        : '∞)';
    
    return 'AmountRange($minStr, $maxStr)';
  }
}
