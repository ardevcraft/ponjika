import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponjika_flutter/ponjika_flutter.dart';

void main() {
  final today = BanglaDate(1432, 1, 4);
  Widget host(
    Widget child, {
    Brightness brightness = Brightness.light,
    double scale = 1,
  }) => MaterialApp(
    theme: ThemeData(brightness: brightness, useMaterial3: true),
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: SingleChildScrollView(child: child),
      ),
    ),
  );

  testWidgets('selects a civil date and navigates month boundaries', (
    tester,
  ) async {
    BanglaDate? selected;
    await tester.pumpWidget(
      host(
        PonjikaCalendar(
          value: today,
          today: today,
          onChanged: (date) => selected = date,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('ponjika.day.1432-01-05')));
    expect(selected, BanglaDate(1432, 1, 5));
    await tester.tap(find.byKey(const ValueKey('ponjika.next')));
    await tester.pump();
    expect(find.text('জ্যৈষ্ঠ ১৪৩২'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ponjika.today')));
    await tester.pump();
    expect(find.text('বৈশাখ ১৪৩২'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('respects disabled days and navigation bounds', (tester) async {
    BanglaDate? selected;
    await tester.pumpWidget(
      host(
        PonjikaCalendar(
          value: today,
          today: today,
          firstDate: today,
          lastDate: today.addDays(3),
          selectableDayPredicate: (date) => date.day != 5,
          onChanged: (date) => selected = date,
        ),
      ),
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('ponjika.previous')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('ponjika.next')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('ponjika.day.1432-01-05')));
    expect(selected, isNull);
    await tester.tap(find.byKey(const ValueKey('ponjika.day.1432-01-06')));
    expect(selected, today.addDays(2));
  });
  testWidgets('keyboard arrows move focus and Enter selects', (tester) async {
    BanglaDate? selected;
    await tester.pumpWidget(
      host(
        PonjikaCalendar(
          value: today,
          today: today,
          onChanged: (date) => selected = date,
        ),
      ),
    );
    final button = tester.widget<TextButton>(
      find.byKey(const ValueKey('ponjika.day.1432-01-04')),
    );
    button.focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, today.addDays(1));
  });
  testWidgets('supports dark theme, 320px width and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      host(
        PonjikaCalendar(value: today, today: today, onChanged: (_) {}),
        brightness: Brightness.dark,
        scale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('date picker confirms and cancel returns null', (tester) async {
    BanglaDate? result;
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showPonjikaDatePicker(
                  context: context,
                  initialDate: today,
                  today: today,
                  language: PonjikaLanguage.english,
                );
                completed = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ponjika.confirm')));
    await tester.pumpAndSettle();
    expect(result, today);
    completed = false;
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ponjika.cancel')));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(result, isNull);
  });
  testWidgets('range picker sorts reverse selection and confirms', (
    tester,
  ) async {
    BanglaDateRange? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showPonjikaDateRangePicker(
                  context: context,
                  today: today,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ponjika.day.1432-01-08')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ponjika.day.1432-01-04')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ponjika.confirm')));
    await tester.pumpAndSettle();
    expect(result, BanglaDateRange(start: today, end: today.addDays(4)));
  });
  testWidgets('range picker rejects an unavailable interior date', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showPonjikaDateRangePicker(
                context: context,
                today: today,
                language: PonjikaLanguage.english,
                selectableDayPredicate: (date) => date.day != 6,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ponjika.day.1432-01-04')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ponjika.day.1432-01-08')));
    await tester.pump();
    expect(
      find.text('This range includes unavailable dates. Choose another date.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('ponjika.confirm')))
          .onPressed,
      isNull,
    );
  });
}
