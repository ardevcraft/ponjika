import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ponjika/ponjika.dart';

import 'theme.dart';

/// Custom cell content; the calendar retains the button and accessibility label.
typedef PonjikaDayBuilder =
    Widget Function(
      BuildContext context,
      BanglaDate date,
      bool selected,
      bool inDisplayedMonth,
    );

/// A controlled date selection with internally managed month navigation.
///
/// [onChanged] null makes selection read-only. [selectedRange] highlights an
/// inclusive range; callers decide how taps update that range. Keyboard users
/// can Tab through days, use arrow keys, and select with Enter or Space.
class PonjikaCalendar extends StatefulWidget {
  PonjikaCalendar({
    super.key,
    this.value,
    this.selectedRange,
    this.initialMonth,
    this.onChanged,
    this.onMonthChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.language = PonjikaLanguage.bangla,
    this.numerals = PonjikaNumerals.bangla,
    this.firstWeekday = DateTime.saturday,
    this.today,
    this.showGregorian = true,
    this.showTodayButton = true,
    this.dayBuilder,
  }) {
    RangeError.checkValueInInterval(firstWeekday, 1, 7, 'firstWeekday');
    if (firstDate != null &&
        lastDate != null &&
        lastDate!.isBefore(firstDate!)) {
      throw ArgumentError('lastDate must not precede firstDate');
    }
  }
  final BanglaDate? value;
  final BanglaDateRange? selectedRange;
  final BanglaDate? initialMonth;
  final ValueChanged<BanglaDate>? onChanged;
  final ValueChanged<BanglaDate>? onMonthChanged;
  final BanglaDate? firstDate;
  final BanglaDate? lastDate;
  final bool Function(BanglaDate date)? selectableDayPredicate;
  final PonjikaLanguage language;
  final PonjikaNumerals numerals;
  final int firstWeekday;
  final BanglaDate? today;
  final bool showGregorian;
  final bool showTodayButton;
  final PonjikaDayBuilder? dayBuilder;
  @override
  State<PonjikaCalendar> createState() => _PonjikaCalendarState();
}

class _PonjikaCalendarState extends State<PonjikaCalendar> {
  late BanglaDate _month;
  final _focusNodes = <BanglaDate, FocusNode>{};
  BanglaDate get _today => widget.today ?? const BanglaCalendar().today();
  bool get _bn => widget.language == PonjikaLanguage.bangla;
  String _digits(Object value) => ponjikaDigits('$value', widget.numerals);
  BanglaDate get _minimum =>
      widget.firstDate ?? BanglaDate(BanglaDate.minYear, 1, 1);
  BanglaDate get _maximum =>
      widget.lastDate ?? BanglaDate(BanglaDate.maxYear, 12, 30);
  BanglaDate _clamp(BanglaDate date) => date.isBefore(_minimum)
      ? _minimum
      : date.isAfter(_maximum)
      ? _maximum
      : date;

  @override
  void initState() {
    super.initState();
    _month = _clamp(
      widget.initialMonth ??
          widget.value ??
          widget.selectedRange?.start ??
          _today,
    ).startOfMonth;
  }

