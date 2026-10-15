# Ponjika Flutter

Material 3 Bangla calendars with Gregorian secondary dates, single-date and
range dialogs, accessible labels, keyboard navigation and theme support.
The pure Dart calendar engine is re-exported for convenience.

## Install

```yaml
dependencies:
  ponjika_flutter: ^1.0.0
```

```dart
import 'package:ponjika_flutter/ponjika_flutter.dart';

PonjikaCalendar(
  value: selectedDate,
  onChanged: (date) => setState(() => selectedDate = date),
  language: PonjikaLanguage.bangla,
  numerals: PonjikaNumerals.bangla,
  today: const BanglaCalendar().today(utcOffset: const Duration(hours: 6)),
)
```

## Pickers

```dart
final date = await showPonjikaDatePicker(
  context: context,
  initialDate: BanglaDate(1432, 1, 4),
  firstDate: BanglaDate(1432, 1, 1),
  lastDate: BanglaDate(1433, 12, 30),
);
final range = await showPonjikaDateRangePicker(context: context);
```

Dialogs return null on cancel/back/dismissal. Date selection requires Confirm.
Range selection uses two taps, sorts reverse endpoints, and resets on the third
tap. An unavailable interior date prevents range confirmation.

## Integration options

- `value` and `onChanged`: controlled single-date selection.
- `selectedRange`: controlled inclusive range highlighting.
- `initialMonth`, `onMonthChanged`: initial view and navigation notifications.
- `firstDate`, `lastDate`, `selectableDayPredicate`: date restrictions.
- `firstWeekday`: Monday=1 through Sunday=7; defaults to Saturday.
- `showGregorian`: Gregorian day/month secondary labels (Latin digits).
- `dayBuilder`: custom day content for event indicators; interaction and
  accessibility semantics remain owned by the calendar.
- `today`: explicit clock/location interpretation. Rebuild when today changes;
  no background timer, networking or app lifecycle observer is installed.
- `onChanged: null`: read-only dates, with month browsing still available.

Initial picker selections must be valid and selectable. A picker with no
available dates keeps Confirm disabled and remains cancellable.

## Theme and accessibility

Colors and text styles come from `Theme.of(context)`. Customize layout using:

```dart
ThemeData(
  extensions: const [
    PonjikaCalendarTheme(cellHeight: 64, maximumWidth: 460),
  ],
)
```

Days have full date semantics, selected/disabled state and Today descriptions.
Tab moves between controls, arrows move between dates, and Enter/Space select.
Arrow-key searches skip unavailable dates within a bounded one-year window.
Picker content scrolls on smaller viewports while confirmation actions stay visible. Embed the inline calendar in a scrolling
parent when vertical space is constrained. Dense numeric labels scale down to fit their cell width; full dates remain available in semantics. Large-text layout is supported;
custom day builders must manage their own content scaling.

The package provides Bangla and English labels. For a localized application,
configure Flutter's localization delegates and supported locales in MaterialApp;
fonts and other application strings remain the application's responsibility.
No Riverpod/Popsicle/Bloc dependency is required; keep selection in your own store.

## Example playground

From the extracted two-package bundle run `dart tool/bootstrap.dart`, then:

```sh
cd packages/ponjika_flutter/example
flutter pub get
flutter run -d chrome
```

Includes language/numeral switches, theme toggle, dual dates, both dialogs,
format editor and copyable Dart snippets. Uses the Bangladesh revised civil
ruleset, proleptic before 2019. It does not implement astronomical panjika,
sunrise calculations, regional variants, or holiday datasets.

Apache-2.0. See LICENSE.
