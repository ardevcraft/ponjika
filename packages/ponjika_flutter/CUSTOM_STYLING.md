# Ponjika Calendar styling

`PonjikaCalendarTheme` can be installed globally through `ThemeData.extensions` or passed to a single calendar/picker through `theme:`.

## Global theme

```dart
final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA242C2)),
  extensions: const [
    PonjikaCalendarTheme(
      contentPadding: 16,
      cellHeight: 58,
      cellSpacing: 3,
      cornerRadius: 24,
      dayCornerRadius: 14,
      elevation: 1,
      borderWidth: 1,
      headerPadding: EdgeInsets.only(bottom: 10),
      weekdayPadding: EdgeInsets.symmetric(vertical: 10),
      todayBorderWidth: 1.5,
    ),
  ],
);
```

Null color/text-style properties intentionally inherit from the active Material `ThemeData`, so the component remains light/dark-mode aware.

## Local premium styling

```dart
PonjikaCalendar(
  value: selectedDate,
  onChanged: (date) => setState(() => selectedDate = date),
  theme: PonjikaCalendarTheme(
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
    borderColor: Theme.of(context).colorScheme.outlineVariant,
    borderWidth: 1,
    cornerRadius: 24,
    dayCornerRadius: 14,
    cellSpacing: 3,
    selectedDayBackgroundColor: Theme.of(context).colorScheme.primary,
    selectedDayForegroundColor: Theme.of(context).colorScheme.onPrimary,
    rangeDayBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    todayBorderColor: Theme.of(context).colorScheme.primary,
    todayBorderWidth: 1.5,
    headerTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    ),
    weekdayTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

## Picker styling

Both picker helpers accept the same `theme:` override:

```dart
final date = await showPonjikaDatePicker(
  context: context,
  theme: const PonjikaCalendarTheme(
    cornerRadius: 24,
    dayCornerRadius: 14,
    cellSpacing: 3,
  ),
);
```

For completely custom cell content, `dayBuilder` remains available. The calendar still owns interaction, focus, keyboard navigation, selection and accessibility semantics.
