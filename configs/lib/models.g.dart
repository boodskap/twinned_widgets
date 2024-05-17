// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FontConfigImpl _$$FontConfigImplFromJson(Map<String, dynamic> json) =>
    _$FontConfigImpl(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14,
      fontColor: (json['fontColor'] as num?)?.toInt() ?? 0,
      fontBold: json['fontBold'] as bool? ?? false,
    );

Map<String, dynamic> _$$FontConfigImplToJson(_$FontConfigImpl instance) =>
    <String, dynamic>{
      'fontSize': instance.fontSize,
      'fontColor': instance.fontColor,
      'fontBold': instance.fontBold,
    };

_$TotalValueWidgetConfigImpl _$$TotalValueWidgetConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$TotalValueWidgetConfigImpl(
      title: json['title'] as String? ?? 'Total',
      fieldPrefix: json['fieldPrefix'] as String? ?? '',
      fieldSuffix: json['fieldSuffix'] as String? ?? '',
      bgColor: (json['bgColor'] as num?)?.toInt() ?? 0xFFFFFFFF,
      borderColor: (json['borderColor'] as num?)?.toInt() ?? 0xFFFFFFFF,
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 2.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.0,
      borderStyle:
          $enumDecodeNullable(_$BorderStyleEnumMap, json['borderStyle']) ??
              BorderStyle.solid,
      headerFont: json['headerFont'] == null
          ? const FontConfig(fontSize: 20, fontBold: true)
          : FontConfig.fromJson(json['headerFont'] as Map<String, dynamic>),
      labelFont: json['labelFont'] == null
          ? const FontConfig()
          : FontConfig.fromJson(json['labelFont'] as Map<String, dynamic>),
      field: json['field'] as String? ?? '',
      modelIds: (json['modelIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TotalValueWidgetConfigImplToJson(
        _$TotalValueWidgetConfigImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'fieldPrefix': instance.fieldPrefix,
      'fieldSuffix': instance.fieldSuffix,
      'bgColor': instance.bgColor,
      'borderColor': instance.borderColor,
      'borderWidth': instance.borderWidth,
      'borderRadius': instance.borderRadius,
      'borderStyle': _$BorderStyleEnumMap[instance.borderStyle]!,
      'headerFont': instance.headerFont,
      'labelFont': instance.labelFont,
      'field': instance.field,
      'modelIds': instance.modelIds,
    };

const _$BorderStyleEnumMap = {
  BorderStyle.none: 'none',
  BorderStyle.solid: 'solid',
};
