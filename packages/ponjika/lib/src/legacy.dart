import 'calendar.dart';
import 'date.dart';
import 'format.dart';

/// Compatibility facade for 1.x callers. Conversion accuracy changes in 2.0.
abstract final class Ponjika {
  static String format({
    DateTime? date,
    String displayLanguage = 'bangla',
    String dayStartsAt = 'midnight',
    bool showSeason = false,
    bool showWeekDays = false,
    String format = 'DD MM, YY',
  }) {
    if (dayStartsAt != 'midnight') {
      throw UnsupportedError(
        'Only midnight civil dates are supported; sunrise needs astronomical rules.',
      );
    }
    final language = switch (displayLanguage) {
      'bangla' || 'bn' => PonjikaLanguage.bangla,
      'english' || 'en' => PonjikaLanguage.english,
      _ => throw ArgumentError.value(displayLanguage, 'displayLanguage'),
    };
    final value = const BanglaCalendar().fromGregorian(date ?? DateTime.now());
    final result = format.replaceAllMapped(
      RegExp('DD|MM|YY|WW|SS', caseSensitive: false),
      (m) {
        return switch (m[0]!.toUpperCase()) {
          'DD' => value.day.toString(),
          'MM' => value.monthValue.nameIn(language),
          'YY' => value.year.toString(),
          'WW' => ponjikaWeekdayName(value.weekday, language),
          'SS' => value.season.nameIn(language),
          _ => m[0]!,
        };
      },
    );
    return ponjikaDigits(
      result,
      language == PonjikaLanguage.bangla
          ? PonjikaNumerals.bangla
          : PonjikaNumerals.latin,
    );
  }

  static String getSeasonEmoji(DateTime? date, {bool showName = false}) {
    final season = const BanglaCalendar()
        .fromGregorian(date ?? DateTime.now())
        .season;
    return showName
        ? '${season.emoji} ${season.nameIn(PonjikaLanguage.bangla)}'
        : season.emoji;
  }
}