  @override
  void didUpdateWidget(covariant PonjikaCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectionChanged =
        widget.value != oldWidget.value ||
        widget.selectedRange != oldWidget.selectedRange;
    final updated = selectionChanged
        ? widget.value ?? widget.selectedRange?.end
        : null;
    _month = _clamp(updated ?? _month).startOfMonth;
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  bool _withinBounds(BanglaDate date) =>
      !date.isBefore(_minimum) && !date.isAfter(_maximum);
  bool _enabled(BanglaDate date) =>
      widget.onChanged != null &&
      _withinBounds(date) &&
      (widget.selectableDayPredicate?.call(date) ?? true);
  bool _canMove(int offset) {
    try {
      final next = _month.addMonths(offset);
      return !next.endOfMonth.isBefore(_minimum) && !next.isAfter(_maximum);
    } on RangeError {
      return false;
    }
  }

  void _showMonth(BanglaDate date) {
    final month = _clamp(date).startOfMonth;
    if (month == _month) return;
    setState(() => _month = month);
    widget.onMonthChanged?.call(month);
  }

  void _pick(BanglaDate date) {
    if (!_enabled(date)) return;
    _showMonth(date);
    widget.onChanged?.call(date);
  }

  KeyEventResult _key(BanglaDate date, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent)
      return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final offset = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => rtl ? 1 : -1,
      LogicalKeyboardKey.arrowRight => rtl ? -1 : 1,
      LogicalKeyboardKey.arrowUp => -7,
      LogicalKeyboardKey.arrowDown => 7,
      _ => null,
    };
    if (offset == null) return KeyEventResult.ignored;
    BanglaDate next;
    try {
      next = date.addDays(offset);
    } on RangeError {
      return KeyEventResult.handled;
    }
    // Skip disabled days in the same direction, staying within supported bounds.
    var skipped = 0;
    while (_withinBounds(next) && !_enabled(next)) {
      if (++skipped > 366) return KeyEventResult.handled;
      try {
        next = next.addDays(offset.sign);
      } on RangeError {
        return KeyEventResult.handled;
      }
    }
    if (!_withinBounds(next)) return KeyEventResult.handled;
    _showMonth(next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[next]?.requestFocus();
    });
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tokens = PonjikaCalendarTheme.of(context);
    final cells = const BanglaCalendar().monthGrid(
      _month.year,
      _month.month,
      firstWeekday: widget.firstWeekday,
    );
    final visible = cells.map((c) => c.date).whereType<BanglaDate>().toSet();
    // Keep focus state bounded to the visible grid, disposing after detachment.
    final obsolete = _focusNodes.keys
        .where((d) => !visible.contains(d))
        .toList();
    final retired = [for (final date in obsolete) _focusNodes.remove(date)!];
    if (retired.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final node in retired) {
          node.dispose();
        }
      });
    }
    final today = _today;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cellHeight = tokens.cellHeight * (textScale < 1 ? 1 : textScale);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: tokens.maximumWidth),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(tokens.cornerRadius),
        child: Padding(
          padding: EdgeInsets.all(tokens.contentPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    key: const ValueKey('ponjika.previous'),
                    tooltip: _bn ? 'আগের মাস' : 'Previous month',
                    onPressed: _canMove(-1)
                        ? () => _showMonth(_month.addMonths(-1))
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        '${_month.monthValue.nameIn(widget.language)} ${_digits(_month.year)}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('ponjika.next'),
                    tooltip: _bn ? 'পরের মাস' : 'Next month',
                    onPressed: _canMove(1)
                        ? () => _showMonth(_month.addMonths(1))
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing),
                child: Row(
                  children: List.generate(7, (index) {
                    final day = (widget.firstWeekday - 1 + index) % 7 + 1;
                    final name = ponjikaWeekdayName(day, widget.language);
                    return Expanded(
                      child: Semantics(
                        label: name,
                        excludeSemantics: true,
                        child: Text(
                          name.substring(0, _bn ? 2 : 3),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    6,
                    (week) => Row(
                      children: List.generate(7, (dayIndex) {
                        final cell = cells[week * 7 + dayIndex];
                        final date = cell.date;
                        if (date == null)
                          return Expanded(child: SizedBox(height: cellHeight));
                        final selected =
                            widget.value == date ||
                            widget.selectedRange?.start == date ||
                            widget.selectedRange?.end == date;
                        final inRange =
                            widget.selectedRange?.contains(date) ?? false;
                        final isToday = date == today;
                        final enabled = _enabled(date);
                        final foreground = selected
                            ? colors.onPrimary
                            : !enabled
                            ? colors.onSurface.withValues(alpha: 0.38)
                            : inRange
                            ? colors.onSecondaryContainer
                            : cell.isCurrentMonth
                            ? colors.onSurface
                            : colors.onSurfaceVariant;
                        final gregorian = date.toGregorian();
                        final semanticLabel =
                            '${BanglaDateFormat('EEEE, d MMMM yyyy', language: widget.language, numerals: widget.numerals).format(date)}, ${gregorian.year}-${gregorian.month}-${gregorian.day}'
                            '${isToday ? (_bn ? ', আজ' : ', Today') : ''}';
                        final node = _focusNodes.putIfAbsent(
                          date,
                          () => FocusNode(debugLabel: 'Ponjika $date'),
                        );
                        return Expanded(
                          child: SizedBox(
                            height: cellHeight,
                            child: Focus(
                              onKeyEvent: (_, event) => _key(date, event),
                              child: Semantics(
                                label: semanticLabel,
                                selected: selected,
                                button: true,
                                enabled: enabled,
                                excludeSemantics: true,
                                onTap: enabled ? () => _pick(date) : null,
                                child: TextButton(
                                  key: ValueKey('ponjika.day.$date'),
                                  focusNode: node,
                                  onPressed: enabled ? () => _pick(date) : null,
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    foregroundColor: foreground,
                                    disabledForegroundColor: foreground,
                                    backgroundColor: selected
                                        ? colors.primary
                                        : inRange
                                        ? colors.secondaryContainer
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        tokens.cornerRadius / 2,
                                      ),
                                      side: isToday
                                          ? BorderSide(color: colors.primary)
                                          : BorderSide.none,
                                    ),
                                  ),
                                  child:
                                      widget.dayBuilder?.call(
                                        context,
                                        date,
                                        selected,
                                        cell.isCurrentMonth,
                                      ) ??
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              _digits(date.day),
                                              maxLines: 1,
                                              softWrap: false,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: foreground,
                                                    fontWeight:
                                                        selected || isToday
                                                        ? FontWeight.w700
                                                        : null,
                                                  ),
                                            ),
                                          ),
                                          if (widget.showGregorian)
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '${gregorian.day}/${gregorian.month}',
                                                maxLines: 1,
                                                softWrap: false,
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: foreground,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              if (widget.showTodayButton)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    key: const ValueKey('ponjika.today'),
                    onPressed: _withinBounds(_today)
                        ? () => _showMonth(_today)
                        : null,
                    child: Text(_bn ? 'আজ' : 'Today'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
