import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponjika_flutter_example/main.dart';

void main() {
  testWidgets('playground opens and switches language without layout errors', (
    tester,
  ) async {
    await tester.pumpWidget(const PonjikaExample());
    await tester.pumpAndSettle();
    expect(find.text('Ponjika · Calendar playground'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
