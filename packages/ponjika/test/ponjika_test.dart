import 'dart:convert';
import 'package:ponjika/ponjika.dart';
import 'package:test/test.dart';

void main() {
  const calendar = BanglaCalendar();
  group('reference dates under revised Bangladesh rules', () {
    final fixtures = <(DateTime, BanglaDate)>[
      (DateTime.utc(2025, 4, 14), BanglaDate(1432, 1, 1)),
      (DateTime.utc(2025, 4, 17), BanglaDate(1432, 1, 4)),
      (DateTime.utc(2025, 4, 13), BanglaDate(1431, 12, 30)),
      (DateTime.utc(2024, 2, 19), BanglaDate(1430, 11, 6)),
      (DateTime.utc(2024, 2, 21), BanglaDate(1430, 11, 8)),
      (DateTime.utc(2024, 3, 14), BanglaDate(1430, 11, 30)),
      (DateTime.utc(2025, 3, 14), BanglaDate(1431, 11, 29)),
      (DateTime.utc(2024, 3, 15), BanglaDate(1430, 12, 1)),
      (DateTime.utc(2025, 12, 16), BanglaDate(1432, 9, 1)),
    ];
    for (final (gregorian, bangla) in fixtures) {
      test('$gregorian ↔ $bangla', () {
        expect(calendar.fromGregorian(gregorian), bangla);
        expect(bangla.toGregorian(), gregorian);
      });
    }
  });
  test('exhaustive day round trips for Gregorian 1900–2100', () {
    for (
      var date = DateTime.utc(1900);
      date.isBefore(DateTime.utc(2101));
      date = date.add(const Duration(days: 1))
    ) {
      final result = calendar.fromGregorian(date);
      expect(result.toGregorian(), date, reason: '$date → $result');
      expect(result.day, inInclusiveRange(1, result.daysInMonth));
    }
  });
  test('every month boundary and leap century rule', () {
    for (final year in [1, 1306, 1406, 1426, 1430, 1431, 1432, 1506, 9405]) {
      var total = 0;
      for (var month = 1; month <= 12; month++) {
        final first = BanglaDate(year, month, 1);
        total += first.daysInMonth;
        expect(calendar.fromGregorian(first.toGregorian()), first);
        expect(
          calendar.fromGregorian(first.endOfMonth.toGregorian()),
          first.endOfMonth,
        );
        if (month < 12)
          expect(first.endOfMonth.addDays(1), BanglaDate(year, month + 1, 1));
      }
      expect(total, BanglaDate(year, 1, 1).daysInYear);
    }
    expect(BanglaDate(1306, 11, 1).daysInMonth, 29); // Gregorian 1900
    expect(BanglaDate(1406, 11, 1).daysInMonth, 30); // Gregorian 2000
    expect(BanglaDate(1506, 11, 1).daysInMonth, 29); // Gregorian 2100
  });
  test('civil conversion ignores time and UTC marker', () {
    expect(
      calendar.fromGregorian(DateTime(2025, 4, 14)),
      BanglaDate(1432, 1, 1),
    );
    expect(
      calendar.fromGregorian(DateTime.utc(2025, 4, 14, 23, 59)),
      BanglaDate(1432, 1, 1),
    );
    expect(BanglaDate(1432, 1, 1).weekday, DateTime.monday);
  });
  test('instant conversion explicitly crosses midnight', () {
    final instant = DateTime.utc(2025, 4, 13, 18);
    expect(
      calendar.fromInstant(instant, utcOffset: const Duration(hours: 6)),
      BanglaDate(1432, 1, 1),
    );
    expect(
      calendar.fromInstant(
        instant.subtract(const Duration(microseconds: 1)),
        utcOffset: const Duration(hours: 6),
      ),
      BanglaDate(1431, 12, 30),
    );
    expect(
      () => calendar.fromInstant(instant, utcOffset: const Duration(hours: 15)),
      throwsArgumentError,
    );
    expect(
      calendar.today(clock: () => instant, utcOffset: const Duration(hours: 6)),
      BanglaDate(1432, 1, 1),
    );
    expect(calendar.explain(instant).rulesetId, BanglaCalendar.rulesetId);
  });
  test('invalid dates and supported range boundaries', () {
    for (final parts in [
      (0, 1, 1),
      (9406, 1, 1),
      (1432, 0, 1),
      (1432, 13, 1),
      (1432, 1, 0),
      (1432, 7, 31),
      (1431, 11, 30),
    ]) {
      expect(() => BanglaDate(parts.$1, parts.$2, parts.$3), throwsRangeError);
    }
    expect(() => BanglaDate(1, 1, 1).addDays(-1), throwsRangeError);
    expect(() => BanglaDate(9405, 12, 30).addDays(1), throwsRangeError);
  });
  test('arithmetic, equality and inclusive ranges', () {
    final date = BanglaDate(1432, 6, 31);
    expect(date.addMonths(1), BanglaDate(1432, 7, 30));
    expect(
      () => date.addMonths(1, overflow: DateOverflow.reject),
      throwsRangeError,
    );
    expect(BanglaDate(1430, 11, 30).addYears(1), BanglaDate(1431, 11, 29));
    expect(BanglaDate(1432, 1, 1).addMonths(-1), BanglaDate(1431, 12, 1));
    expect({date, date.copyWith()}.length, 1);
    final range = BanglaDateRange(start: date, end: date.addDays(2));
    expect(range.lengthInDays, 3);
    expect(range.dates.length, 3);
    expect(range.contains(date), isTrue);
    expect(range.contains(date.addDays(-1)), isFalse);
    expect(
      () => BanglaDateRange(start: date, end: date.addDays(-1)),
      throwsArgumentError,
    );
    expect(
      BanglaDateRange(
        start: BanglaDate(9405, 12, 30),
        end: BanglaDate(9405, 12, 30),
      ).dates.length,
      1,
    );
  });
  test('month grid supports every week start and extreme years', () {
    for (var weekday = 1; weekday <= 7; weekday++) {
      final grid = calendar.monthGrid(1432, 1, firstWeekday: weekday);
      expect(grid.length, 42);
      expect(grid.first.date!.weekday, weekday);
      expect(grid.where((c) => c.isCurrentMonth).length, 31);
    }
    expect(calendar.monthGrid(1, 1).where((c) => c.date == null), isNotEmpty);
    expect(
      calendar.monthGrid(9405, 12).where((c) => c.date == null),
      isNotEmpty,
    );
  });
  group('formatting and strict parsing', () {
    final date = BanglaDate(1432, 1, 4);
    test('exact Bangla output', () {
      final format = BanglaDateFormat('d MMMM, yyyy (EEEE) • SSSS');
      expect(format.format(date), '৪ বৈশাখ, ১৪৩২ (বৃহস্পতিবার) • গ্রীষ্ম');
      expect(format.parse(format.format(date)), date);
    });
    test('independent name and numeral settings', () {
      expect(
        BanglaDateFormat.long(numerals: PonjikaNumerals.latin).format(date),
        '4 বৈশাখ, 1432',
      );
      expect(
        BanglaDateFormat.long(language: PonjikaLanguage.english).format(date),
        '৪ Boishakh, ১৪৩২',
      );
      final f = BanglaDateFormat(
        'yyyy-MM-dd [Bangla]',
        numerals: PonjikaNumerals.latin,
      );
      expect(f.format(date), '1432-01-04 Bangla');
      expect(f.parse(f.format(date)), date);
      expect(BanglaDateFormat.iso().parse('১৪৩২-০১-০৪'), date);
    });
    test(
      'reject malformed, ambiguous, incomplete and contradictory inputs',
      () {
        final iso = BanglaDateFormat.iso();
        for (final text in [
          '1432-01-00',
          '1431-11-30',
          '1432-1-04',
          '1432-01-04x',
          'garbage',
        ]) {
          expect(iso.tryParse(text), isNull);
        }
        expect(
          () => BanglaDateFormat('yyyy-MM-dd [oops'),
          throwsFormatException,
        );
        expect(() => BanglaDateFormat('yyyy-MM-dd bad'), throwsFormatException);
        expect(BanglaDateFormat('yy-MM-dd').tryParse('32-01-04'), isNull);
        expect(BanglaDateFormat('yyyy-MM').tryParse('1432-01'), isNull);
        expect(
          BanglaDateFormat('yyyy-MM-dd EEEE').tryParse('1432-01-04 সোমবার'),
          isNull,
        );
        expect(
          BanglaDateFormat('yyyy-MM-dd SSSS').tryParse('1432-01-04 শীত'),
          isNull,
        );
      },
    );
    test('all months and seasons round trip in both languages', () {
      for (final language in PonjikaLanguage.values) {
        final f = BanglaDateFormat(
          'dd MMMM yyyy EEEE SSSS',
          language: language,
        );
        for (var month = 1; month <= 12; month++) {
          final d = BanglaDate(1432, month, 1);
          expect(f.parse(f.format(d)), d);
          expect(d.season.emoji, isNotEmpty);
        }
      }
      expect('Price 123.45'.toBanglaDigits().toLatinDigits(), 'Price 123.45');
    });
  });
  test('recurrences handle missing dates explicitly', () {
    final event = BanglaAnnualEvent(
      id: 'birthday',
      title: 'Birthday',
      month: 11,
      day: 30,
    );
    expect(event.inYear(1431), isNull);
    expect(event.inYear(1430), BanglaDate(1430, 11, 30));
    expect(
      event.nextOccurrence(BanglaDate(1431, 1, 1)),
      BanglaDate(1434, 11, 30),
    );
    final clamp = BanglaAnnualEvent(
      id: 'a',
      title: 'A',
      month: 11,
      day: 30,
      missingDatePolicy: MissingDatePolicy.clamp,
    );
    expect(clamp.inYear(1431), BanglaDate(1431, 11, 29));
    final reject = BanglaAnnualEvent(
      id: 'a',
      title: 'A',
      month: 11,
      day: 30,
      missingDatePolicy: MissingDatePolicy.reject,
    );
    expect(() => reject.inYear(1431), throwsStateError);
    final newYear = BanglaAnnualEvent(
      id: 'new-year',
      title: 'New year',
      month: 1,
      day: 1,
    );
    final start = BanglaDate(1432, 1, 1);
    expect(newYear.nextOccurrence(start), start);
    expect(
      newYear.nextOccurrence(start, inclusive: false),
      BanglaDate(1433, 1, 1),
    );
    expect(
      newYear
          .occurrences(BanglaDateRange(start: start, end: start.addYears(2)))
          .length,
      3,
    );
    expect(newYear.nextOccurrence(BanglaDate(9405, 12, 30)), isNull);
  });
  test('JSON DTO generated serialization preserves ruleset', () {
    final date = BanglaDate(1432, 1, 1);
    final dto = BanglaDateDto.fromDomain(date);
    final json = jsonDecode(jsonEncode(dto.toJson())) as Map<String, Object?>;
    expect(BanglaDateDto.fromJson(json).toDomain(), date);
    expect(dto.copyWith(day: 2).toDomain(), date.addDays(1));
    expect(
      () => BanglaDateDto.fromJson({'year': 1432.5, 'month': 1, 'day': 1}),
      throwsA(isA<Exception>()),
    );
    expect(
      () => dto.copyWith(ruleset: 'unknown').toDomain(),
      throwsFormatException,
    );
    expect(
      () => BanglaDateDto.fromJson({'year': '1432'}),
      throwsA(isA<Exception>()),
    );
  });
  test('legacy facade retains tokens with documented behavior corrections', () {
    expect(
      Ponjika.format(
        date: DateTime(2025, 4, 17),
        format: 'DD MM, YY (WW) - SS',
      ),
      '৪ বৈশাখ, ১৪৩২ (বৃহস্পতিবার) - গ্রীষ্ম',
    );
    expect(
      Ponjika.format(date: DateTime(2025, 4, 17), displayLanguage: 'en'),
      '4 Boishakh, 1432',
    );
    expect(
      () => Ponjika.format(dayStartsAt: 'sunrise'),
      throwsUnsupportedError,
    );
    expect(Ponjika.getSeasonEmoji(DateTime(2025, 4, 17)), '☀️');
  });
}
