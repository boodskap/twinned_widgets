import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@unfreezed
class FontConfig with _$FontConfig {
  const factory FontConfig(
      {@Default(14) final double fontSize,
      @Default(0) final int fontColor,
      @Default(false) final bool fontBold}) = _FontConfig;

  factory FontConfig.fromJson(Map<String, Object?> json) =>
      _$FontConfigFromJson(json);
}

@unfreezed
class TotalValueWidgetConfig with _$TotalValueWidgetConfig {
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
}
