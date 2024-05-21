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

Example _$ExampleFromJson(Map<String, dynamic> json) {
  return _Example.fromJson(json);
}

/// @nodoc
mixin _$Example {
  String get name => throw _privateConstructorUsedError;
  set name(String value) => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  set age(int value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExampleCopyWith<Example> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExampleCopyWith<$Res> {
  factory $ExampleCopyWith(Example value, $Res Function(Example) then) =
      _$ExampleCopyWithImpl<$Res, Example>;
  @useResult
  $Res call({String name, int age});
}

/// @nodoc
class _$ExampleCopyWithImpl<$Res, $Val extends Example>
    implements $ExampleCopyWith<$Res> {
  _$ExampleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? age = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExampleImplCopyWith<$Res> implements $ExampleCopyWith<$Res> {
  factory _$$ExampleImplCopyWith(
          _$ExampleImpl value, $Res Function(_$ExampleImpl) then) =
      __$$ExampleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int age});
}

/// @nodoc
class __$$ExampleImplCopyWithImpl<$Res>
    extends _$ExampleCopyWithImpl<$Res, _$ExampleImpl>
    implements _$$ExampleImplCopyWith<$Res> {
  __$$ExampleImplCopyWithImpl(
      _$ExampleImpl _value, $Res Function(_$ExampleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? age = null,
  }) {
    return _then(_$ExampleImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExampleImpl extends _Example {
  _$ExampleImpl({required this.name, required this.age}) : super._();

  factory _$ExampleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExampleImplFromJson(json);

  @override
  String name;
  @override
  int age;

  @override
  String toString() {
    return 'Example(name: $name, age: $age)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExampleImplCopyWith<_$ExampleImpl> get copyWith =>
      __$$ExampleImplCopyWithImpl<_$ExampleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExampleImplToJson(
      this,
    );
  }
}

abstract class _Example extends Example {
  factory _Example({required String name, required int age}) = _$ExampleImpl;
  _Example._() : super._();

  factory _Example.fromJson(Map<String, dynamic> json) = _$ExampleImpl.fromJson;

  @override
  String get name;
  set name(String value);
  @override
  int get age;
  set age(int value);
  @override
  @JsonKey(ignore: true)
  _$$ExampleImplCopyWith<_$ExampleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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
class _$FontConfigImpl extends _FontConfig {
  const _$FontConfigImpl(
      {this.fontSize = 14, this.fontColor = 0, this.fontBold = false})
      : super._();

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

abstract class _FontConfig extends FontConfig {
  const factory _FontConfig(
      {final double fontSize,
      final int fontColor,
      final bool fontBold}) = _$FontConfigImpl;
  const _FontConfig._() : super._();

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
class _$TotalValueWidgetConfigImpl extends _TotalValueWidgetConfig {
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
      this.modelIds = const []})
      : super._();

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

abstract class _TotalValueWidgetConfig extends TotalValueWidgetConfig {
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
  _TotalValueWidgetConfig._() : super._();

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

Range _$RangeFromJson(Map<String, dynamic> json) {
  return _Range.fromJson(json);
}

/// @nodoc
mixin _$Range {
  double? get from => throw _privateConstructorUsedError;
  double? get to => throw _privateConstructorUsedError;
  int? get color => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RangeCopyWith<Range> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RangeCopyWith<$Res> {
  factory $RangeCopyWith(Range value, $Res Function(Range) then) =
      _$RangeCopyWithImpl<$Res, Range>;
  @useResult
  $Res call({double? from, double? to, int? color, String label});
}

/// @nodoc
class _$RangeCopyWithImpl<$Res, $Val extends Range>
    implements $RangeCopyWith<$Res> {
  _$RangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? color = freezed,
    Object? label = null,
  }) {
    return _then(_value.copyWith(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as double?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as double?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as int?,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RangeImplCopyWith<$Res> implements $RangeCopyWith<$Res> {
  factory _$$RangeImplCopyWith(
          _$RangeImpl value, $Res Function(_$RangeImpl) then) =
      __$$RangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? from, double? to, int? color, String label});
}

/// @nodoc
class __$$RangeImplCopyWithImpl<$Res>
    extends _$RangeCopyWithImpl<$Res, _$RangeImpl>
    implements _$$RangeImplCopyWith<$Res> {
  __$$RangeImplCopyWithImpl(
      _$RangeImpl _value, $Res Function(_$RangeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = freezed,
    Object? to = freezed,
    Object? color = freezed,
    Object? label = null,
  }) {
    return _then(_$RangeImpl(
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as double?,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as double?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as int?,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RangeImpl extends _Range {
  const _$RangeImpl({this.from, this.to, this.color, this.label = 'Label'})
      : super._();

  factory _$RangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RangeImplFromJson(json);

  @override
  final double? from;
  @override
  final double? to;
  @override
  final int? color;
  @override
  @JsonKey()
  final String label;

  @override
  String toString() {
    return 'Range(from: $from, to: $to, color: $color, label: $label)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RangeImplCopyWith<_$RangeImpl> get copyWith =>
      __$$RangeImplCopyWithImpl<_$RangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RangeImplToJson(
      this,
    );
  }
}

abstract class _Range extends Range {
  const factory _Range(
      {final double? from,
      final double? to,
      final int? color,
      final String label}) = _$RangeImpl;
  const _Range._() : super._();

  factory _Range.fromJson(Map<String, dynamic> json) = _$RangeImpl.fromJson;

  @override
  double? get from;
  @override
  double? get to;
  @override
  int? get color;
  @override
  String get label;
  @override
  @JsonKey(ignore: true)
  _$$RangeImplCopyWith<_$RangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ValueDistributionPieChartWidgetConfig
    _$ValueDistributionPieChartWidgetConfigFromJson(Map<String, dynamic> json) {
  return _ValueDistributionPieChartWidgetConfig.fromJson(json);
}

/// @nodoc
mixin _$ValueDistributionPieChartWidgetConfig {
  String get title => throw _privateConstructorUsedError;
  set title(String value) => throw _privateConstructorUsedError;
  FontConfig get headerFont => throw _privateConstructorUsedError;
  set headerFont(FontConfig value) => throw _privateConstructorUsedError;
  FontConfig get labelFont => throw _privateConstructorUsedError;
  set labelFont(FontConfig value) => throw _privateConstructorUsedError;
  DistributionChartType get type => throw _privateConstructorUsedError;
  set type(DistributionChartType value) => throw _privateConstructorUsedError;
  String get field => throw _privateConstructorUsedError;
  set field(String value) => throw _privateConstructorUsedError;
  List<String> get modelIds => throw _privateConstructorUsedError;
  set modelIds(List<String> value) => throw _privateConstructorUsedError;
  List<Range> get segments => throw _privateConstructorUsedError;
  set segments(List<Range> value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ValueDistributionPieChartWidgetConfigCopyWith<
          ValueDistributionPieChartWidgetConfig>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValueDistributionPieChartWidgetConfigCopyWith<$Res> {
  factory $ValueDistributionPieChartWidgetConfigCopyWith(
          ValueDistributionPieChartWidgetConfig value,
          $Res Function(ValueDistributionPieChartWidgetConfig) then) =
      _$ValueDistributionPieChartWidgetConfigCopyWithImpl<$Res,
          ValueDistributionPieChartWidgetConfig>;
  @useResult
  $Res call(
      {String title,
      FontConfig headerFont,
      FontConfig labelFont,
      DistributionChartType type,
      String field,
      List<String> modelIds,
      List<Range> segments});

  $FontConfigCopyWith<$Res> get headerFont;
  $FontConfigCopyWith<$Res> get labelFont;
}

/// @nodoc
class _$ValueDistributionPieChartWidgetConfigCopyWithImpl<$Res,
        $Val extends ValueDistributionPieChartWidgetConfig>
    implements $ValueDistributionPieChartWidgetConfigCopyWith<$Res> {
  _$ValueDistributionPieChartWidgetConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? headerFont = null,
    Object? labelFont = null,
    Object? type = null,
    Object? field = null,
    Object? modelIds = null,
    Object? segments = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      headerFont: null == headerFont
          ? _value.headerFont
          : headerFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      labelFont: null == labelFont
          ? _value.labelFont
          : labelFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DistributionChartType,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      modelIds: null == modelIds
          ? _value.modelIds
          : modelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      segments: null == segments
          ? _value.segments
          : segments // ignore: cast_nullable_to_non_nullable
              as List<Range>,
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
abstract class _$$ValueDistributionPieChartWidgetConfigImplCopyWith<$Res>
    implements $ValueDistributionPieChartWidgetConfigCopyWith<$Res> {
  factory _$$ValueDistributionPieChartWidgetConfigImplCopyWith(
          _$ValueDistributionPieChartWidgetConfigImpl value,
          $Res Function(_$ValueDistributionPieChartWidgetConfigImpl) then) =
      __$$ValueDistributionPieChartWidgetConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      FontConfig headerFont,
      FontConfig labelFont,
      DistributionChartType type,
      String field,
      List<String> modelIds,
      List<Range> segments});

  @override
  $FontConfigCopyWith<$Res> get headerFont;
  @override
  $FontConfigCopyWith<$Res> get labelFont;
}

/// @nodoc
class __$$ValueDistributionPieChartWidgetConfigImplCopyWithImpl<$Res>
    extends _$ValueDistributionPieChartWidgetConfigCopyWithImpl<$Res,
        _$ValueDistributionPieChartWidgetConfigImpl>
    implements _$$ValueDistributionPieChartWidgetConfigImplCopyWith<$Res> {
  __$$ValueDistributionPieChartWidgetConfigImplCopyWithImpl(
      _$ValueDistributionPieChartWidgetConfigImpl _value,
      $Res Function(_$ValueDistributionPieChartWidgetConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? headerFont = null,
    Object? labelFont = null,
    Object? type = null,
    Object? field = null,
    Object? modelIds = null,
    Object? segments = null,
  }) {
    return _then(_$ValueDistributionPieChartWidgetConfigImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      headerFont: null == headerFont
          ? _value.headerFont
          : headerFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      labelFont: null == labelFont
          ? _value.labelFont
          : labelFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DistributionChartType,
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String,
      modelIds: null == modelIds
          ? _value.modelIds
          : modelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      segments: null == segments
          ? _value.segments
          : segments // ignore: cast_nullable_to_non_nullable
              as List<Range>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValueDistributionPieChartWidgetConfigImpl
    extends _ValueDistributionPieChartWidgetConfig {
  _$ValueDistributionPieChartWidgetConfigImpl(
      {this.title = 'Title',
      this.headerFont = const FontConfig(fontSize: 20, fontBold: true),
      this.labelFont = const FontConfig(),
      this.type = DistributionChartType.pie,
      this.field = '',
      this.modelIds = const [],
      this.segments = const [
        Range(from: 0, to: 25, color: 0xFFFFFFFF),
        Range(from: 26, to: 50, color: 0xFFFFFFFF),
        Range(from: 51, to: 75, color: 0xFFFFFFFF),
        Range(from: 76, to: 100, color: 0xFFFFFFFF)
      ]})
      : super._();

  factory _$ValueDistributionPieChartWidgetConfigImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ValueDistributionPieChartWidgetConfigImplFromJson(json);

  @override
  @JsonKey()
  String title;
  @override
  @JsonKey()
  FontConfig headerFont;
  @override
  @JsonKey()
  FontConfig labelFont;
  @override
  @JsonKey()
  DistributionChartType type;
  @override
  @JsonKey()
  String field;
  @override
  @JsonKey()
  List<String> modelIds;
  @override
  @JsonKey()
  List<Range> segments;

  @override
  String toString() {
    return 'ValueDistributionPieChartWidgetConfig(title: $title, headerFont: $headerFont, labelFont: $labelFont, type: $type, field: $field, modelIds: $modelIds, segments: $segments)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValueDistributionPieChartWidgetConfigImplCopyWith<
          _$ValueDistributionPieChartWidgetConfigImpl>
      get copyWith => __$$ValueDistributionPieChartWidgetConfigImplCopyWithImpl<
          _$ValueDistributionPieChartWidgetConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValueDistributionPieChartWidgetConfigImplToJson(
      this,
    );
  }
}

abstract class _ValueDistributionPieChartWidgetConfig
    extends ValueDistributionPieChartWidgetConfig {
  factory _ValueDistributionPieChartWidgetConfig(
      {String title,
      FontConfig headerFont,
      FontConfig labelFont,
      DistributionChartType type,
      String field,
      List<String> modelIds,
      List<Range> segments}) = _$ValueDistributionPieChartWidgetConfigImpl;
  _ValueDistributionPieChartWidgetConfig._() : super._();

  factory _ValueDistributionPieChartWidgetConfig.fromJson(
          Map<String, dynamic> json) =
      _$ValueDistributionPieChartWidgetConfigImpl.fromJson;

  @override
  String get title;
  set title(String value);
  @override
  FontConfig get headerFont;
  set headerFont(FontConfig value);
  @override
  FontConfig get labelFont;
  set labelFont(FontConfig value);
  @override
  DistributionChartType get type;
  set type(DistributionChartType value);
  @override
  String get field;
  set field(String value);
  @override
  List<String> get modelIds;
  set modelIds(List<String> value);
  @override
  List<Range> get segments;
  set segments(List<Range> value);
  @override
  @JsonKey(ignore: true)
  _$$ValueDistributionPieChartWidgetConfigImplCopyWith<
          _$ValueDistributionPieChartWidgetConfigImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TotalAndReportingAssetWidgetConfig _$TotalAndReportingAssetWidgetConfigFromJson(
    Map<String, dynamic> json) {
  return _TotalAndReportingAssetWidgetConfig.fromJson(json);
}

/// @nodoc
mixin _$TotalAndReportingAssetWidgetConfig {
  String get title => throw _privateConstructorUsedError;
  set title(String value) => throw _privateConstructorUsedError;
  FontConfig get headerFont => throw _privateConstructorUsedError;
  set headerFont(FontConfig value) => throw _privateConstructorUsedError;
  FontConfig get labelFont => throw _privateConstructorUsedError;
  set labelFont(FontConfig value) => throw _privateConstructorUsedError;
  List<String> get assetModelIds => throw _privateConstructorUsedError;
  set assetModelIds(List<String> value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TotalAndReportingAssetWidgetConfigCopyWith<
          TotalAndReportingAssetWidgetConfig>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TotalAndReportingAssetWidgetConfigCopyWith<$Res> {
  factory $TotalAndReportingAssetWidgetConfigCopyWith(
          TotalAndReportingAssetWidgetConfig value,
          $Res Function(TotalAndReportingAssetWidgetConfig) then) =
      _$TotalAndReportingAssetWidgetConfigCopyWithImpl<$Res,
          TotalAndReportingAssetWidgetConfig>;
  @useResult
  $Res call(
      {String title,
      FontConfig headerFont,
      FontConfig labelFont,
      List<String> assetModelIds});

  $FontConfigCopyWith<$Res> get headerFont;
  $FontConfigCopyWith<$Res> get labelFont;
}

/// @nodoc
class _$TotalAndReportingAssetWidgetConfigCopyWithImpl<$Res,
        $Val extends TotalAndReportingAssetWidgetConfig>
    implements $TotalAndReportingAssetWidgetConfigCopyWith<$Res> {
  _$TotalAndReportingAssetWidgetConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? headerFont = null,
    Object? labelFont = null,
    Object? assetModelIds = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      headerFont: null == headerFont
          ? _value.headerFont
          : headerFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      labelFont: null == labelFont
          ? _value.labelFont
          : labelFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      assetModelIds: null == assetModelIds
          ? _value.assetModelIds
          : assetModelIds // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TotalAndReportingAssetWidgetConfigImplCopyWith<$Res>
    implements $TotalAndReportingAssetWidgetConfigCopyWith<$Res> {
  factory _$$TotalAndReportingAssetWidgetConfigImplCopyWith(
          _$TotalAndReportingAssetWidgetConfigImpl value,
          $Res Function(_$TotalAndReportingAssetWidgetConfigImpl) then) =
      __$$TotalAndReportingAssetWidgetConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      FontConfig headerFont,
      FontConfig labelFont,
      List<String> assetModelIds});

  @override
  $FontConfigCopyWith<$Res> get headerFont;
  @override
  $FontConfigCopyWith<$Res> get labelFont;
}

/// @nodoc
class __$$TotalAndReportingAssetWidgetConfigImplCopyWithImpl<$Res>
    extends _$TotalAndReportingAssetWidgetConfigCopyWithImpl<$Res,
        _$TotalAndReportingAssetWidgetConfigImpl>
    implements _$$TotalAndReportingAssetWidgetConfigImplCopyWith<$Res> {
  __$$TotalAndReportingAssetWidgetConfigImplCopyWithImpl(
      _$TotalAndReportingAssetWidgetConfigImpl _value,
      $Res Function(_$TotalAndReportingAssetWidgetConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? headerFont = null,
    Object? labelFont = null,
    Object? assetModelIds = null,
  }) {
    return _then(_$TotalAndReportingAssetWidgetConfigImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      headerFont: null == headerFont
          ? _value.headerFont
          : headerFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      labelFont: null == labelFont
          ? _value.labelFont
          : labelFont // ignore: cast_nullable_to_non_nullable
              as FontConfig,
      assetModelIds: null == assetModelIds
          ? _value.assetModelIds
          : assetModelIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TotalAndReportingAssetWidgetConfigImpl
    extends _TotalAndReportingAssetWidgetConfig {
  _$TotalAndReportingAssetWidgetConfigImpl(
      {this.title = 'Title',
      this.headerFont = const FontConfig(fontSize: 20, fontBold: true),
      this.labelFont = const FontConfig(),
      this.assetModelIds = const []})
      : super._();

  factory _$TotalAndReportingAssetWidgetConfigImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$TotalAndReportingAssetWidgetConfigImplFromJson(json);

  @override
  @JsonKey()
  String title;
  @override
  @JsonKey()
  FontConfig headerFont;
  @override
  @JsonKey()
  FontConfig labelFont;
  @override
  @JsonKey()
  List<String> assetModelIds;

  @override
  String toString() {
    return 'TotalAndReportingAssetWidgetConfig(title: $title, headerFont: $headerFont, labelFont: $labelFont, assetModelIds: $assetModelIds)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TotalAndReportingAssetWidgetConfigImplCopyWith<
          _$TotalAndReportingAssetWidgetConfigImpl>
      get copyWith => __$$TotalAndReportingAssetWidgetConfigImplCopyWithImpl<
          _$TotalAndReportingAssetWidgetConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TotalAndReportingAssetWidgetConfigImplToJson(
      this,
    );
  }
}

abstract class _TotalAndReportingAssetWidgetConfig
    extends TotalAndReportingAssetWidgetConfig {
  factory _TotalAndReportingAssetWidgetConfig(
      {String title,
      FontConfig headerFont,
      FontConfig labelFont,
      List<String> assetModelIds}) = _$TotalAndReportingAssetWidgetConfigImpl;
  _TotalAndReportingAssetWidgetConfig._() : super._();

  factory _TotalAndReportingAssetWidgetConfig.fromJson(
          Map<String, dynamic> json) =
      _$TotalAndReportingAssetWidgetConfigImpl.fromJson;

  @override
  String get title;
  set title(String value);
  @override
  FontConfig get headerFont;
  set headerFont(FontConfig value);
  @override
  FontConfig get labelFont;
  set labelFont(FontConfig value);
  @override
  List<String> get assetModelIds;
  set assetModelIds(List<String> value);
  @override
  @JsonKey(ignore: true)
  _$$TotalAndReportingAssetWidgetConfigImplCopyWith<
          _$TotalAndReportingAssetWidgetConfigImpl>
      get copyWith => throw _privateConstructorUsedError;
}
