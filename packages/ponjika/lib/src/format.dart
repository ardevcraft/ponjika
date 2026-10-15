import 'date.dart';

const _bnDigits = '০১২৩৪৫৬৭৮৯';

/// Convert numerals without changing punctuation or other text.
String ponjikaDigits(String input, PonjikaNumerals numerals) {
  final latin = input.replaceAllMapped(
    RegExp('[০-৯]'),
    (m) => _bnDigits.indexOf(m[0]!).toString(),
  );
  return numerals == PonjikaNumerals.latin
      ? latin
      : latin.replaceAllMapped(
          RegExp('[0-9]'),
          (m) => _bnDigits[int.parse(m[0]!)],
        );
}

extension PonjikaStringNumerals on String {
  String toBanglaDigits() => ponjikaDigits(this, PonjikaNumerals.bangla);
  String toLatinDigits() => ponjikaDigits(this, PonjikaNumerals.latin);
}

/// Case-sensitive formatter. Wrap literal text in [square brackets].
/// Tokens: yyyy, yy, MMMM, MM, M, dd, d, EEEE, SSSS.
final class BanglaDateFormat {
  BanglaDateFormat(
    this.pattern, {
    this.language = PonjikaLanguage.bangla,
    this.numerals = PonjikaNumerals.bangla,
  }) : _parts = _tokenize(pattern);

  factory BanglaDateFormat.long({
    PonjikaLanguage language = PonjikaLanguage.bangla,
    PonjikaNumerals numerals = PonjikaNumerals.bangla,
  }) =>
      BanglaDateFormat('d MMMM, yyyy', language: language, numerals: numerals);
  factory BanglaDateFormat.iso({
    PonjikaNumerals numerals = PonjikaNumerals.latin,
  }) => BanglaDateFormat('yyyy-MM-dd', numerals: numerals);

  final String pattern;
  final PonjikaLanguage language;
  final PonjikaNumerals numerals;
  final List<_Part> _parts;

  String format(BanglaDate date) {
    final output = StringBuffer();
    for (final part in _parts) {
      if (!part.token) {
        output.write(part.text);
        continue;
      }
      output.write(switch (part.text) {
        'yyyy' => date.year.toString().padLeft(4, '0'),
        'yy' => (date.year % 100).toString().padLeft(2, '0'),
        'MMMM' => date.monthValue.nameIn(language),
        'MM' => date.month.toString().padLeft(2, '0'),
        'M' => date.month,
        'dd' => date.day.toString().padLeft(2, '0'),
        'd' => date.day,
        'EEEE' => ponjikaWeekdayName(date.weekday, language),
        'SSSS' => date.season.nameIn(language),
        _ => throw StateError('Unrecognized token'),
      });
    }
    return ponjikaDigits(output.toString(), numerals);
  }

  /// Strictly parses this pattern, accepting either numeral script.
  /// Requires yyyy, a month, and a day exactly once; yy parsing is ambiguous.
  /// Weekday and season tokens, when present, are checked against the date.
  BanglaDate parse(String input) {
    final expression = StringBuffer('^');
    final fields = <String>[];
    for (final part in _parts) {
      if (!part.token) {
        expression.write(RegExp.escape(part.text.toLatinDigits()));
        continue;
      }
      fields.add(part.text);
      expression.write(switch (part.text) {
        'yyyy' => r'([0-9]{4})',
        'MM' || 'dd' => r'([0-9]{2})',
        'M' || 'd' => r'([0-9]{1,2})',
        'MMMM' =>
          '(${BanglaMonth.values.map((m) => RegExp.escape(m.nameIn(language))).join('|')})',
        'EEEE' =>
          '(${List.generate(7, (i) => RegExp.escape(ponjikaWeekdayName(i + 1, language))).join('|')})',
        'SSSS' =>
          '(${BanglaSeason.values.map((s) => RegExp.escape(s.nameIn(language))).join('|')})',
        'yy' => throw FormatException(
          'Two-digit years cannot be parsed unambiguously',
          input,
        ),
        _ => throw StateError('Unrecognized token'),
      });
    }
    expression.write(r'$');
    final match = RegExp(
      expression.toString(),
    ).firstMatch(input.toLatinDigits());
    if (match == null)
      throw FormatException('Input does not match $pattern', input);
    int? year, month, day;
    String? weekday, season;
    for (var i = 0; i < fields.length; i++) {
      final value = match.group(i + 1)!;
      switch (fields[i]) {
        case 'yyyy':
          if (year != null) throw FormatException('Duplicate year', input);
          year = int.parse(value);
        case 'MMMM':
          if (month != null) throw FormatException('Duplicate month', input);
          month = BanglaMonth.values
              .firstWhere((m) => m.nameIn(language) == value)
              .number;
        case 'MM' || 'M':
          if (month != null) throw FormatException('Duplicate month', input);
          month = int.parse(value);
        case 'dd' || 'd':
          if (day != null) throw FormatException('Duplicate day', input);
          day = int.parse(value);
        case 'EEEE':
          weekday = value;
        case 'SSSS':
          season = value;
      }
    }
    if (year == null || month == null || day == null)
      throw FormatException('Pattern must contain year, month and day', input);
    late final BanglaDate result;
    try {
      result = BanglaDate(year, month, day);
    } on RangeError {
      throw FormatException('Invalid Bangla civil date', input);
    }
    if (weekday != null &&
        weekday != ponjikaWeekdayName(result.weekday, language))
      throw FormatException('Weekday does not match date', input);
    if (season != null && season != result.season.nameIn(language))
      throw FormatException('Season does not match date', input);
    return result;
  }

  BanglaDate? tryParse(String input) {
    try {
      return parse(input);
    } on FormatException {
      return null;
    }
  }
}

final class _Part {
  const _Part(this.text, this.token);
  final String text;
  final bool token;
}

List<_Part> _tokenize(String pattern) {
  const tokens = ['yyyy', 'MMMM', 'EEEE', 'SSSS', 'yy', 'MM', 'dd', 'M', 'd'];
  final parts = <_Part>[];
  var i = 0;
  while (i < pattern.length) {
    if (pattern[i] == '[') {
      final close = pattern.indexOf(']', i + 1);
      if (close < 0) throw FormatException('Unclosed literal', pattern, i);
      parts.add(_Part(pattern.substring(i + 1, close), false));
      i = close + 1;
      continue;
    }
    String? token;
    for (final candidate in tokens) {
      if (pattern.startsWith(candidate, i)) {
        token = candidate;
        break;
      }
    }
    if (token != null) {
      parts.add(_Part(token, true));
      i += token.length;
    } else {
      if (RegExp('[A-Za-z]').hasMatch(pattern[i]))
        throw FormatException(
          'Escape literal text with [brackets]',
          pattern,
          i,
        );
      parts.add(_Part(pattern[i], false));
      i++;
    }
  }
  return List.unmodifiable(parts);
}
