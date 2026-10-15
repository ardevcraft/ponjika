// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangla_date_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BanglaDateDto _$BanglaDateDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BanglaDateDto', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['year', 'month', 'day', 'ruleset']);
      final val = BanglaDateDto(
        year: $checkedConvert('year', (v) => _readInt(v)),
        month: $checkedConvert('month', (v) => _readInt(v)),
        day: $checkedConvert('day', (v) => _readInt(v)),
        ruleset: $checkedConvert(
          'ruleset',
          (v) => v as String? ?? 'bd-revised-2019-v1',
        ),
      );
      return val;
    });

Map<String, dynamic> _$BanglaDateDtoToJson(BanglaDateDto instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
      'ruleset': instance.ruleset,
    };
