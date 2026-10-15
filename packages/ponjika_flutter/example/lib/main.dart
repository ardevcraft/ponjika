import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ponjika_flutter/ponjika_flutter.dart';

void main() => runApp(const PonjikaExample());

class PonjikaExample extends StatefulWidget {
  const PonjikaExample({super.key});
  @override
  State<PonjikaExample> createState() => _PonjikaExampleState();
}

class _PonjikaExampleState extends State<PonjikaExample> {
  ThemeMode _mode = ThemeMode.system;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Ponjika',
    debugShowCheckedModeBanner: false,
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('en'), Locale('bn')],
    theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
    darkTheme: ThemeData(
      colorSchemeSeed: Colors.deepPurple,
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    themeMode: _mode,
    home: _Playground(
      onTheme: () => setState(
        () =>
            _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      ),
    ),
  );
}

class _Playground extends StatefulWidget {
  const _Playground({required this.onTheme});
  final VoidCallback onTheme;
  @override
  State<_Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<_Playground> {
  BanglaDate _date = const BanglaCalendar().today(
    utcOffset: const Duration(hours: 6),
  );
  PonjikaLanguage _language = PonjikaLanguage.bangla;
  PonjikaNumerals _numerals = PonjikaNumerals.bangla;
  String _pattern = 'EEEE, d MMMM yyyy • SSSS';
  String? _error;
  bool _gregorian = true;
  @override
  Widget build(BuildContext context) {
    final tokens = PonjikaCalendarTheme.of(context);
    final text = Theme.of(context).textTheme;
    String output;
    try {
      output = BanglaDateFormat(
        _pattern,
        language: _language,
        numerals: _numerals,
      ).format(_date);
    } on FormatException {
      output = 'Enter a supported format pattern.';
    }
    final patternLiteral = jsonEncode(_pattern).replaceAll(r'$', r'\$');
    final snippet =
        "BanglaDateFormat($patternLiteral, language: PonjikaLanguage.${_language.name}, "
        "numerals: PonjikaNumerals.${_numerals.name}).format(BanglaDate(${_date.year}, ${_date.month}, ${_date.day}));";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ponjika · Calendar playground'),
        actions: [
          IconButton(
            onPressed: widget.onTheme,
            tooltip: 'Toggle theme',
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.contentPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maximumWidth * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(output, style: text.headlineSmall),
                SizedBox(height: tokens.spacing),
                Wrap(
                  spacing: tokens.spacing,
                  runSpacing: tokens.spacing,
                  children: [
                    SegmentedButton<PonjikaLanguage>(
                      segments: const [
                        ButtonSegment(
                          value: PonjikaLanguage.bangla,
                          label: Text('বাংলা'),
                        ),
                        ButtonSegment(
                          value: PonjikaLanguage.english,
                          label: Text('English'),
                        ),
                      ],
                      selected: {_language},
                      onSelectionChanged: (s) =>
                          setState(() => _language = s.first),
                    ),
                    SegmentedButton<PonjikaNumerals>(
                      segments: const [
                        ButtonSegment(
                          value: PonjikaNumerals.bangla,
                          label: Text('১২৩'),
                        ),
                        ButtonSegment(
                          value: PonjikaNumerals.latin,
                          label: Text('123'),
                        ),
                      ],
                      selected: {_numerals},
                      onSelectionChanged: (s) =>
                          setState(() => _numerals = s.first),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show Gregorian dates'),
                  value: _gregorian,
                  onChanged: (v) => setState(() => _gregorian = v),
                ),
                Align(
                  child: PonjikaCalendar(
                    value: _date,
                    today: const BanglaCalendar().today(
                      utcOffset: const Duration(hours: 6),
                    ),
                    language: _language,
                    numerals: _numerals,
                    showGregorian: _gregorian,
                    onChanged: (d) => setState(() => _date = d),
                  ),
                ),
                Wrap(
                  spacing: tokens.spacing,
                  runSpacing: tokens.spacing,
                  children: [
                    FilledButton.tonal(
                      onPressed: () async {
                        final date = await showPonjikaDatePicker(
                          context: context,
                          initialDate: _date,
                          language: _language,
                          numerals: _numerals,
                        );
                        if (date != null && mounted)
                          setState(() => _date = date);
                      },
                      child: const Text('Date picker'),
                    ),
                    FilledButton.tonal(
                      onPressed: () async {
                        final range = await showPonjikaDateRangePicker(
                          context: context,
                          language: _language,
                          numerals: _numerals,
                        );
                        if (range != null && context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${range.start} → ${range.end} (${range.lengthInDays} days)',
                              ),
                            ),
                          );
                      },
                      child: const Text('Range picker'),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing),
                TextFormField(
                  initialValue: _pattern,
                  decoration: InputDecoration(
                    labelText: 'Format pattern',
                    helperText:
                        'yyyy · MM · MMMM · d · dd · EEEE · SSSS · [literal]',
                    errorText: _error,
                  ),
                  onChanged: (value) => setState(() {
                    _pattern = value;
                    try {
                      BanglaDateFormat(value);
                      _error = null;
                    } on FormatException catch (e) {
                      _error = e.message;
                    }
                  }),
                ),
                SizedBox(height: tokens.spacing),
                SelectableText(snippet, style: text.bodySmall),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: snippet));
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dart snippet copied')),
                        );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Dart'),
                  ),
                ),
                Text(BanglaCalendar.rulesDescription, style: text.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
