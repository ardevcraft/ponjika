import 'package:flutter/material.dart';

/// Visual and layout configuration for [PonjikaCalendar].
///
/// Add this to [ThemeData.extensions] to style every calendar, or pass an
/// instance directly to `PonjikaCalendar(theme: ...)` for a local override.
/// Colors and text styles left null are derived from the ambient Material
/// theme, keeping the calendar automatically compatible with light/dark mode.
@immutable
class PonjikaCalendarTheme extends ThemeExtension<PonjikaCalendarTheme> {
  const PonjikaCalendarTheme({
    this.spacing = 8,
    this.contentPadding = 12,
    this.cellHeight = 60,
    this.cellSpacing = 2,
    this.cornerRadius = 16,
    this.dayCornerRadius = 10,
    this.maximumWidth = 440,
    this.elevation = 0,
    this.backgroundColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.borderColor,
    this.borderWidth = 0,
    this.headerPadding = const EdgeInsets.only(bottom: 4),
    this.headerTextStyle,
    this.navigationIconColor,
    this.navigationDisabledIconColor,
    this.navigationBackgroundColor,
    this.navigationIconSize = 24,
    this.weekdayPadding = const EdgeInsets.symmetric(vertical: 8),
    this.weekdayTextStyle,
    this.weekdayColor,
    this.weekendWeekdayColor,
    this.weekendBackgroundColor,
    this.weekendForegroundColor,
    this.dayTextStyle,
    this.gregorianTextStyle,
    this.dayForegroundColor,
    this.outsideDayForegroundColor,
    this.disabledDayForegroundColor,
    this.selectedDayForegroundColor,
    this.selectedDayBackgroundColor,
    this.rangeDayForegroundColor,
    this.rangeDayBackgroundColor,
    this.todayForegroundColor,
    this.todayBackgroundColor,
    this.todayBorderColor,
    this.todayBorderWidth = 1,
    this.dayBorderColor,
    this.dayBorderWidth = 0,
    this.dayOverlayColor,
    this.selectedDayTextStyle,
    this.todayDayTextStyle,
    this.disabledDayTextStyle,
    this.outsideDayTextStyle,
    this.todayButtonTextStyle,
    this.todayButtonForegroundColor,
    this.todayButtonBackgroundColor,
    this.todayButtonPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.todayButtonAlignment = AlignmentDirectional.centerEnd,
  });

  final double spacing;
  final double contentPadding;
  final double cellHeight;
  final double cellSpacing;
  final double cornerRadius;
  final double dayCornerRadius;
  final double maximumWidth;
  final double elevation;

  final Color? backgroundColor;
  final Color? surfaceTintColor;
  final Color? shadowColor;
  final Color? borderColor;
  final double borderWidth;

  final EdgeInsetsGeometry headerPadding;
  final TextStyle? headerTextStyle;
  final Color? navigationIconColor;
  final Color? navigationDisabledIconColor;
  final Color? navigationBackgroundColor;
  final double navigationIconSize;

  final EdgeInsetsGeometry weekdayPadding;
  final TextStyle? weekdayTextStyle;
  final Color? weekdayColor;
  final Color? weekendWeekdayColor;
  final Color? weekendBackgroundColor;
  final Color? weekendForegroundColor;

  final TextStyle? dayTextStyle;
  final TextStyle? gregorianTextStyle;
  final Color? dayForegroundColor;
  final Color? outsideDayForegroundColor;
  final Color? disabledDayForegroundColor;
  final Color? selectedDayForegroundColor;
  final Color? selectedDayBackgroundColor;
  final Color? rangeDayForegroundColor;
  final Color? rangeDayBackgroundColor;
  final Color? todayForegroundColor;
  final Color? todayBackgroundColor;
  final Color? todayBorderColor;
  final double todayBorderWidth;
  final Color? dayBorderColor;
  final double dayBorderWidth;
  final Color? dayOverlayColor;
  final TextStyle? selectedDayTextStyle;
  final TextStyle? todayDayTextStyle;
  final TextStyle? disabledDayTextStyle;
  final TextStyle? outsideDayTextStyle;

  final TextStyle? todayButtonTextStyle;
  final Color? todayButtonForegroundColor;
  final Color? todayButtonBackgroundColor;
  final EdgeInsetsGeometry todayButtonPadding;
  final AlignmentGeometry todayButtonAlignment;

  static PonjikaCalendarTheme of(BuildContext context) =>
      Theme.of(context).extension<PonjikaCalendarTheme>() ??
      const PonjikaCalendarTheme();

