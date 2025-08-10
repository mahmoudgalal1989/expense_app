/// Enum representing how multiple categories should be filtered
enum CategoryFilterType {
  /// Match transactions that have ANY of the specified categories (OR logic)
  any,
  
  /// Match transactions that have ALL of the specified categories (AND logic)
  all,
}

/// Extension to provide utility methods for CategoryFilterType
extension CategoryFilterTypeExtension on CategoryFilterType {
  /// Returns true if this is ANY filter type
  bool get isAny => this == CategoryFilterType.any;
  
  /// Returns true if this is ALL filter type
  bool get isAll => this == CategoryFilterType.all;
  
  /// Returns a human-readable string representation
  String get displayName {
    switch (this) {
      case CategoryFilterType.any:
        return 'Any Category';
      case CategoryFilterType.all:
        return 'All Categories';
    }
  }
  
  /// Returns a description of the filter logic
  String get description {
    switch (this) {
      case CategoryFilterType.any:
        return 'Transactions with at least one of the selected categories';
      case CategoryFilterType.all:
        return 'Transactions with all of the selected categories';
    }
  }
}
