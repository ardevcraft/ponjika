# Ponjika packages

Two independently publishable packages, upgraded from the supplied Ponjika 1.1.0 source.

| Package | Release | Purpose |
| --- | --- | --- |
| `packages/ponjika` | 2.0.0 | Pure Dart civil calendar engine |
| `packages/ponjika_flutter` | 1.0.0 | Material calendar and single/range pickers |

Start with [PUBLISHING.md](PUBLISHING.md), [MIGRATION.md](MIGRATION.md), and
[CALENDAR_RULES.md](CALENDAR_RULES.md). Validation results are in [VALIDATION.md](VALIDATION.md).

## Local development

Requires Dart >=3.9 and Flutter >=3.35. Use a current stable Flutter installation.
From this extracted directory:

```sh
dart tool/bootstrap.dart
bash tool/check.sh
cd packages/ponjika_flutter/example
flutter pub get
flutter run -d chrome
```

The example includes a web runner. To generate mobile runners with your
installed Flutter SDK, run `flutter create --platforms=android,ios --project-name=ponjika_flutter_example .` inside the example directory.

The bootstrap script creates ignored `pubspec_overrides.yaml` files for local
cross-package resolution. The publishable manifests contain a hosted
`ponjika: ^2.0.0` dependency; no workspace or path dependency leaks into that
manifest. Root scripts are development tooling and are not separate packages.

## Included

- Revised Bangladesh civil calendar with documented proleptic behavior.
- Validated immutable dates, enums, reverse conversion and date arithmetic.
- Strict parsing, escaped literals, independent language and numeral options.
- Generated JSON DTO serialization with a stable ruleset identifier.
- Deterministic clocks, explicit instant conversion and conversion explanations.
- Inclusive ranges, 42-cell month data and recurring Bangla events.
- Theme-aware dual calendars, keyboard navigation, localized labels and semantics.
- Date/range dialogs with bounds, disabled dates, confirmation and cancellation.
- Interactive example with formatting playground, snippet copying and themes.
- Unit/widget tests and a GitHub Actions validation workflow.

Only the revised Bangladesh civil ruleset is implemented. Astronomical panjika,
sunrise calculations, West Bengal conventions, holiday datasets, IANA timezone
data and OS notifications are outside this release. Recurrences compute dates;
applications own scheduling. No state-management framework is imposed on consumers.

Apache-2.0 license preserved from the supplied package. See package LICENSE files.