  @override
  PonjikaCalendarTheme copyWith({
    double? spacing,
    double? contentPadding,
    double? cellHeight,
    double? cellSpacing,
    double? cornerRadius,
    double? dayCornerRadius,
    double? maximumWidth,
    double? elevation,
    Color? backgroundColor,
    Color? surfaceTintColor,
    Color? shadowColor,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? headerPadding,
    TextStyle? headerTextStyle,
    Color? navigationIconColor,
    Color? navigationDisabledIconColor,
    Color? navigationBackgroundColor,
    double? navigationIconSize,
    EdgeInsetsGeometry? weekdayPadding,
    TextStyle? weekdayTextStyle,
    Color? weekdayColor,
    Color? weekendWeekdayColor,
    Color? weekendBackgroundColor,
    Color? weekendForegroundColor,
    TextStyle? dayTextStyle,
    TextStyle? gregorianTextStyle,
    Color? dayForegroundColor,
    Color? outsideDayForegroundColor,
    Color? disabledDayForegroundColor,
    Color? selectedDayForegroundColor,
    Color? selectedDayBackgroundColor,
    Color? rangeDayForegroundColor,
    Color? rangeDayBackgroundColor,
    Color? todayForegroundColor,
    Color? todayBackgroundColor,
    Color? todayBorderColor,
    double? todayBorderWidth,
    Color? dayBorderColor,
    double? dayBorderWidth,
    Color? dayOverlayColor,
    TextStyle? selectedDayTextStyle,
    TextStyle? todayDayTextStyle,
    TextStyle? disabledDayTextStyle,
    TextStyle? outsideDayTextStyle,
    TextStyle? todayButtonTextStyle,
    Color? todayButtonForegroundColor,
    Color? todayButtonBackgroundColor,
    EdgeInsetsGeometry? todayButtonPadding,
    AlignmentGeometry? todayButtonAlignment,
  }) => PonjikaCalendarTheme(
    spacing: spacing ?? this.spacing,
    contentPadding: contentPadding ?? this.contentPadding,
    cellHeight: cellHeight ?? this.cellHeight,
    cellSpacing: cellSpacing ?? this.cellSpacing,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    dayCornerRadius: dayCornerRadius ?? this.dayCornerRadius,
    maximumWidth: maximumWidth ?? this.maximumWidth,
    elevation: elevation ?? this.elevation,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
    shadowColor: shadowColor ?? this.shadowColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    headerPadding: headerPadding ?? this.headerPadding,
    headerTextStyle: headerTextStyle ?? this.headerTextStyle,
    navigationIconColor: navigationIconColor ?? this.navigationIconColor,
    navigationDisabledIconColor: navigationDisabledIconColor ?? this.navigationDisabledIconColor,
    navigationBackgroundColor: navigationBackgroundColor ?? this.navigationBackgroundColor,
    navigationIconSize: navigationIconSize ?? this.navigationIconSize,
    weekdayPadding: weekdayPadding ?? this.weekdayPadding,
    weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
    weekdayColor: weekdayColor ?? this.weekdayColor,
    weekendWeekdayColor: weekendWeekdayColor ?? this.weekendWeekdayColor,
    weekendBackgroundColor: weekendBackgroundColor ?? this.weekendBackgroundColor,
    weekendForegroundColor: weekendForegroundColor ?? this.weekendForegroundColor,
    dayTextStyle: dayTextStyle ?? this.dayTextStyle,
    gregorianTextStyle: gregorianTextStyle ?? this.gregorianTextStyle,
    dayForegroundColor: dayForegroundColor ?? this.dayForegroundColor,
    outsideDayForegroundColor: outsideDayForegroundColor ?? this.outsideDayForegroundColor,
    disabledDayForegroundColor: disabledDayForegroundColor ?? this.disabledDayForegroundColor,
    selectedDayForegroundColor: selectedDayForegroundColor ?? this.selectedDayForegroundColor,
    selectedDayBackgroundColor: selectedDayBackgroundColor ?? this.selectedDayBackgroundColor,
    rangeDayForegroundColor: rangeDayForegroundColor ?? this.rangeDayForegroundColor,
    rangeDayBackgroundColor: rangeDayBackgroundColor ?? this.rangeDayBackgroundColor,
    todayForegroundColor: todayForegroundColor ?? this.todayForegroundColor,
    todayBackgroundColor: todayBackgroundColor ?? this.todayBackgroundColor,
    todayBorderColor: todayBorderColor ?? this.todayBorderColor,
    todayBorderWidth: todayBorderWidth ?? this.todayBorderWidth,
    dayBorderColor: dayBorderColor ?? this.dayBorderColor,
    dayBorderWidth: dayBorderWidth ?? this.dayBorderWidth,
    dayOverlayColor: dayOverlayColor ?? this.dayOverlayColor,
    selectedDayTextStyle: selectedDayTextStyle ?? this.selectedDayTextStyle,
    todayDayTextStyle: todayDayTextStyle ?? this.todayDayTextStyle,
    disabledDayTextStyle: disabledDayTextStyle ?? this.disabledDayTextStyle,
    outsideDayTextStyle: outsideDayTextStyle ?? this.outsideDayTextStyle,
    todayButtonTextStyle: todayButtonTextStyle ?? this.todayButtonTextStyle,
    todayButtonForegroundColor: todayButtonForegroundColor ?? this.todayButtonForegroundColor,
    todayButtonBackgroundColor: todayButtonBackgroundColor ?? this.todayButtonBackgroundColor,
    todayButtonPadding: todayButtonPadding ?? this.todayButtonPadding,
    todayButtonAlignment: todayButtonAlignment ?? this.todayButtonAlignment,
  );

