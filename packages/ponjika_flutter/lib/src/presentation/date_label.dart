import 'package:flutter/material.dart';
import 'package:ponjika/ponjika.dart';

/// Compact date label. Rebuild with a new [date] when the civil day changes.
class PonjikaDateLabel extends StatelessWidget {
  const PonjikaDateLabel({
    super.key,
    required this.date,
    this.language = PonjikaLanguage.bangla,
    this.numerals = PonjikaNumerals.bangla,
    this.showWeekday = false,
    this.showSeason = false,
    this.style,
  });
  final BanglaDate date;
  final PonjikaLanguage language;
  final PonjikaNumerals numerals;
  final bool showWeekday;
  final bool showSeason;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    final format = BanglaDateFormat(
      '${showWeekday ? 'EEEE, ' : ''}d MMMM yyyy${showSeason ? ' • SSSS' : ''}',
      language: language,
      numerals: numerals,
    );
    return Text(
      format.format(date),
      style: style ?? Theme.of(context).textTheme.bodyMedium,
    );
  }
}
