import 'package:equatable/equatable.dart';
import '../entities/transaction_type.dart';
import '../enums/category_filter_type.dart';
import 'amount_range.dart';
import 'date_range.dart';

/// Value object representing comprehensive filter criteria for transactions
class FilterCriteria extends Equatable {
  /// List of category IDs to filter by (null means no category filter)
  final List<String>? categoryIds;
  
  /// How to apply category filtering when multiple categories are specified
  final CategoryFilterType categoryFilterType;
  
  /// Currency code to filter by (null means no currency filter)
  final String? currencyCode;
  
  /// Date range to filter by (null means no date filter)
  final DateRange? dateRange;
  
  /// Transaction type to filter by (null means no type filter)
  final TransactionType? type;
  
  /// Text to search in transaction notes (null means no note search)
  final String? noteSearch;
  
  /// Amount range to filter by (null means no amount filter)
  final AmountRange? amountRange;
  
  /// Whether to include transactions without any categories in category filtering
  final bool includeTransactionsWithoutCategories;

  const FilterCriteria({
    this.categoryIds,
    this.categoryFilterType = CategoryFilterType.any,
    this.currencyCode,
    this.dateRange,
    this.type,
    this.noteSearch,
    this.amountRange,
    this.includeTransactionsWithoutCategories = false,
  });

  /// Creates an empty filter criteria (no filters applied)
  const FilterCriteria.empty()
      : categoryIds = null,
        categoryFilterType = CategoryFilterType.any,
        currencyCode = null,
        dateRange = null,
        type = null,
        noteSearch = null,
        amountRange = null,
        includeTransactionsWithoutCategories = false;

  /// Creates filter criteria for a specific category
  FilterCriteria.forCategory(String categoryId)
      : categoryIds = [categoryId],
        categoryFilterType = CategoryFilterType.any,
        currencyCode = null,
        dateRange = null,
        type = null,
        noteSearch = null,
        amountRange = null,
        includeTransactionsWithoutCategories = false;

