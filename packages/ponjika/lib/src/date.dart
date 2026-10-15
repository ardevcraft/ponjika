/// Output language. English uses transliterated Bangla month names.
enum PonjikaLanguage { bangla, english }

/// Numerals are independent from the language used for names.
enum PonjikaNumerals { bangla, latin }

/// Policy when month/year arithmetic lands on a nonexistent date.
enum DateOverflow { clamp, reject }

/// Bangla civil months, in calendar order.
enum BanglaMonth {
  boishakh,
  joishtho,
  ashar,
  srabon,
  bhadro,
  ashwin,
  kartik,
  ogrohayon,
  poush,
  magh,
  falgun,
  choitro;

  int get number => index + 1;
  String nameIn(PonjikaLanguage language) =>
      language == PonjikaLanguage.bangla ? _bnMonths[index] : _enMonths[index];
  BanglaSeason get season => BanglaSeason.values[index ~/ 2];
}

/// Calendar seasons; these labels do not describe actual local weather.
enum BanglaSeason {
  summer,
  monsoon,
  autumn,
  lateAutumn,
  winter,
  spring;

  String nameIn(PonjikaLanguage language) => language == PonjikaLanguage.bangla
      ? _bnSeasons[index]
      : _enSeasons[index];
  String get emoji => const ['☀️', '🌧️', '🍃', '🍂', '❄️', '🌸'][index];
}

const _bnMonths = [
  'বৈশাখ',
  'জ্যৈষ্ঠ',
  'আষাঢ়',
  'শ্রাবণ',
  'ভাদ্র',
  'আশ্বিন',
  'কার্তিক',
  'অগ্রহায়ণ',
  'পৌষ',
  'মাঘ',
  'ফাল্গুন',
  'চৈত্র',
];
const _enMonths = [
  'Boishakh',
  'Joishtho',
  'Ashar',
  'Srabon',
  'Bhadro',
  'Ashwin',
  'Kartik',
  'Ogrohayon',
  'Poush',
  'Magh',
  'Falgun',
  'Choitro',
];
const _bnSeasons = ['গ্রীষ্ম', 'বর্ষা', 'শরৎ', 'হেমন্ত', 'শীত', 'বসন্ত'];
const _enSeasons = [
  'Summer',
  'Monsoon',
  'Autumn',
  'Late autumn',
  'Winter',
  'Spring',
];
const _bnWeekdays = [
  'সোমবার',
  'মঙ্গলবার',
  'বুধবার',
  'বৃহস্পতিবার',
  'শুক্রবার',
  'শনিবার',
  'রবিবার',
];
const _enWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Weekday number follows DateTime: Monday=1 through Sunday=7.
String ponjikaWeekdayName(int weekday, PonjikaLanguage language) {
  RangeError.checkValueInInterval(weekday, 1, 7, 'weekday');
  return (language == PonjikaLanguage.bangla
      ? _bnWeekdays
      : _enWeekdays)[weekday - 1];
}

/// Immutable civil date under the `bd-revised-2019-v1` ruleset.
///
/// Years before 1426 use the same rules proleptically: they are NOT historical
/// Bangladesh or traditional astronomical calendar reconstructions.
final class BanglaDate implements Comparable<BanglaDate> {
  factory BanglaDate(int year, int month, int day) {
    RangeError.checkValueInInterval(year, minYear, maxYear, 'year');
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    RangeError.checkValueInInterval(day, 1, monthLength(year, month), 'day');
    return BanglaDate._(year, month, day);
  }
  const BanglaDate._(this.year, this.month, this.day);

  static const minYear = 1;
  static const maxYear = 9405;
  final int year;
  final int month;
  final int day;

