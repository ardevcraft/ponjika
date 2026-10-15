# Ponjika playground

From the extracted bundle root run `dart tool/bootstrap.dart`, then:

```sh
cd packages/ponjika_flutter/example
flutter pub get
flutter run -d chrome
```

A web runner is included. Generate additional native runners with
`flutter create --platforms=android,ios --project-name=ponjika_flutter_example .`
using your installed Flutter SDK.

Try language and numeral switches, theme switching, both pickers, and the
format editor. Dates use the Bangladesh revised civil ruleset.
