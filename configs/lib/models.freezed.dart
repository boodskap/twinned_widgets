// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FontConfig _$FontConfigFromJson(Map<String, dynamic> json) {
  return _FontConfig.fromJson(json);
}

/// @nodoc
mixin _$FontConfig {
  double get fontSize => throw _privateConstructorUsedError;
  int get fontColor => throw _privateConstructorUsedError;
  bool get fontBold => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FontConfigCopyWith<FontConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FontConfigCopyWith<$Res> {
  factory $FontConfigCopyWith(
          FontConfig value, $Res Function(FontConfig) then) =
      _$FontConfigCopyWithImpl<$Res, FontConfig>;
  @useResult
  $Res call({double fontSize, int fontColor, bool fontBold});
}

/// @nodoc
class _$FontConfigCopyWithImpl<$Res, $Val extends FontConfig>
    implements $FontConfigCopyWith<$Res> {
  _$FontConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fontSize = null,
    Object? fontColor = null,
    Object? fontBold = null,
  }) {
    return _then(_value.copyWith(
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      fontColor: null == fontColor
          ? _value.fontColor
          : fontColor // ignore: cast_nullable_to_non_nullable
              as int,
      fontBold: null == fontBold
          ? _value.fontBold
          : fontBold // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FontConfigImplCopyWith<$Res>
    implements $FontConfigCopyWith<$Res> {
  factory _$$FontConfigImplCopyWith(
          _$FontConfigImpl value, $Res Function(_$FontConfigImpl) then) =
      __$$FontConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double fontSize, int fontColor, bool fontBold});
}

/// @nodoc
class __$$FontConfigImplCopyWithImpl<$Res>
    extends _$FontConfigCopyWithImpl<$Res, _$FontConfigImpl>
    implements _$$FontConfigImplCopyWith<$Res> {
  __$$FontConfigImplCopyWithImpl(
      _$FontConfigImpl _value, $Res Function(_$FontConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fontSize = null,
    Object? fontColor = null,
    Object? fontBold = null,
  }) {
    return _then(_$FontConfigImpl(
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      fontColor: null == fontColor
          ? _value.fontColor
          : fontColor // ignore: cast_nullable_to_non_nullable
              as int,
      fontBold: null == fontBold
          ? _value.fontBold
          : fontBold // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FontConfigImpl implements _FontConfig {
  const _$FontConfigImpl(
      {this.fontSize = 14, this.fontColor = 0, this.fontBold = false});

  factory _$FontConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$FontConfigImplFromJson(json);

  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final int fontColor;
  @override
  @JsonKey()
  final bool fontBold;

  @override
  String toString() {
    return 'FontConfig(fontSize: $fontSize, fontColor: $fontColor, fontBold: $fontBold)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FontConfigImplCopyWith<_$FontConfigImpl> get copyWith =>
      __$$FontConfigImplCopyWithImpl<_$FontConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FontConfigImplToJson(
      this,
    );
  }
}

abstract class _FontConfig implements FontConfig {
  const factory _FontConfig(
      {final double fontSize,
      final int fontColor,
      final bool fontBold}) = _$FontConfigImpl;

  factory _FontConfig.fromJson(Map<String, dynamic> json) =
      _$FontConfigImpl.fromJson;

  @override
  double get fontSize;
  @override
  int get fontColor;
  @override
  bool get fontBold;
  @override
  @JsonKey(ignore: true)
  _$$FontConfigImplCopyWith<_$FontConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TotalValueWidgetConfig _$TotalValueWidgetConfigFromJson(
    Map<String, dynamic> json) {
  return _TotalValueWidgetConfig.fromJson(json);
}

/// @nodoc
mixin _$TotalValueWidgetConfig {
  String get title => throw _privateConstructorUsedError;
  set title(String value) => throw _privateConstructorUsedError;
  String get fieldPrefix => throw _privateConstructorUsedError;
  set fieldPrefix(String value) => throw _privateConstructorUsedError;
  String get fieldSuffix => throw _privateConstructorUsedError;
  set fieldSuffix(String value) => throw _privateConstructorUsedError;
  int get bgColor => throw _privateConstructorUsedError;
  set bgColor(int value) => throw _privateConstructorUsedError;
  int get borderColor => throw _privateConstructorUsedError;
  set borderColor(int value) => throw _privateConstructorUsedError;
  double get borderWidth => throw _privateConstructorUsedError;
  set borderWidth(double value) => throw _privateConstructorUsedError;
  double get borderRadius => throw _privateConstructorUsedError;
  set borderRadius(double value) => throw _privateConstructorUsedError;
  BorderStyle get borderStyle => throw _privateConstructorUsedError;
  set borderStyle(BorderStyle value) => throw _privateConstructorUsedError;
  FontConfig get headerFont => throw _privateConstructorUsedError;
  set headerFont(FontConfig value) => throw _privateConstructorUsedError;
  FontConfig get labelFont => throw _privateConstructorUsedError;
  set labelFont(FontConfig value) => throw _privateConstructorUsedError;
  String get field => throw _privateConstructorUsedError;
  set field(String value) => throw _privateConstructorUsedError;
  List<String> get modelIds => throw _privateConstructorUsedError;
  set modelIds(List<String> value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TotalValueWidgetConfigCopyWith<TotalValueWidgetConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TotalValueWidgetConfigCopyWith<$Res> {
  factory $TotalValueWidgetConfigCopyWith(TotalValueWidgetConfig value,
          $Res Function(TotalValueWidgetConfig) then) =
      _$TotalValueWidgetConfigCopyWithImpl<$Res, TotalValueWidgetConfig>;
  @useResult
  $Res call(
      {String title,
      String fieldPrefix,
      String fieldSuffix,
      int bgColor,
      int borderColor,
      double borderWidth,
      double borderRadius,
      BorderStyle borderStyle,
      FontConfig headerFont,
      FontConfig labelFont,
      String field,
      List<String> modelIds});

  $FontConfigCopyWith<$Res> get headerFont;
  $FontConfigCopyWith<$Res> get labelFont;
}

/// @nodoc
class _$TotalValueWidgetConfigCopyWithImpl<$Res,
        $Val extends TotalValueWidgetConfig>
    implements $TotalValueWidgetConfigCopyWith<$Res> {
  _$TotalValueWidgetConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? fieldPrefix = null,
    Object? fieldSuffix = null,
    Object? bgColor = null,
    Object? borderColor = null,
    Object? borderWidth = null,
    Object? borderRadius = null,
    Object? borderStyle = null,
    Object? headerFont = null,
    Object? labelFont = null,
    Object? field = null,
    Object? modelIds = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      fieldPrefix: null == fieldPrefix
          ? _value.fieldPrefix
          : fieldPrefix // ignore: cast_nullable_to_non_nullable
              as String,
      fieldSuffix: null == fieldSuffix
          ? _value.fieldSuffix
          : fieldSuffix // ignore: cast_nullable_to_non_nullable
              as String,
      bgColor: null == bgColor
          ? _value.bgColor
          : bgColor // ignore: cast_nullable_to_non_nullable
              as int,
      borderColor: null == borderColor
          ? _value.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as int,
      borderWidth: null == borderWidth
          ? _value.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      borderRadius: null == borderRadius
          ? _value.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      borderStyle: null == borderStyle
          ? _value.borderStyle
          : borderStyle // ignore: cast_nullable_to_non_nullable
              as BorderStyle,
      headerFont: null == headerFont
          ? _value.headerFont
          : headerFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      labelFont: null == labelFont
          ? _value.labelFont
          : labelFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      modelIds: null == modelIds
          ? _value.modelIds
          : modelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $FontConfigCopyWith<$Res> get headerFont {
    return $FontConfigCopyWith<$Res>(_value.headerFont, (value) {
      return _then(_value.copyWith(headerFont: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $FontConfigCopyWith<$Res> get labelFont {
    return $FontConfigCopyWith<$Res>(_value.labelFont, (value) {
      return _then(_value.copyWith(labelFont: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TotalValueWidgetConfigImplCopyWith<$Res>
    implements $TotalValueWidgetConfigCopyWith<$Res> {
  factory _$$TotalValueWidgetConfigImplCopyWith(
          _$TotalValueWidgetConfigImpl value,
          $Res Function(_$TotalValueWidgetConfigImpl) then) =
      __$$TotalValueWidgetConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String fieldPrefix,
      String fieldSuffix,
      int bgColor,
      int borderColor,
      double borderWidth,
      double borderRadius,
      BorderStyle borderStyle,
      FontConfig headerFont,
      FontConfig labelFont,
      String field,
      List<String> modelIds});

  @override
  $FontConfigCopyWith<$Res> get headerFont;
  @override
  $FontConfigCopyWith<$Res> get labelFont;
}

/// @nodoc
class __$$TotalValueWidgetConfigImplCopyWithImpl<$Res>
    extends _$TotalValueWidgetConfigCopyWithImpl<$Res,
        _$TotalValueWidgetConfigImpl>
    implements _$$TotalValueWidgetConfigImplCopyWith<$Res> {
  __$$TotalValueWidgetConfigImplCopyWithImpl(
      _$TotalValueWidgetConfigImpl _value,
      $Res Function(_$TotalValueWidgetConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? fieldPrefix = null,
    Object? fieldSuffix = null,
    Object? bgColor = null,
    Object? borderColor = null,
    Object? borderWidth = null,
    Object? borderRadius = null,
    Object? borderStyle = null,
    Object? headerFont = null,
    Object? labelFont = null,
    Object? field = null,
    Object? modelIds = null,
  }) {
    return _then(_$TotalValueWidgetConfigImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      fieldPrefix: null == fieldPrefix
          ? _value.fieldPrefix
          : fieldPrefix // ignore: cast_nullable_to_non_nullable
              as String,
      fieldSuffix: null == fieldSuffix
          ? _value.fieldSuffix
          : fieldSuffix // ignore: cast_nullable_to_non_nullable
              as String,
      bgColor: null == bgColor
          ? _value.bgColor
          : bgColor // ignore: cast_nullable_to_non_nullable
              as int,
      borderColor: null == borderColor
          ? _value.borderColor
          : borderColor // ignore: cast_nullable_to_non_nullable
              as int,
      borderWidth: null == borderWidth
          ? _value.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      borderRadius: null == borderRadius
          ? _value.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      borderStyle: null == borderStyle
          ? _value.borderStyle
          : borderStyle // ignore: cast_nullable_to_non_nullable
              as BorderStyle,
      headerFont: null == headerFont
          ? _value.headerFont
          : headerFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      labelFont: null == labelFont
          ? _value.labelFont
          : labelFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      modelIds: null == modelIds
          ? _value.modelIds
          : modelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TotalValueWidgetConfigImpl implements _TotalValueWidgetConfig {
  _$TotalValueWidgetConfigImpl(
      {this.title = 'Total',
      this.fieldPrefix = '',
      this.fieldSuffix = '',
      this.bgColor = 0xFFFFFFFF,
      this.borderColor = 0xFFFFFFFF,
      this.borderWidth = 2.0,
      this.borderRadius = 0.0,
      this.borderStyle = BorderStyle.solid,
      this.headerFont = const FontConfig(fontSize: 20, fontBold: true),
      this.labelFont = const FontConfig(),
      this.field = '',
      this.modelIds = const []});

  factory _$TotalValueWidgetConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$TotalValueWidgetConfigImplFromJson(json);

  @override
  @JsonKey()
  String title;
  @override
  @JsonKey()
  String fieldPrefix;
  @override
  @JsonKey()
  String fieldSuffix;
  @override
  @JsonKey()
  int bgColor;
  @override
  @JsonKey()
  int borderColor;
  @override
  @JsonKey()
  double borderWidth;
  @override
  @JsonKey()
  double borderRadius;
  @override
  @JsonKey()
  BorderStyle borderStyle;
  @override
  @JsonKey()
  FontConfig headerFont;
  @override
  @JsonKey()
  FontConfig labelFont;
  @override
  @JsonKey()
  String field;
  @override
  @JsonKey()
  List<String> modelIds;

  @override
  String toString() {
    return 'TotalValueWidgetConfig(title: $title, fieldPrefix: $fieldPrefix, fieldSuffix: $fieldSuffix, bgColor: $bgColor, borderColor: $borderColor, borderWidth: $borderWidth, borderRadius: $borderRadius, borderStyle: $borderStyle, headerFont: $headerFont, labelFont: $labelFont, field: $field, modelIds: $modelIds)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TotalValueWidgetConfigImplCopyWith<_$TotalValueWidgetConfigImpl>
      get copyWith => __$$TotalValueWidgetConfigImplCopyWithImpl<
          _$TotalValueWidgetConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TotalValueWidgetConfigImplToJson(
      this,
    );
  }
}

abstract class _TotalValueWidgetConfig implements TotalValueWidgetConfig {
  factory _TotalValueWidgetConfig(
      {String title,
      String fieldPrefix,
      String fieldSuffix,
      int bgColor,
      int borderColor,
      double borderWidth,
      double borderRadius,
      BorderStyle borderStyle,
      FontConfig headerFont,
      FontConfig labelFont,
      String field,
      List<String> modelIds}) = _$TotalValueWidgetConfigImpl;

  factory _TotalValueWidgetConfig.fromJson(Map<String, dynamic> json) =
      _$TotalValueWidgetConfigImpl.fromJson;

  @override
  String get title;
  set title(String value);
  @override
  String get fieldPrefix;
  set fieldPrefix(String value);
  @override
  String get fieldSuffix;
  set fieldSuffix(String value);
  @override
  int get bgColor;
  set bgColor(int value);
  @override
  int get borderColor;
  set borderColor(int value);
  @override
  double get borderWidth;
  set borderWidth(double value);
  @override
  double get borderRadius;
  set borderRadius(double value);
  @override
  BorderStyle get borderStyle;
  set borderStyle(BorderStyle value);
  @override
  FontConfig get headerFont;
  set headerFont(FontConfig value);
  @override
  FontConfig get labelFont;
  set labelFont(FontConfig value);
  @override
  String get field;
  set field(String value);
  @override
  List<String> get modelIds;
  set modelIds(List<String> value);
  @override
  @JsonKey(ignore: true)
  _$$TotalValueWidgetConfigImplCopyWith<_$TotalValueWidgetConfigImpl>
      get copyWith => throw _privateConstructorUsedError;
}
