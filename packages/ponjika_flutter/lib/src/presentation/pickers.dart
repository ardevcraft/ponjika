import 'package:flutter/material.dart';
import 'package:ponjika/ponjika.dart';

import 'calendar.dart';
import 'theme.dart';

/// Shows a single-date dialog. Returns null on cancel, back, or barrier dismissal.
Future<BanglaDate?> showPonjikaDatePicker({
  required BuildContext context,
  BanglaDate? initialDate,
  BanglaDate? firstDate,
  BanglaDate? lastDate,
  bool Function(BanglaDate)? selectableDayPredicate,
  PonjikaLanguage language = PonjikaLanguage.bangla,
  PonjikaNumerals numerals = PonjikaNumerals.bangla,
  int firstWeekday = DateTime.saturday,
  BanglaDate? today,
  bool showGregorian = true,
  bool barrierDismissible = true,
  PonjikaCalendarTheme? theme,
}) {
  _validateBounds(firstDate, lastDate);
  if (initialDate != null &&
      !_isSelectable(
        initialDate,
        firstDate,
        lastDate,
        selectableDayPredicate,
      )) {
    throw ArgumentError('initialDate must be within bounds and selectable');
  }
  return showDialog<BanglaDate>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => _PonjikaPicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      language: language,
      numerals: numerals,
      firstWeekday: firstWeekday,
      today: today,
      showGregorian: showGregorian,
      theme: theme,
    ),
  );
}

/// Range selection resets after two taps. Every date in a confirmed range must
/// pass [selectableDayPredicate]. Returns null when dismissed without confirming.
Future<BanglaDateRange?> showPonjikaDateRangePicker({
  required BuildContext context,
  BanglaDateRange? initialRange,
  BanglaDate? firstDate,
  BanglaDate? lastDate,
  bool Function(BanglaDate)? selectableDayPredicate,
  PonjikaLanguage language = PonjikaLanguage.bangla,
  PonjikaNumerals numerals = PonjikaNumerals.bangla,
  int firstWeekday = DateTime.saturday,
  BanglaDate? today,
  bool showGregorian = true,
  bool barrierDismissible = true,
  PonjikaCalendarTheme? theme,
}) {
  _validateBounds(firstDate, lastDate);
  if (initialRange != null &&
      !_rangeSelectable(
        initialRange,
        firstDate,
        lastDate,
        selectableDayPredicate,
      )) {
    throw ArgumentError(
      'initialRange must contain only selectable dates within bounds',
    );
  }
  return showDialog<BanglaDateRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => _PonjikaPicker(
      rangeMode: true,
      initialRange: initialRange,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      language: language,
      numerals: numerals,
      firstWeekday: firstWeekday,
      today: today,
      showGregorian: showGregorian,
      theme: theme,
    ),
  );
}

void _validateBounds(BanglaDate? first, BanglaDate? last) {
  if (first != null && last != null && last.isBefore(first))
    throw ArgumentError('Invalid date bounds');
}

bool _isSelectable(
  BanglaDate date,
  BanglaDate? first,
  BanglaDate? last,
  bool Function(BanglaDate)? predicate,
) =>
    !(first != null && date.isBefore(first)) &&
    !(last != null && date.isAfter(last)) &&
    (predicate?.call(date) ?? true);
bool _rangeSelectable(
  BanglaDateRange range,
  BanglaDate? first,
  BanglaDate? last,
  bool Function(BanglaDate)? predicate,
) {
  if (!_isSelectable(range.start, first, last, predicate) ||
      !_isSelectable(range.end, first, last, predicate))
    return false;
  return predicate == null || range.dates.every(predicate);
}

class _PonjikaPicker extends StatefulWidget {
  const _PonjikaPicker({
    this.rangeMode = false,
    this.initialDate,
    this.initialRange,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    required this.language,
    required this.numerals,
    required this.firstWeekday,
    this.today,
    required this.showGregorian,
    this.theme,
  });
  final bool rangeMode;
  final BanglaDate? initialDate;
  final BanglaDateRange? initialRange;
  final BanglaDate? firstDate;
  final BanglaDate? lastDate;
  final bool Function(BanglaDate)? selectableDayPredicate;
  final PonjikaLanguage language;
  final PonjikaNumerals numerals;
  final int firstWeekday;
  final BanglaDate? today;
  final bool showGregorian;
  final PonjikaCalendarTheme? theme;
  @override
  State<_PonjikaPicker> createState() => _PonjikaPickerState();
}

