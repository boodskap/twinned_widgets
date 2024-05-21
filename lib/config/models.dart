import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

enum DataType {
  numeric,
  decimal,
  text,
  yesno,
  enumerated,
  font,
  listOfTexts,
  listOfNumbers,
  listOfDecimals,
  listOfObjects,
}

enum HintType {
  none,
  color,
  field,
  modelId,
  range,
  assetModelId,
}

abstract class BaseConfig {
  const BaseConfig();

  DataType getDataType(String parameter);

  HintType getHintType(String parameter) {
    return HintType.none;
  }

  List<String> getEnumeratedValues(String parameter) {
    return [];
  }

  bool isRequired(String parameter) {
    return false;
  }

  bool isValid(String parameter, dynamic value) {
    return true;
  }
}

@unfreezed
class Example extends BaseConfig with _$Example {
  Example._();

  factory Example({required String name, required int age}) = _Example;

  factory Example.fromJson(Map<String, Object?> json) =>
      _$ExampleFromJson(json);

  @override
  DataType getDataType(String parameter) {
    switch (parameter) {
      case 'name':
        return DataType.text;
      case 'age':
        return DataType.numeric;
      default:
        return DataType.text;
    }
  }

  @override
  HintType getHintType(String parameter) {
    return HintType.none;
  }
}

@unfreezed
class FontConfig with _$FontConfig {
  const FontConfig._();

  const factory FontConfig(
      {@Default(14) final double fontSize,
      @Default(0) final int fontColor,
      @Default(false) final bool fontBold}) = _FontConfig;

  factory FontConfig.fromJson(Map<String, Object?> json) =>
      _$FontConfigFromJson(json);
}

@unfreezed
class TotalValueWidgetConfig extends BaseConfig with _$TotalValueWidgetConfig {
  TotalValueWidgetConfig._();

  factory TotalValueWidgetConfig({
    @Default('Total') String title,
    @Default('') String fieldPrefix,
    @Default('') String fieldSuffix,
    @Default(0xFFFFFFFF) int bgColor,
    @Default(0xFFFFFFFF) int borderColor,
    @Default(2.0) double borderWidth,
    @Default(0.0) double borderRadius,
    @Default(BorderStyle.solid) BorderStyle borderStyle,
    @Default(FontConfig(fontSize: 20, fontBold: true)) FontConfig headerFont,
    @Default(FontConfig()) FontConfig labelFont,
    @Default('') String field,
    @Default([]) List<String> modelIds,
  }) = _TotalValueWidgetConfig;

  factory TotalValueWidgetConfig.fromJson(Map<String, Object?> json) =>
      _$TotalValueWidgetConfigFromJson(json);

  @override
  DataType getDataType(String parameter) {
    switch (parameter) {
      case 'bgColor':
      case 'borderColor':
        return DataType.numeric;
      case 'borderWidth':
      case 'borderRadius':
        return DataType.decimal;
      case 'borderStyle':
        return DataType.enumerated;
      case 'headerFont':
      case 'labelFont':
        return DataType.font;
      case 'modelIds':
        return DataType.listOfTexts;
      default:
        return DataType.text;
    }
  }

  @override
  HintType getHintType(String parameter) {
    switch (parameter) {
      case 'bgColor':
      case 'borderColor':
        return HintType.color;
      case 'modelIds':
        return HintType.modelId;
      case 'field':
        return HintType.field;
    }

    return HintType.none;
  }

  @override
  List<String> getEnumeratedValues(String parameter) {
    switch (parameter) {
      case 'borderStyle':
        return BorderStyle.values.asNameMap().keys.toList();
    }
    return [];
  }

  @override
  bool isRequired(String parameter) {
    switch (parameter) {
      case 'modelIds':
      case 'field':
        return true;
      default:
        return false;
    }
  }
}

@unfreezed
class Range with _$Range {
  const Range._();

  const factory Range(
      {final double? from,
      final double? to,
      final int? color,
      @Default('Label') final String label}) = _Range;

  factory Range.fromJson(Map<String, Object?> json) => _$RangeFromJson(json);
}

enum DistributionChartType { pie, doughnut, radial, pyramid, funnel }

@unfreezed
class ValueDistributionPieChartWidgetConfig extends BaseConfig
    with _$ValueDistributionPieChartWidgetConfig {
  ValueDistributionPieChartWidgetConfig._();

  factory ValueDistributionPieChartWidgetConfig({
    @Default('Title') String title,
    @Default(FontConfig(fontSize: 20, fontBold: true)) FontConfig headerFont,
    @Default(FontConfig()) FontConfig labelFont,
    @Default(DistributionChartType.pie) DistributionChartType type,
    @Default('') String field,
    @Default([]) List<String> modelIds,
    @Default([
      Range(from: 0, to: 25, color: 0xFFFFFFFF),
      Range(from: 26, to: 50, color: 0xFFFFFFFF),
      Range(from: 51, to: 75, color: 0xFFFFFFFF),
      Range(from: 76, to: 100, color: 0xFFFFFFFF),
    ])
    List<Range> segments,
  }) = _ValueDistributionPieChartWidgetConfig;

  factory ValueDistributionPieChartWidgetConfig.fromJson(
          Map<String, Object?> json) =>
      _$ValueDistributionPieChartWidgetConfigFromJson(json);

  @override
  DataType getDataType(String parameter) {
    switch (parameter) {
      case 'headerFont':
      case 'labelFont':
        return DataType.font;
      case 'type':
        return DataType.enumerated;
      case 'modelIds':
        return DataType.listOfTexts;
      case 'segments':
        return DataType.listOfObjects;
      default:
        return DataType.text;
    }
  }

  @override
  HintType getHintType(String parameter) {
    switch (parameter) {
      case 'modelIds':
        return HintType.modelId;
      case 'field':
        return HintType.field;
      case 'segments':
        return HintType.range;
    }

    return HintType.none;
  }

  @override
  List<String> getEnumeratedValues(String parameter) {
    switch (parameter) {
      case 'type':
        return DistributionChartType.values.asNameMap().keys.toList();
    }
    return [];
  }

  @override
  bool isRequired(String parameter) {
    switch (parameter) {
      case 'modelIds':
      case 'field':
      case 'segments':
        return true;
      default:
        return false;
    }
  }
}

@unfreezed
class TotalAndReportingAssetWidgetConfig extends BaseConfig
    with _$TotalAndReportingAssetWidgetConfig {
  TotalAndReportingAssetWidgetConfig._();

  factory TotalAndReportingAssetWidgetConfig({
    @Default('Title') String title,
    @Default(FontConfig(fontSize: 20, fontBold: true)) FontConfig headerFont,
    @Default(FontConfig()) FontConfig labelFont,
    @Default([]) List<String> assetModelIds,
  }) = _TotalAndReportingAssetWidgetConfig;

  factory TotalAndReportingAssetWidgetConfig.fromJson(
          Map<String, Object?> json) =>
      _$TotalAndReportingAssetWidgetConfigFromJson(json);

  @override
  DataType getDataType(String parameter) {
    switch (parameter) {
      case 'headerFont':
      case 'labelFont':
        return DataType.font;
      case 'assetModelIds':
        return DataType.listOfTexts;
      default:
        return DataType.text;
    }
  }

  @override
  HintType getHintType(String parameter) {
    switch (parameter) {
      case 'assetModelIds':
        return HintType.assetModelId;
    }

    return HintType.none;
  }

  @override
  bool isRequired(String parameter) {
    switch (parameter) {
      case 'assetModelIds':
        return true;
      default:
        return false;
    }
  }
}