  BanglaMonth get monthValue => BanglaMonth.values[month - 1];
  BanglaSeason get season => monthValue.season;
  int get daysInMonth => monthLength(year, month);
  int get daysInYear => isLeapYear ? 366 : 365;
  bool get isLeapYear => gregorianLeapYear(year + 594);
  int get weekday => toGregorian().weekday;
  int get dayOfYear =>
      day +
      [
        for (var m = 1; m < month; m++) monthLength(year, m),
      ].fold(0, (int a, int b) => a + b);
  BanglaDate get startOfMonth => BanglaDate(year, month, 1);
  BanglaDate get endOfMonth => BanglaDate(year, month, daysInMonth);

  /// The Gregorian civil date encoded as UTC midnight, not a local instant.
  DateTime toGregorian() =>
      DateTime.utc(year + 593, 4, 14).add(Duration(days: dayOfYear - 1));

  /// Uses only year/month/day. Time, offset, and UTC/local marker are ignored.
  factory BanglaDate.fromGregorian(DateTime date) {
    final civil = DateTime.utc(date.year, date.month, date.day);
    final startYear = date.month < 4 || (date.month == 4 && date.day < 14)
        ? date.year - 1
        : date.year;
    final year = startYear - 593;
    RangeError.checkValueInInterval(year, minYear, maxYear, 'Bangla year');
    var remaining = civil.difference(DateTime.utc(startYear, 4, 14)).inDays;
    var month = 1;
    while (remaining >= monthLength(year, month)) {
      remaining -= monthLength(year, month++);
    }
    return BanglaDate(year, month, remaining + 1);
  }

  static bool gregorianLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  static int monthLength(int year, int month) {
    RangeError.checkValueInInterval(year, minYear, maxYear, 'year');
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    if (month <= 6) return 31;
    if (month == 11) return gregorianLeapYear(year + 594) ? 30 : 29;
    return 30;
  }

  BanglaDate copyWith({int? year, int? month, int? day}) =>
      BanglaDate(year ?? this.year, month ?? this.month, day ?? this.day);
  BanglaDate addDays(int days) =>
      BanglaDate.fromGregorian(toGregorian().add(Duration(days: days)));
  BanglaDate addMonths(
    int months, {
    DateOverflow overflow = DateOverflow.clamp,
  }) {
    final total = (year - 1) * 12 + month - 1 + months;
    if (total < 0 || total >= maxYear * 12)
      throw RangeError('Result outside supported years');
    final y = total ~/ 12 + 1;
    final m = total % 12 + 1;
    final max = monthLength(y, m);
    return BanglaDate(
      y,
      m,
      overflow == DateOverflow.clamp && day > max ? max : day,
    );
  }

  BanglaDate addYears(
    int years, {
    DateOverflow overflow = DateOverflow.clamp,
  }) => addMonths(years * 12, overflow: overflow);
  int differenceInDays(BanglaDate other) =>
      toGregorian().difference(other.toGregorian()).inDays;
  bool isBefore(BanglaDate other) => compareTo(other) < 0;
  bool isAfter(BanglaDate other) => compareTo(other) > 0;
  @override
  int compareTo(BanglaDate other) {
    final yearCompare = year.compareTo(other.year);
    if (yearCompare != 0) return yearCompare;
    final monthCompare = month.compareTo(other.month);
    return monthCompare != 0 ? monthCompare : day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is BanglaDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;
  @override
  int get hashCode => Object.hash(year, month, day);

  /// Stable numeric representation, independent of UI locale.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

/// Inclusive range with validated chronological order.
final class BanglaDateRange {
  BanglaDateRange({required this.start, required this.end}) {
    if (end.isBefore(start)) throw ArgumentError('end must not precede start');
  }
  final BanglaDate start;
  final BanglaDate end;
  int get lengthInDays => end.differenceInDays(start) + 1;
  bool contains(BanglaDate date) => !date.isBefore(start) && !date.isAfter(end);
  Iterable<BanglaDate> get dates sync* {
    var current = start;
    while (true) {
      yield current;
      if (current == end) break;
      current = current.addDays(1);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is BanglaDateRange && start == other.start && end == other.end;
  @override
  int get hashCode => Object.hash(start, end);
}
