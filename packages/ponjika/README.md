# Ponjika

A pure Dart toolkit for the **Bangladesh revised civil Bangla calendar**.
Typed dates, reverse conversion, strict parsing, formatting, arithmetic,
recurrences and JSON DTOs. Flutter widgets are in `ponjika_flutter`.

## Install

```yaml
dependencies:
  ponjika: ^2.0.0
```

```dart
import 'package:ponjika/ponjika.dart';

final date = BanglaDate.fromGregorian(DateTime(2025, 4, 17));
final text = BanglaDateFormat('d MMMM, yyyy (EEEE) • SSSS').format(date);
// ৪ বৈশাখ, ১৪৩২ (বৃহস্পতিবার) • গ্রীষ্ম
final gregorian = date.toGregorian(); // UTC-encoded Gregorian civil date
final parsed = BanglaDateFormat.iso().parse('1432-01-04');
```

## Calendar contract

Ruleset `bd-revised-2019-v1`: April 14 starts Boishakh; first six months have
31 days; Kartik–Magh and Choitro have 30; Falgun has 29, or 30 when its
containing Gregorian year is leap (Bangla year +594).

Years 1–9405 are supported. Rules are **proleptic before 2019** and are not
historical or astronomical calendar reconstruction. Sunrise, West Bengal
calendar variants, tithi and official holiday datasets are not implemented.
Calendar seasons are month-pair labels rather than weather predictions.

## Civil date or instant?

```dart
const calendar = BanglaCalendar();
// Reads date components exactly; does not shift for a timezone.
final civil = calendar.fromGregorian(DateTime(2025, 4, 14));
// Converts an instant to Bangladesh civil time explicitly.
final bangladesh = calendar.fromInstant(
  DateTime.utc(2025, 4, 13, 18),
  utcOffset: const Duration(hours: 6),
);
final today = calendar.today(utcOffset: const Duration(hours: 6));
final deterministic = calendar.today(clock: () => DateTime(2025, 4, 14));
final explanation = calendar.explain(DateTime(2025, 4, 14));
```

`toGregorian()` returns date components represented as UTC midnight, not a
local-midnight instant. Resolve IANA/DST offsets externally for `fromInstant`.

## Formatting and parsing

| Token | Meaning |
| --- | --- |
| `yyyy` | Four-digit year |
| `yy` | Two-digit year, formatting only |
| `MMMM` | Full Bangla month name or English transliteration |
| `MM`, `M` | Padded/unpadded numeric month |
| `dd`, `d` | Padded/unpadded day |
| `EEEE` | Full weekday |
| `SSSS` | Full season |
| `[text]` | Literal text |

```dart
final format = BanglaDateFormat(
  'dd MMMM yyyy',
  language: PonjikaLanguage.bangla,
  numerals: PonjikaNumerals.latin,
);
final label = format.format(BanglaDate(1432, 1, 4)); // 04 বৈশাখ 1432
final date = format.tryParse('০৪ বৈশাখ ১৪৩২');
final amount = '123.45'.toBanglaDigits();
```

Parsing accepts either digit script, is strict about pattern and date validity,
checks weekday/season when supplied, and requires a full year, month and day.
`parse` throws `FormatException`; `tryParse` returns null.

## Arithmetic and grids

```dart
final next = BanglaDate(1432, 6, 31).addMonths(1); // 1432-07-30
final strict = BanglaDate(1432, 1, 1).addYears(1, overflow: DateOverflow.reject);
final range = BanglaDateRange(start: next, end: next.addDays(6));
final days = range.dates; // inclusive, lazy
final cells = const BanglaCalendar().monthGrid(1432, 1, firstWeekday: DateTime.saturday);
```

Month/year arithmetic clamps by default. Reject mode throws if the destination
date is invalid. Grids always contain 42 cells; adjacent dates outside supported
years are null. All date construction and arithmetic validate supported bounds.
Dates support equality, hashCode, comparison, copyWith and `differenceInDays`.

## Recurring events

```dart
final birthday = BanglaAnnualEvent(
  id: 'birthday', title: 'Birthday', month: 11, day: 30,
  missingDatePolicy: MissingDatePolicy.skip,
);
final next = birthday.nextOccurrence(BanglaDate(1431, 1, 1));
```

Missing dates can skip, clamp, or reject. A recurrence only computes dates;
it does not create OS notifications or imply a government holiday.

## JSON boundary

```dart
final dto = BanglaDateDto.fromDomain(BanglaDate(1432, 1, 4));
final json = dto.toJson();
final restored = BanglaDateDto.fromJson(json).toDomain();
```

Generated `json_serializable` code is included. The DTO carries year, month,
day and ruleset. Domain conversion validates dates and rejects unknown rulesets.
No state-management dependency is required.

## Compatibility

`Ponjika.format` and `getSeasonEmoji` remain available with legacy DD/MM/YY/WW/SS
tokens. In 2.0, MM still means month name in that facade only. Midnight is now
the default; explicit sunrise throws. WW/SS no longer require flags. Conversion
results change because timezone shifting, boundaries and month rules are corrected.

Apache-2.0. See LICENSE.
