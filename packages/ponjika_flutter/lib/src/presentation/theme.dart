import 'package:flutter/material.dart';

/// Layout tokens. Colors and typography come from the ambient Material theme.
@immutable
class PonjikaCalendarTheme extends ThemeExtension<PonjikaCalendarTheme> {
  const PonjikaCalendarTheme({
    this.spacing = 8,
    this.contentPadding = 12,
    this.cellHeight = 60,
    this.cornerRadius = 16,
    this.maximumWidth = 440,
  });
  final double spacing;
  final double contentPadding;
  final double cellHeight;
  final double cornerRadius;
  final double maximumWidth;
  static PonjikaCalendarTheme of(BuildContext context) =>
      Theme.of(context).extension<PonjikaCalendarTheme>() ??
      const PonjikaCalendarTheme();
  @override
  PonjikaCalendarTheme copyWith({
    double? spacing,
    double? contentPadding,
    double? cellHeight,
    double? cornerRadius,
    double? maximumWidth,
  }) => PonjikaCalendarTheme(
    spacing: spacing ?? this.spacing,
    contentPadding: contentPadding ?? this.contentPadding,
    cellHeight: cellHeight ?? this.cellHeight,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    maximumWidth: maximumWidth ?? this.maximumWidth,
  );
  @override
  PonjikaCalendarTheme lerp(covariant PonjikaCalendarTheme? other, double t) {
    if (other == null) return this;
    double mix(double a, double b) => a + (b - a) * t;
    return PonjikaCalendarTheme(
      spacing: mix(spacing, other.spacing),
      contentPadding: mix(contentPadding, other.contentPadding),
      cellHeight: mix(cellHeight, other.cellHeight),
      cornerRadius: mix(cornerRadius, other.cornerRadius),
      maximumWidth: mix(maximumWidth, other.maximumWidth),
    );
  }
}
