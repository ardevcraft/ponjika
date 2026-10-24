import 'package:erp_platform/src/features/student/tools/bangla_date/presentation/services/bangla_launcher_widget_service.dart';
import 'package:erp_platform/src/shared/components/curved_surface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ponjika_flutter/ponjika_flutter.dart';

import '../providers/bangla_date_providers.dart';

class BanglaCalendarScreen extends ConsumerStatefulWidget {
  const BanglaCalendarScreen({super.key});

  @override
  ConsumerState<BanglaCalendarScreen> createState() =>
      _BanglaCalendarScreenState();
}

class _BanglaCalendarScreenState extends ConsumerState<BanglaCalendarScreen>
    with WidgetsBindingObserver {
  late BanglaDate _selectedDate;
  late BanglaDate _todayDate;
  bool _showGregorianDates = true;

  static const _banglaWeekdays = <String>[
    'সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি', 'শুক্র', 'শনি', 'রবি',
  ];

  BanglaDate _today(Duration offset) =>
      const BanglaCalendar().today(utcOffset: offset);

  bool _sameDate(BanglaDate a, BanglaDate b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void initState() {
    super.initState();
    _todayDate = _today(ref.read(banglaDateConfigProvider).utcOffset);
    _selectedDate = _todayDate;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    final fresh = _today(ref.read(banglaDateConfigProvider).utcOffset);
    if (!_sameDate(fresh, _todayDate)) {
      setState(() => _todayDate = fresh);
    }
  }

  Future<void> _showLauncherWidgetHelp() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final requested = await BanglaLauncherWidgetService.requestAndroidPin();
      if (!mounted) return;
      if (!requested) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
            'Open your Home screen Widgets menu to add the date widget.',
          )),
        );
      }
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.widgets_outlined),
        title: const Text('Add the Bangla date widget'),
        content: const Text(
          'Touch and hold your Home Screen, choose Add Widget, '
          'then select this app’s Bangla date widget.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(banglaDateConfigProvider);
    ref.listen<BanglaDateConfig>(banglaDateConfigProvider, (previous, next) {
      if (previous?.utcOffset == next.utcOffset) return;
      final date = _today(next.utcOffset);
      if (!_sameDate(date, _todayDate)) {
        setState(() => _todayDate = date);
      }
    });

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final type = theme.textTheme;
    final bangla = config.language == PonjikaLanguage.bangla;
    final selected = _selectedDate;
    final isToday = _sameDate(selected, _todayDate);
    final weekendRed = theme.brightness == Brightness.dark
        ? const Color(0xFFFFA2A4)
        : const Color(0xFFB7474B);
    final weekendSurface = Color.alphaBlend(
      weekendRed.withValues(alpha: theme.brightness == Brightness.dark ? .13 : .09),
      colors.surface,
    );

    String format(String pattern, BanglaDate date) => BanglaDateFormat(
      pattern,
      language: config.language,
      numerals: config.numerals,
    ).format(date);

    final calendarTheme = PonjikaCalendarTheme(
      backgroundColor: colors.surface,
      contentPadding: 8,
      spacing: 10,
      maximumWidth: 720,
      cellHeight: 66,
      cellSpacing: 3,
      cornerRadius: 24,
      dayCornerRadius: 13,
      headerPadding: const EdgeInsets.fromLTRB(0, 6, 0, 14),
      headerTextStyle: type.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      navigationBackgroundColor: colors.surfaceContainerHigh,
      navigationIconColor: colors.onSurface,
      weekdayPadding: const EdgeInsets.symmetric(vertical: 12),
      weekdayTextStyle: type.labelMedium?.copyWith(fontWeight: FontWeight.w800),
      weekdayColor: colors.onSurfaceVariant,
      weekendWeekdayColor: weekendRed,
      weekendBackgroundColor: weekendSurface,
      weekendForegroundColor: weekendRed,
      dayTextStyle: type.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      gregorianTextStyle: type.labelSmall?.copyWith(fontWeight: FontWeight.w500),
      outsideDayForegroundColor: colors.onSurfaceVariant.withValues(alpha: .48),
      selectedDayBackgroundColor: colors.primary,
      selectedDayForegroundColor: colors.onPrimary,
      selectedDayTextStyle: type.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      todayBorderColor: colors.primary,
      todayBorderWidth: 1.7,
      todayDayTextStyle: type.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      todayButtonForegroundColor: colors.primary,
      todayButtonTextStyle: type.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      todayButtonPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(bangla ? 'বাংলা ক্যালেন্ডার' : 'Bangla Calendar'),
        actions: [
          IconButton(
            tooltip: bangla ? 'হোম স্ক্রিনে উইজেট যোগ করুন' : 'Add widget',
            onPressed: _showLauncherWidgetHelp,
            icon: const Icon(Icons.widgets_outlined),
          ),
          IconButton(
            tooltip: bangla ? 'আজকের তারিখ' : 'Today',
            onPressed: () => setState(() => _selectedDate = _todayDate),
            icon: const Icon(Icons.today_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: CurvedSurface(
          child: LayoutBuilder(builder: (context, size) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: size.maxWidth >= 760 ? 760 : 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_outlined,
                                  size: 18, color: colors.onPrimaryContainer),
                              const SizedBox(width: 8),
                              Text(
                                isToday
                                    ? (bangla ? 'আজকের দিন' : 'Today')
                                    : (bangla ? 'নির্বাচিত দিন' : 'Selected date'),
                                style: type.labelLarge?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                format('d', selected),
                                style: type.displayLarge?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      format('MMMM yyyy', selected),
                                      style: type.titleLarge?.copyWith(
                                        color: colors.onPrimaryContainer,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      format('EEEE', selected),
                                      style: type.bodyMedium?.copyWith(
                                        color: colors.onPrimaryContainer.withValues(alpha: .8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: colors.onPrimaryContainer.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_outlined, size: 16,
                                    color: colors.onPrimaryContainer),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    MaterialLocalizations.of(context).formatMediumDate(
                                      selected.toGregorian(),
                                    ),
                                    style: type.labelMedium?.copyWith(
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: colors.outlineVariant.withValues(alpha: .5)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, color: colors.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    bangla ? 'মাসের দিনপঞ্জি' : 'Month calendar',
                                    style: type.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Text(bangla ? 'ইংরেজি' : 'Gregorian',
                                    style: type.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                                const SizedBox(width: 6),
                                Switch.adaptive(
                                  value: _showGregorianDates,
                                  onChanged: (value) => setState(() => _showGregorianDates = value),
                                ),
                              ],
                            ),
                          ),
                          PonjikaCalendar(
                            value: selected,
                            today: _todayDate,
                            language: config.language,
                            numerals: config.numerals,
                            firstWeekday: DateTime.saturday,
                            weekdayLabels: bangla ? _banglaWeekdays : null,
                            weekendDays: const {DateTime.friday, DateTime.saturday},
                            showGregorian: _showGregorianDates,
                            showTodayButton: false,
                            theme: calendarTheme,
                            onChanged: (date) => setState(() => _selectedDate = date),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(
                                    color: weekendSurface,
                                    border: Border.all(color: weekendRed.withValues(alpha: .5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    bangla ? 'শুক্র ও শনিবার সাপ্তাহিক ছুটি' : 'Friday & Saturday weekends',
                                    style: type.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                                  ),
                                ),
                                if (!isToday)
                                  TextButton.icon(
                                    onPressed: () => setState(() => _selectedDate = _todayDate),
                                    icon: const Icon(Icons.today_outlined, size: 17),
                                    label: Text(bangla ? 'আজ' : 'Today'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      bangla ? 'যেকোনো তারিখে স্পর্শ করে বিস্তারিত দেখুন' : 'Select any date to view its details',
                      textAlign: TextAlign.center,
                      style: type.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