class _PonjikaPickerState extends State<_PonjikaPicker> {
  BanglaDate? _start;
  BanglaDate? _end;
  bool _invalidRange = false;
  bool get _bn => widget.language == PonjikaLanguage.bangla;
  @override
  void initState() {
    super.initState();
    _start = widget.rangeMode ? widget.initialRange?.start : widget.initialDate;
    _end = widget.initialRange?.end;
  }

  BanglaDateRange? get _range => _start != null && _end != null
      ? BanglaDateRange(start: _start!, end: _end!)
      : null;
  void _select(BanglaDate date) => setState(() {
    _invalidRange = false;
    if (!widget.rangeMode || _start == null || _end != null) {
      _start = date;
      _end = null;
    } else {
      final range = date.isBefore(_start!)
          ? BanglaDateRange(start: date, end: _start!)
          : BanglaDateRange(start: _start!, end: date);
      if (!_rangeSelectable(
        range,
        widget.firstDate,
        widget.lastDate,
        widget.selectableDayPredicate,
      )) {
        _invalidRange = true;
      } else {
        _start = range.start;
        _end = range.end;
      }
    }
  });
  @override
  Widget build(BuildContext context) {
    final tokens = PonjikaCalendarTheme.of(context);
    final text = Theme.of(context).textTheme;
    final formatter = BanglaDateFormat.long(
      language: widget.language,
      numerals: widget.numerals,
    );
    final complete = widget.rangeMode ? _range != null : _start != null;
    return AlertDialog(
      scrollable: true,
      titlePadding: EdgeInsets.all(tokens.contentPadding),
      contentPadding: EdgeInsets.symmetric(horizontal: tokens.contentPadding),
      actionsPadding: EdgeInsets.all(tokens.contentPadding),
      title: Text(
        widget.rangeMode
            ? (_bn ? 'তারিখের পরিসর নির্বাচন করুন' : 'Select date range')
            : (_bn ? 'তারিখ নির্বাচন করুন' : 'Select date'),
      ),
      content: SizedBox(
        width: tokens.maximumWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                _start == null
                    ? (_bn
                          ? 'শুরুর তারিখ নির্বাচন করুন'
                          : 'Choose a start date')
                    : '${formatter.format(_start!)}${_end == null ? '' : ' – ${formatter.format(_end!)}'}',
                style: text.bodyMedium,
              ),
            ),
            PonjikaCalendar(
              value: widget.rangeMode ? (_end == null ? _start : null) : _start,
              selectedRange: _range,
              initialMonth: _start,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              selectableDayPredicate: widget.selectableDayPredicate,
              language: widget.language,
              numerals: widget.numerals,
              firstWeekday: widget.firstWeekday,
              today: widget.today,
              showGregorian: widget.showGregorian,
              theme: widget.theme,
              onChanged: _select,
            ),
            if (_invalidRange)
              Semantics(
                liveRegion: true,
                child: Text(
                  _bn
                      ? 'এই পরিসরে অনির্বাচনযোগ্য তারিখ রয়েছে। অন্য তারিখ নির্বাচন করুন।'
                      : 'This range includes unavailable dates. Choose another date.',
                  style: text.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('ponjika.cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_bn ? 'বাতিল' : 'Cancel'),
        ),
        FilledButton(
          key: const ValueKey('ponjika.confirm'),
          onPressed: complete
              ? () {
                  if (widget.rangeMode) {
                    Navigator.of(context).pop(_range);
                  } else {
                    Navigator.of(context).pop(_start);
                  }
                }
              : null,
          child: Text(_bn ? 'নিশ্চিত করুন' : 'Confirm'),
        ),
      ],
    );
  }
}
