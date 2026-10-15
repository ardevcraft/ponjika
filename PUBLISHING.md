# Publish the two packages

Package source is prepared for publication. This ZIP does not publish anything
or authenticate your pub.dev account. Verify name availability, account ownership,
and version availability before upload; these cannot be reserved by an archive.
If 2.0.0 already exists, choose the next available core version and update the
Flutter package's hosted dependency constraint and release notes accordingly.

## 1. Validate locally

```sh
dart tool/bootstrap.dart
bash tool/check.sh
```

The script resolves local dependencies, formats/checks source, analyzes both
packages and the example, and runs core and Flutter tests. Generated JSON code
is included, so build_runner is required only when DTOs change:

```sh
cd packages/ponjika
dart run build_runner build --delete-conflicting-outputs
```

## 2. Publish core first

Remove local overrides before release validation:

```sh
# Run from the extracted root.
dart tool/bootstrap.dart --clean
cd packages/ponjika
dart pub get
dart pub publish --dry-run
dart pub publish
```

Review pub's file list and resolve warnings before confirming upload. Ensure
package metadata URLs refer to the repository where you actually commit this
release. The original repository URL is retained; it is not created or updated
by this ZIP.

## 3. Publish Flutter after the core is available

After pub.dev resolves the new core version:

```sh
cd ../ponjika_flutter
flutter pub get
flutter analyze
flutter test
flutter pub publish --dry-run
flutter pub publish
```

Do not bypass dependency validation to hide an unpublished core dependency.
The nested example has a development path dependency on its parent; the main
Flutter package has only the hosted `ponjika: ^2.0.0` dependency.

## Release checks

- Keep README, CHANGELOG, LICENSE, API docs, tests and generated .g.dart files.
- Exclude build output, caches, local override files and lockfiles using .pubignore.
- Run the example on target platforms and verify Bengali font rendering and assistive technology.
- CI validates on current stable Flutter; consumers using the declared minimum
  SDK should validate that minimum in their own SDK matrix before tightening support guarantees.

Official guidance: https://dart.dev/tools/pub/publishing and
https://dart.dev/tools/pub/cmd/pub-lish .
