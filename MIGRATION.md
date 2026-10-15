# Migrating from Ponjika 1.1.0

2.0.0 is deliberately a major version: calendar correctness changes output.

## Existing facade

```dart
final label = Ponjika.format(
  date: DateTime(2025, 4, 17),
  format: 'DD MM, YY (WW) - SS',
);
// ৪ বৈশাখ, ১৪৩২ (বৃহস্পতিবার) - গ্রীষ্ম
```

`Ponjika.format` and `getSeasonEmoji` remain available. Legacy token spelling
is retained, including MM for a month **name** and YY for a full year.

Behavior changes:

- Revised Bangladesh month lengths replace the old implicit month table.
- Date inputs no longer subtract six hours. Midnight stays the requested day.
- `dayStartsAt` now defaults to `midnight`. An explicit `sunrise` (or another
  unsupported value) throws `UnsupportedError`; the old parameter was ignored.
- `displayLanguage` is honored: bangla/bn or english/en. Unknown values throw.
- WW and SS tokens work directly. `showWeekDays` and `showSeason` are accepted
  for source compatibility but no longer gate token expansion or append text.
- Historical dates use documented proleptic rules; see CALENDAR_RULES.md.
- The core no longer depends on Flutter. JSON annotations are the only runtime
  package dependency. Widgets now live in `ponjika_flutter`.

## Preferred typed API

```dart
final date = BanglaDate.fromGregorian(DateTime(2025, 4, 17));
final label = BanglaDateFormat('d MMMM, yyyy (EEEE) • SSSS').format(date);
final parsed = BanglaDateFormat.iso().parse('1432-01-04');
final gregorianCivilDate = parsed.toGregorian();
```

The new formatter is case-sensitive. MM means numeric month, MMMM month name,
yyyy full year, and yy two-digit display only. Wrap literals in square brackets.
Do not mechanically reuse legacy patterns with `BanglaDateFormat`.

No generated state-management code or state-management dependency is required.
