import 'package:equatable/equatable.dart';

/// Value object representing a date range for filtering transactions
class DateRange extends Equatable {
  /// Start date of the range
  final DateTime startDate;
  
  /// End date of the range
  final DateTime endDate;
  
  /// Whether to include transactions on the start date
  final bool includeStartDate;
  
  /// Whether to include transactions on the end date
  final bool includeEndDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
    this.includeStartDate = true,
    this.includeEndDate = true,
  });

  /// Creates a date range for a single day
  DateRange.singleDay(DateTime date)
      : startDate = DateTime(date.year, date.month, date.day),
        endDate = DateTime(date.year, date.month, date.day, 23, 59, 59, 999),
        includeStartDate = true,
        includeEndDate = true;

  /// Creates a date range for the current week
  factory DateRange.currentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return DateRange(
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59, 999),
    );
  }

  /// Creates a date range for the current month
  factory DateRange.currentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    
    return DateRange(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Creates a date range for the current year
  factory DateRange.currentYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59, 999);
    
    return DateRange(
      startDate: startOfYear,
      endDate: endOfYear,
    );
  }

  /// Creates a date range for the last N days
  factory DateRange.lastDays(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    
    return DateRange(
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
  }

  /// Returns true if the range is valid (start <= end)
  bool get isValid => startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
  
  /// Returns the duration of this date range
  Duration get duration => endDate.difference(startDate);
  
  /// Returns the number of days in this range (inclusive)
  int get dayCount => duration.inDays + 1;

  /// Checks if the given date falls within this range
  bool contains(DateTime date) {
    if (!isValid) return false;
    
    // Check start date constraint
    if (includeStartDate) {
      if (date.isBefore(startDate)) return false;
    } else {
      if (date.isBefore(startDate) || date.isAtSameMomentAs(startDate)) return false;
    }
    
    // Check end date constraint
    if (includeEndDate) {
      if (date.isAfter(endDate)) return false;
    } else {
      if (date.isAfter(endDate) || date.isAtSameMomentAs(endDate)) return false;
    }
    
    return true;
  }

  /// Creates a copy of this range with updated values
  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? includeStartDate,
    bool? includeEndDate,
  }) {
    return DateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeStartDate: includeStartDate ?? this.includeStartDate,
      includeEndDate: includeEndDate ?? this.includeEndDate,
    );
  }

  @override
  List<Object?> get props => [startDate, endDate, includeStartDate, includeEndDate];

  @override
  String toString() {
    final startStr = includeStartDate ? '[' : '(';
    final endStr = includeEndDate ? ']' : ')';
    return 'DateRange$startStr${startDate.toIso8601String()}, ${endDate.toIso8601String()}$endStr';
  }
}
