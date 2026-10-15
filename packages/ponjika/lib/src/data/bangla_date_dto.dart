import 'package:json_annotation/json_annotation.dart';
import '../date.dart';

part 'bangla_date_dto.g.dart';

/// Storage boundary. Domain validation occurs in [toDomain].
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
final class BanglaDateDto {
  const BanglaDateDto({
    required this.year,
    required this.month,
    required this.day,
    this.ruleset = 'bd-revised-2019-v1',
  });
  factory BanglaDateDto.fromJson(Map<String, Object?> json) =>
      _$BanglaDateDtoFromJson(json);
  factory BanglaDateDto.fromDomain(BanglaDate date) =>
      BanglaDateDto(year: date.year, month: date.month, day: date.day);
  @JsonKey(fromJson: _readInt)
  final int year;
  @JsonKey(fromJson: _readInt)
  final int month;
  @JsonKey(fromJson: _readInt)
  final int day;
  final String ruleset;
  Map<String, Object?> toJson() => _$BanglaDateDtoToJson(this);
  BanglaDate toDomain() {
    if (ruleset != 'bd-revised-2019-v1')
      throw FormatException('Unsupported calendar ruleset: $ruleset');
    return BanglaDate(year, month, day);
  }

  BanglaDateDto copyWith({int? year, int? month, int? day, String? ruleset}) =>
      BanglaDateDto(
        year: year ?? this.year,
        month: month ?? this.month,
        day: day ?? this.day,
        ruleset: ruleset ?? this.ruleset,
      );
}

int _readInt(Object? value) {
  if (value is! int)
    throw const FormatException('Expected an integer date component');
  return value;
}
