import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/generic_air_quality/generic_air_quality_linear.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GenericAirQualityLinearWidget extends StatefulWidget {
  final GenericAirQualityLinearWidgetConfig config;
  const GenericAirQualityLinearWidget({super.key, required this.config});

  @override
  State<GenericAirQualityLinearWidget> createState() =>
      _GenericAirQualityLinearWidgetState();
}

class _GenericAirQualityLinearWidgetState
    extends BaseState<GenericAirQualityLinearWidget> {
  bool isValidConfig = false;
  late String field;
  late String deviceId;
  late String title;
  late String fieldLabel;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late FontConfig axisLabelFont;
  late FontConfig fieldLabelFont;
  late FontConfig valueFont;
  late Color titleFontColor;
  late Color labelFontColor;
  late Color axisLabelFontColor;
  late Color fieldLabelFontColor;
  late Color valueFontColor;
  late bool gaugeAnimate;

  late bool showLabel;
  late double interval;
  late double markerSize;
  late double rangeWidth;
  late double markerOffset;
  double markerValue = 0;
  late Color markerColor;
  late double width;
  dynamic value;
  List<dynamic> rangeLabel = [];
  bool apiLoadingStatus = false;
  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    fieldLabel = config.fieldLabel;
    gaugeAnimate = config.gaugeAnimate;
    markerColor = Color(config.markerColor);
    showLabel = config.showLabel;
    interval = config.interval;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    axisLabelFont = FontConfig.fromJson(config.axisLabelFont);
    fieldLabelFont = FontConfig.fromJson(config.fieldLabelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    titleFontColor = _getColor(titleFont.fontColor);
    labelFontColor = _getColor(labelFont.fontColor);
    axisLabelFontColor = _getColor(axisLabelFont.fontColor);
    fieldLabelFontColor = _getColor(fieldLabelFont.fontColor);
    valueFontColor = _getColor(valueFont.fontColor);
    rangeLabel = config.ranges;
    markerSize = config.markerSize;
    rangeWidth = config.rangeWidth;
    markerOffset = config.markerOffset;
    width = config.width;
    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
    super.initState();
  }

  Color _getColor(int colorValue) {
    return colorValue <= 0 ? Colors.black : Color(colorValue);
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

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    List<LinearGaugeRange> ranges = [];
    late Range begin;
    late Range end;
    for (int i = 0; i < widget.config.ranges.length; i++) {
      dynamic val = widget.config.ranges[i];
      Range range = Range.fromJson(val);
      if (i == 0) {
        begin = range;
      }
      end = range;
      ranges.add(LinearGaugeRange(
        startValue: range.from ?? double.minPositive,
        endValue: range.to ?? double.maxFinite,
        startWidth: rangeWidth,
        endWidth: rangeWidth,
        position: LinearElementPosition.outside,
        color: Color(range.color ?? Colors.black.value),
        edgeStyle: i == 0
            ? LinearEdgeStyle.startCurve
            : i == rangeLabel.length - 1
                ? LinearEdgeStyle.endCurve
                : LinearEdgeStyle.bothFlat,
        child: Center(
            child: Text(range.label,
                style: TextStyle(
                    fontFamily: labelFont.fontFamily,
                    fontSize: labelFont.fontSize,
                    fontWeight: labelFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(labelFont.fontColor)))),
      ));
    }

    return Center(
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontFamily: titleFont.fontFamily,
                    fontSize: titleFont.fontSize,
                    fontWeight: titleFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: titleFontColor)),
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fieldLabel,
                              style: TextStyle(
                                  fontFamily: fieldLabelFont.fontFamily,
                                  fontSize: fieldLabelFont.fontSize,
                                  fontWeight: fieldLabelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: fieldLabelFontColor)),
                          Text(markerValue.toString(),
                              style: TextStyle(
                                  fontFamily: valueFont.fontFamily,
                                  fontSize: valueFont.fontSize,
                                  fontWeight: valueFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: valueFontColor))
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    SfLinearGauge(
                      minimum: begin.from ?? 0,
                      maximum: end.to ?? 100,
                      useRangeColorForAxis: false,
                      showAxisTrack: false,
                      animateAxis: false,
                      animateRange: false,
                      interval: interval,
                      showTicks: false,
                      ranges: ranges,
                      showLabels: showLabel,
                      axisLabelStyle: TextStyle(
                          fontFamily: axisLabelFont.fontFamily,
                          fontSize: axisLabelFont.fontSize,
                          fontWeight: axisLabelFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: axisLabelFontColor),
                      animationDuration: 0,
                      markerPointers: [
                        LinearShapePointer(
                          value: markerValue,
                          color: markerColor,
                          borderWidth: 0,
                          width: markerSize,
                          height: markerSize,
                          borderColor: Colors.transparent,
                          shapeType: LinearShapePointerType.triangle,
                          offset: markerOffset,
                          enableAnimation: gaugeAnimate
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getLabelForValue(double value) {
    for (var range in rangeLabel) {
      if (value >= range['from'] && markerValue <= range['to']) {
        return Color(range['color']);
      }
    }
    return Colors.black;
  }

  Future _load() async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

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
          ],
          sort: {'updatedStamp': 'desc'},
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            dynamic fetchedValue = obj['p_source']['data'];
            refresh(sync: () {
              markerValue = fetchedValue["airQualityIndex"] ?? 0;
              markerColor = getLabelForValue(markerValue);
            });
          }
        }
      }
    });

    loading = false;
    apiLoadingStatus = true;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}

class GenericAirQualityLinearWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericAirQualityLinearWidget(
        config: GenericAirQualityLinearWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.linear_scale);
  }

  @override
  String getPaletteName() {
    return "Linear Gauge";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericAirQualityLinearWidgetConfig.fromJson(config);
    }
    return GenericAirQualityLinearWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Linear Gauge';
  }
}
