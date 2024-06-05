import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/range_label_dial/range_label_dial.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_widgets/twinned_widgets.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DeviceFieldRangeLabelDialWidget extends StatefulWidget {
  final DeviceFieldRangeLabelDialWidgetConfig config;
  const DeviceFieldRangeLabelDialWidget({super.key, required this.config});

  @override
  State<DeviceFieldRangeLabelDialWidget> createState() =>
      _DeviceFieldRangeLabelDialWidgetState();
}

class _DeviceFieldRangeLabelDialWidgetState
    extends BaseState<DeviceFieldRangeLabelDialWidget> {
  bool isValidConfig = false;
  late String field;
  late String deviceId;
  late String title;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late FontConfig valueFont;
  late Color titleBgColor;
  late bool gaugeAnimate;
  late double positionFactor;
  late double radiusFactor;
  late double dialStartWidth;
  late double dialEndWidth;
  late double angle;
  late double axisThickness;
  late bool showLabel;
  String selectedFieldName = '';

  dynamic temperatureValue;
  dynamic volume;
  dynamic value;

  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    titleBgColor = Color(config.titleBgColor);
    gaugeAnimate = config.gaugeAnimate;
    positionFactor = config.positionFactor;
    radiusFactor = config.radiusFactor;
    dialStartWidth = config.dialStartWidth;
    dialEndWidth = config.dialEndWidth;
    axisThickness = config.axisThickness;
    angle = config.angle;
    showLabel = config.showLabel;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);

    if (radiusFactor > 1 && positionFactor > 1) {
      radiusFactor = 1;
      positionFactor = 1;
    }
    if (radiusFactor < 0 && positionFactor < 0) {
      radiusFactor = 0;
      positionFactor = 0;
    }

    isValidConfig = isValidConfig && deviceId.isNotEmpty;
    isValidConfig = field.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Wrap(
          spacing: 8.0,
          children: [
            Text(
              'Not configured properly',
              style:
                  TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }
    List<GaugeRange> ranges = [];
    int i = 0;
    late Range begin;
    late Range end;
    for (dynamic val in widget.config.ranges) {
      Range range = Range.fromJson(val);
      if (i == 0) {
        begin = range;
      }
      end = range;
      ++i;
      ranges.add(
        GaugeRange(
          labelStyle: GaugeTextStyle(
            fontFamily: labelFont.fontFamily,
            color: Color(labelFont.fontColor),
            fontSize: labelFont.fontSize,
            fontWeight:
                labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
          ),
          startWidth: dialStartWidth,
          endWidth: dialEndWidth,
          startValue: range.from ?? double.minPositive,
          endValue: range.to ?? double.maxFinite,
          color: Color(range.color ?? Colors.black.value),
          label: range.label,
        ),
      );
    }

    return Center(
      child: SfRadialGauge(
        enableLoadingAnimation: gaugeAnimate,
        title: GaugeTitle(
          backgroundColor: titleBgColor,
          text: title,
          textStyle: TextStyle(
            fontFamily: titleFont.fontFamily,
            fontSize: titleFont.fontSize,
            fontWeight:
                titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            color: Color(titleFont.fontColor),
          ),
        ),
        axes: [
          RadialAxis(
            pointers: [
              NeedlePointer(
                enableAnimation: gaugeAnimate,
                value: value ?? 0.0,
              )
            ],
            annotations: [
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value != null ? '$value' : '-',
                      style: TextStyle(
                        color: Color(valueFont.fontColor),
                        fontFamily: valueFont.fontFamily,
                        fontSize: valueFont.fontSize,
                        fontWeight: valueFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      selectedFieldName,
                      style: TextStyle(
                        color: Color(valueFont.fontColor),
                        fontFamily: valueFont.fontFamily,
                        fontSize: valueFont.fontSize - 10,
                        fontWeight: valueFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                angle: angle,
                positionFactor: positionFactor,
              ),
            ],
            axisLineStyle: AxisLineStyle(
              thickness: axisThickness + 10,
            ),
            minimum: begin.from ?? 0,
            maximum: end.to ?? 100,
            showLabels: showLabel,
            radiusFactor: radiusFactor,
            ranges: ranges,
          ),
        ],
      ),
    );
  }

  @override
  void setup() {
    load();
  }

  Future<void> load() async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    try {
      await execute(() async {
        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
            apikey: TwinnedSession.instance.authToken,
            body: EqlSearch(
                source: ["data"],
                page: 0,
                size: 1,
                mustConditions: [
                  {
                    "match_phrase": {"deviceId": widget.config.deviceId}
                  },
                  {
                    "exists": {"field": "data.$field"}
                  },
                ]));

        if (qRes.body != null &&
            qRes.body!.result != null &&
            validateResponse(qRes)) {
          Map<String, dynamic>? json =
              qRes.body!.result! as Map<String, dynamic>?;

          if (json != null) {
            List<dynamic> hits = json['hits']['hits'];

            if (hits.isNotEmpty) {
              Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;

              value = obj['p_source']['data'][widget.config.field];
              // debugPrint(value.toString());
            } else {
              // debugPrint('No hits found in response.');
            }
          } else {
            // debugPrint('Failed to parse JSON response.');
          }
        } else {
          // debugPrint('Failed to validate response: ${qRes.statusCode}');
        }
      });
    } catch (e, stackTrace) {
      // debugPrint('Error loading data: $e');
      // debugPrint('Stack trace: $stackTrace');
    } finally {
      loading = false;
      selectedFieldName = field;
      refresh();
    }
  }
}

class DeviceFieldRangeLabelDialWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldRangeLabelDialWidget(
        config: DeviceFieldRangeLabelDialWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.speed);
  }

  @override
  String getPaletteName() {
    return "Range Label Dial";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceFieldRangeLabelDialWidgetConfig.fromJson(config);
    }
    return DeviceFieldRangeLabelDialWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Range label dial show on the field';
  }
}
