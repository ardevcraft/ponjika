#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dart tool/bootstrap.dart
dart format --output=none --set-exit-if-changed packages tool/bootstrap.dart
(
  cd packages/ponjika
  dart pub get
  dart analyze
  dart test
)
(
  cd packages/ponjika_flutter
  flutter pub get
  flutter analyze
  flutter test
)
(
  cd packages/ponjika_flutter/example
  flutter pub get
  flutter analyze
  flutter test
)
