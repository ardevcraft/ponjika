# Release validation

Executed with Flutter 3.47.7 stable and Dart 3.13.5 on Linux.

| Check | Result |
| --- | --- |
| JSON DTO code generation | Passed; generated source included |
| Dart formatting | Passed |
| Core static analysis | No issues |
| Flutter package static analysis | No issues |
| Example app static analysis | No issues |
| Core tests | 23 passed |
| Flutter widget tests | 7 passed |
| Example app smoke test | 1 passed |
| Gregorian round trips, 1900–2100 inclusive | All 73,414 civil days passed |
| Core `dart pub publish --dry-run` | 0 warnings |
| Flutter `flutter pub publish --dry-run` | 0 warnings; 1 local-dependency hint |
| Example release web build | Passed; Wasm compatibility dry run also passed |

The widget tests exercise date selection, month navigation, disabled dates,
keyboard selection, dark theme at 320px with 2x text scaling, date confirmation
and cancellation, reversed range endpoints, and unavailable interior range dates.
The example test opens the playground, switches language, and switches theme.

The publication dry-runs do not publish or reserve a package name. Flutter's
local-dependency hint comes from its development-only pubspec_overrides.yaml.
Those override files are excluded from this ZIP and from pub publication. The
published manifest contains `ponjika: ^2.0.0`. Publish the core first, remove
local overrides with `dart tool/bootstrap.dart --clean`, resolve the hosted
core release, and rerun the Flutter dry-run before upload.

The declared minimum SDK pair (Dart 3.9 / Flutter 3.35) was not separately tested.
Android/iOS/macOS/Linux/Windows native runners and real-device assistive
technology were not exercised. No native platform code or platform plugin is
required by the library. Calendar assumptions and historical limits are
explicitly documented in CALENDAR_RULES.md.

Use `bash tool/check.sh` to reproduce the source checks and tests from the
extracted bundle root, and `flutter build web` in the example for its web build.