  @override
  PonjikaCalendarTheme lerp(covariant PonjikaCalendarTheme? other, double t) {
    if (other == null) return this;
    double mix(double a, double b) => a + (b - a) * t;
    return PonjikaCalendarTheme(
      spacing: mix(spacing, other.spacing),
      contentPadding: mix(contentPadding, other.contentPadding),
      cellHeight: mix(cellHeight, other.cellHeight),
      cellSpacing: mix(cellSpacing, other.cellSpacing),
      cornerRadius: mix(cornerRadius, other.cornerRadius),
      dayCornerRadius: mix(dayCornerRadius, other.dayCornerRadius),
      maximumWidth: mix(maximumWidth, other.maximumWidth),
      elevation: mix(elevation, other.elevation),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      surfaceTintColor: Color.lerp(surfaceTintColor, other.surfaceTintColor, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      borderWidth: mix(borderWidth, other.borderWidth),
      headerPadding: EdgeInsetsGeometry.lerp(headerPadding, other.headerPadding, t)!,
      headerTextStyle: TextStyle.lerp(headerTextStyle, other.headerTextStyle, t),
      navigationIconColor: Color.lerp(navigationIconColor, other.navigationIconColor, t),
      navigationDisabledIconColor: Color.lerp(navigationDisabledIconColor, other.navigationDisabledIconColor, t),
      navigationBackgroundColor: Color.lerp(navigationBackgroundColor, other.navigationBackgroundColor, t),
      navigationIconSize: mix(navigationIconSize, other.navigationIconSize),
      weekdayPadding: EdgeInsetsGeometry.lerp(weekdayPadding, other.weekdayPadding, t)!,
      weekdayTextStyle: TextStyle.lerp(weekdayTextStyle, other.weekdayTextStyle, t),
      weekdayColor: Color.lerp(weekdayColor, other.weekdayColor, t),
      weekendWeekdayColor: Color.lerp(weekendWeekdayColor, other.weekendWeekdayColor, t),
      weekendBackgroundColor: Color.lerp(weekendBackgroundColor, other.weekendBackgroundColor, t),
      weekendForegroundColor: Color.lerp(weekendForegroundColor, other.weekendForegroundColor, t),
      dayTextStyle: TextStyle.lerp(dayTextStyle, other.dayTextStyle, t),
      gregorianTextStyle: TextStyle.lerp(gregorianTextStyle, other.gregorianTextStyle, t),
      dayForegroundColor: Color.lerp(dayForegroundColor, other.dayForegroundColor, t),
      outsideDayForegroundColor: Color.lerp(outsideDayForegroundColor, other.outsideDayForegroundColor, t),
      disabledDayForegroundColor: Color.lerp(disabledDayForegroundColor, other.disabledDayForegroundColor, t),
      selectedDayForegroundColor: Color.lerp(selectedDayForegroundColor, other.selectedDayForegroundColor, t),
      selectedDayBackgroundColor: Color.lerp(selectedDayBackgroundColor, other.selectedDayBackgroundColor, t),
      rangeDayForegroundColor: Color.lerp(rangeDayForegroundColor, other.rangeDayForegroundColor, t),
      rangeDayBackgroundColor: Color.lerp(rangeDayBackgroundColor, other.rangeDayBackgroundColor, t),
      todayForegroundColor: Color.lerp(todayForegroundColor, other.todayForegroundColor, t),
      todayBackgroundColor: Color.lerp(todayBackgroundColor, other.todayBackgroundColor, t),
      todayBorderColor: Color.lerp(todayBorderColor, other.todayBorderColor, t),
      todayBorderWidth: mix(todayBorderWidth, other.todayBorderWidth),
      dayBorderColor: Color.lerp(dayBorderColor, other.dayBorderColor, t),
      dayBorderWidth: mix(dayBorderWidth, other.dayBorderWidth),
      dayOverlayColor: Color.lerp(dayOverlayColor, other.dayOverlayColor, t),
      selectedDayTextStyle: TextStyle.lerp(selectedDayTextStyle, other.selectedDayTextStyle, t),
      todayDayTextStyle: TextStyle.lerp(todayDayTextStyle, other.todayDayTextStyle, t),
      disabledDayTextStyle: TextStyle.lerp(disabledDayTextStyle, other.disabledDayTextStyle, t),
      outsideDayTextStyle: TextStyle.lerp(outsideDayTextStyle, other.outsideDayTextStyle, t),
      todayButtonTextStyle: TextStyle.lerp(todayButtonTextStyle, other.todayButtonTextStyle, t),
      todayButtonForegroundColor: Color.lerp(todayButtonForegroundColor, other.todayButtonForegroundColor, t),
      todayButtonBackgroundColor: Color.lerp(todayButtonBackgroundColor, other.todayButtonBackgroundColor, t),
      todayButtonPadding: EdgeInsetsGeometry.lerp(todayButtonPadding, other.todayButtonPadding, t)!,
      todayButtonAlignment: AlignmentGeometry.lerp(todayButtonAlignment, other.todayButtonAlignment, t)!,
    );
  }
}