  /// Creates filter criteria for multiple categories
  FilterCriteria.forCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
    bool includeWithoutCategories = false,
  })  : categoryIds = categoryIds,
        categoryFilterType = filterType,
        currencyCode = null,
        dateRange = null,
        type = null,
        noteSearch = null,
        amountRange = null,
        includeTransactionsWithoutCategories = includeWithoutCategories;

  /// Creates filter criteria for a specific currency
  FilterCriteria.forCurrency(String currencyCode)
      : categoryIds = null,
        categoryFilterType = CategoryFilterType.any,
        currencyCode = currencyCode,
        dateRange = null,
        type = null,
        noteSearch = null,
        amountRange = null,
        includeTransactionsWithoutCategories = false;

  /// Creates filter criteria for a specific transaction type
  FilterCriteria.forType(TransactionType type)
      : categoryIds = null,
        categoryFilterType = CategoryFilterType.any,
        currencyCode = null,
        dateRange = null,
        type = type,
        noteSearch = null,
        amountRange = null,
        includeTransactionsWithoutCategories = false;

  /// Creates filter criteria for a date range
  FilterCriteria.forDateRange(DateRange dateRange)
      : categoryIds = null,
        categoryFilterType = CategoryFilterType.any,
        currencyCode = null,
        dateRange = dateRange,
        type = null,
        noteSearch = null,
        amountRange = null,
        includeTransactionsWithoutCategories = false;

  /// Returns true if no filters are applied
  bool get isEmpty =>
      categoryIds == null &&
      currencyCode == null &&
      dateRange == null &&
      type == null &&
      noteSearch == null &&
      amountRange == null;

  /// Returns true if any filters are applied
  bool get isNotEmpty => !isEmpty;

  /// Returns true if category filtering is applied
  bool get hasCategoryFilter => categoryIds != null && categoryIds!.isNotEmpty;

  /// Returns true if currency filtering is applied
  bool get hasCurrencyFilter => currencyCode != null;

  /// Returns true if date filtering is applied
  bool get hasDateFilter => dateRange != null;

  /// Returns true if type filtering is applied
  bool get hasTypeFilter => type != null;

  /// Returns true if note search is applied
  bool get hasNoteFilter => noteSearch != null && noteSearch!.isNotEmpty;

  /// Returns true if amount filtering is applied
  bool get hasAmountFilter => amountRange != null;

  /// Returns the number of active filters
  int get activeFilterCount {
    int count = 0;
    if (hasCategoryFilter) count++;
    if (hasCurrencyFilter) count++;
    if (hasDateFilter) count++;
    if (hasTypeFilter) count++;
    if (hasNoteFilter) count++;
    if (hasAmountFilter) count++;
    return count;
  }

  /// Returns true if this criteria would potentially affect many transactions
  /// (used for safety checks in bulk operations)
  bool get isHighImpact {
    // Consider high impact if:
    // - No filters at all (affects everything)
    // - Only type filter (affects half of all transactions)
    // - Only currency filter (could affect many transactions)
    if (isEmpty) return true;
    if (activeFilterCount == 1 && (hasTypeFilter || hasCurrencyFilter)) return true;
    return false;
  }

  /// Creates a copy of this criteria with updated values
  FilterCriteria copyWith({
    List<String>? categoryIds,
    CategoryFilterType? categoryFilterType,
    String? currencyCode,
    DateRange? dateRange,
    TransactionType? type,
    String? noteSearch,
    AmountRange? amountRange,
    bool? includeTransactionsWithoutCategories,
  }) {
    return FilterCriteria(
      categoryIds: categoryIds ?? this.categoryIds,
      categoryFilterType: categoryFilterType ?? this.categoryFilterType,
      currencyCode: currencyCode ?? this.currencyCode,
      dateRange: dateRange ?? this.dateRange,
      type: type ?? this.type,
      noteSearch: noteSearch ?? this.noteSearch,
      amountRange: amountRange ?? this.amountRange,
      includeTransactionsWithoutCategories:
          includeTransactionsWithoutCategories ?? this.includeTransactionsWithoutCategories,
    );
  }

  /// Creates a copy without category filters
  FilterCriteria withoutCategoryFilter() {
    return copyWith(
      categoryIds: null,
      includeTransactionsWithoutCategories: false,
    );
  }

  /// Creates a copy without currency filter
  FilterCriteria withoutCurrencyFilter() {
    return copyWith(currencyCode: null);
  }

  /// Creates a copy without date filter
  FilterCriteria withoutDateFilter() {
    return copyWith(dateRange: null);
  }

  /// Creates a copy without type filter
  FilterCriteria withoutTypeFilter() {
    return copyWith(type: null);
  }

  /// Creates a copy without note filter
  FilterCriteria withoutNoteFilter() {
    return copyWith(noteSearch: null);
  }

  /// Creates a copy without amount filter
  FilterCriteria withoutAmountFilter() {
    return copyWith(amountRange: null);
  }

  @override
  List<Object?> get props => [
        categoryIds,
        categoryFilterType,
        currencyCode,
        dateRange,
        type,
        noteSearch,
        amountRange,
        includeTransactionsWithoutCategories,
      ];

  @override
  String toString() {
    final filters = <String>[];
    
    if (hasCategoryFilter) {
      final categoryStr = categoryFilterType.isAny ? 'ANY' : 'ALL';
      filters.add('categories: $categoryStr(${categoryIds!.join(', ')})');
    }
    
    if (hasCurrencyFilter) {
      filters.add('currency: $currencyCode');
    }
    
    if (hasDateFilter) {
      filters.add('date: $dateRange');
    }
    
    if (hasTypeFilter) {
      filters.add('type: $type');
    }
    
    if (hasNoteFilter) {
      filters.add('note: "$noteSearch"');
    }
    
    if (hasAmountFilter) {
      filters.add('amount: $amountRange');
    }
    
    if (includeTransactionsWithoutCategories) {
      filters.add('includeUncategorized: true');
    }
    
    return 'FilterCriteria(${filters.join(', ')})';
  }
}
