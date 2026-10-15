import 'dart:io';

/// Run from the extracted bundle root; never changes publishable manifests.
void main(List<String> args) {
  if (!File('packages/ponjika/pubspec.yaml').existsSync()) {
    stderr.writeln('Run from the extracted ponjika-release root.');
    exitCode = 1;
    return;
  }
  final overrides = {
    'packages/ponjika_flutter/pubspec_overrides.yaml': '../ponjika',
    'packages/ponjika_flutter/example/pubspec_overrides.yaml': '../../ponjika',
  };
  for (final entry in overrides.entries) {
    final file = File(entry.key);
    if (args.contains('--clean')) {
      if (file.existsSync()) file.deleteSync();
    } else {
      file.writeAsStringSync(
        'dependency_overrides:\n  ponjika:\n    path: ${entry.value}\n',
      );
    }
  }
  stdout.writeln(
    args.contains('--clean')
        ? 'Local overrides removed.'
        : 'Local overrides ready. Run bash tool/check.sh.',
  );
}
