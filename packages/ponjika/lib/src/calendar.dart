import 'date.dart';

/// Injectable clock for deterministic today helpers.
typedef PonjikaClock = DateTime Function();

/// Conversion service for the Bangladesh revised civil calendar.
final class BanglaCalendar {
  const BanglaCalendar();
  static const rulesetId = 'bd-revised-2019-v1';
  static const rulesDescription =
      'April 14 starts the year; months 1–6 have 31 days; '
      'months 7–10 and 12 have 30; Falgun has 29 or 30 according to the Gregorian '
      'leap year containing that Falgun. Midnight civil boundary. Proleptic before 2019.';

  BanglaDate fromGregorian(DateTime date) => BanglaDate.fromGregorian(date);

  /// Convert an instant to civil fields at an explicit fixed UTC offset.
  /// For IANA/DST zones resolve the offset externally for this instant.
  BanglaDate fromInstant(DateTime instant, {required Duration utcOffset}) {
    if (utcOffset.inMicroseconds.abs() >
        const Duration(hours: 14).inMicroseconds) {
      throw ArgumentError.value(
        utcOffset,
        'utcOffset',
        'Must be within ±14 hours',
      );
    }
    return fromGregorian(instant.toUtc().add(utcOffset));
  }

  BanglaDate today({PonjikaClock? clock, Duration? utcOffset}) {
    final now = (clock ?? DateTime.now)();
    return utcOffset == null
        ? fromGregorian(now)
        : fromInstant(now, utcOffset: utcOffset);
  }

  CalendarConversion explain(DateTime date) => CalendarConversion(
    gregorian: DateTime.utc(date.year, date.month, date.day),
    bangla: fromGregorian(date),
  );

  /// Always 42 cells, including adjacent months. At supported range boundaries
  /// an unrepresentable adjacent date is null. Monday=1 ... Sunday=7.
  List<BanglaCalendarCell> monthGrid(
    int year,
    int month, {
    int firstWeekday = DateTime.saturday,
  }) {
    RangeError.checkValueInInterval(firstWeekday, 1, 7, 'firstWeekday');
    final first = BanglaDate(year, month, 1);
    final leading = (first.weekday - firstWeekday + 7) % 7;
    return List.unmodifiable(
      List.generate(42, (index) {
        BanglaDate? date;
        try {
          date = first.addDays(index - leading);
        } on RangeError {
          date = null;
        }
        return BanglaCalendarCell(
          date: date,
          isCurrentMonth: date?.year == year && date?.month == month,
        );
      }),
    );
  }
}

final class CalendarConversion {
  const CalendarConversion({required this.gregorian, required this.bangla});
  final DateTime gregorian;
  final BanglaDate bangla;
  String get rulesetId => BanglaCalendar.rulesetId;
  String get explanation => BanglaCalendar.rulesDescription;
}

final class BanglaCalendarCell {
  const BanglaCalendarCell({required this.date, required this.isCurrentMonth});
  final BanglaDate? date;
  final bool isCurrentMonth;
}

extension PonjikaDateTime on DateTime {
  BanglaDate toBanglaDate() => BanglaDate.fromGregorian(this);
}
