// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExampleImpl _$$ExampleImplFromJson(Map<String, dynamic> json) =>
    _$ExampleImpl(
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
    );

Map<String, dynamic> _$$ExampleImplToJson(_$ExampleImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
    };

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

_$RangeImpl _$$RangeImplFromJson(Map<String, dynamic> json) => _$RangeImpl(
      from: (json['from'] as num?)?.toDouble(),
      to: (json['to'] as num?)?.toDouble(),
      color: (json['color'] as num?)?.toInt(),
      label: json['label'] as String? ?? 'Label',
    );

Map<String, dynamic> _$$RangeImplToJson(_$RangeImpl instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'color': instance.color,
      'label': instance.label,
    };

_$ValueDistributionPieChartWidgetConfigImpl
    _$$ValueDistributionPieChartWidgetConfigImplFromJson(
            Map<String, dynamic> json) =>
        _$ValueDistributionPieChartWidgetConfigImpl(
          title: json['title'] as String? ?? 'Title',
          headerFont: json['headerFont'] == null
              ? const FontConfig(fontSize: 20, fontBold: true)
              : FontConfig.fromJson(json['headerFont'] as Map<String, dynamic>),
          labelFont: json['labelFont'] == null
              ? const FontConfig()
              : FontConfig.fromJson(json['labelFont'] as Map<String, dynamic>),
          type: $enumDecodeNullable(
                  _$DistributionChartTypeEnumMap, json['type']) ??
              DistributionChartType.pie,
          field: json['field'] as String? ?? '',
          modelIds: (json['modelIds'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
          segments: (json['segments'] as List<dynamic>?)
                  ?.map((e) => Range.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [
                Range(from: 0, to: 25, color: 0xFFFFFFFF),
                Range(from: 26, to: 50, color: 0xFFFFFFFF),
                Range(from: 51, to: 75, color: 0xFFFFFFFF),
                Range(from: 76, to: 100, color: 0xFFFFFFFF)
              ],
        );

Map<String, dynamic> _$$ValueDistributionPieChartWidgetConfigImplToJson(
        _$ValueDistributionPieChartWidgetConfigImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'headerFont': instance.headerFont,
      'labelFont': instance.labelFont,
      'type': _$DistributionChartTypeEnumMap[instance.type]!,
      'field': instance.field,
      'modelIds': instance.modelIds,
      'segments': instance.segments,
    };

const _$DistributionChartTypeEnumMap = {
  DistributionChartType.pie: 'pie',
  DistributionChartType.doughnut: 'doughnut',
  DistributionChartType.radial: 'radial',
  DistributionChartType.pyramid: 'pyramid',
  DistributionChartType.funnel: 'funnel',
};

_$TotalAndReportingAssetWidgetConfigImpl
    _$$TotalAndReportingAssetWidgetConfigImplFromJson(
            Map<String, dynamic> json) =>
        _$TotalAndReportingAssetWidgetConfigImpl(
          title: json['title'] as String? ?? 'Title',
          headerFont: json['headerFont'] == null
              ? const FontConfig(fontSize: 20, fontBold: true)
              : FontConfig.fromJson(json['headerFont'] as Map<String, dynamic>),
          labelFont: json['labelFont'] == null
              ? const FontConfig()
              : FontConfig.fromJson(json['labelFont'] as Map<String, dynamic>),
          assetModelIds: (json['assetModelIds'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
        );

Map<String, dynamic> _$$TotalAndReportingAssetWidgetConfigImplToJson(
        _$TotalAndReportingAssetWidgetConfigImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'headerFont': instance.headerFont,
      'labelFont': instance.labelFont,
      'assetModelIds': instance.assetModelIds,
    };
