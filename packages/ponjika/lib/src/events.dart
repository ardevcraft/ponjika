import 'date.dart';

/// Handling of dates such as Falgun 30 in a non-leap year.
enum MissingDatePolicy { skip, clamp, reject }

/// Annual recurrence in the Bangla calendar; no holiday or religious inference.
final class BanglaAnnualEvent {
  BanglaAnnualEvent({
    required this.id,
    required this.title,
    required this.month,
    required this.day,
    this.missingDatePolicy = MissingDatePolicy.skip,
  }) {
    if (id.trim().isEmpty || title.trim().isEmpty)
      throw ArgumentError('id and title must not be empty');
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    final max = month <= 6 ? 31 : 30;
    RangeError.checkValueInInterval(day, 1, max, 'day');
  }
  final String id;
  final String title;
  final int month;
  final int day;
  final MissingDatePolicy missingDatePolicy;

  BanglaDate? inYear(int year) {
    final max = BanglaDate.monthLength(year, month);
    if (day <= max) return BanglaDate(year, month, day);
    return switch (missingDatePolicy) {
      MissingDatePolicy.skip => null,
      MissingDatePolicy.clamp => BanglaDate(year, month, max),
      MissingDatePolicy.reject => throw StateError(
        '$title does not exist in year $year',
      ),
    };
  }

  BanglaDate? nextOccurrence(BanglaDate from, {bool inclusive = true}) {
    for (var year = from.year; year <= BanglaDate.maxYear; year++) {
      final date = inYear(year);
      if (date != null && (date.isAfter(from) || (inclusive && date == from)))
        return date;
    }
    return null;
  }

  Iterable<BanglaDate> occurrences(BanglaDateRange range) sync* {
    for (var year = range.start.year; year <= range.end.year; year++) {
      final date = inYear(year);
      if (date != null && range.contains(date)) yield date;
    }
  }
}
