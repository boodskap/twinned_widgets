import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/generic_air_quality/generic_air_quality.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GenericAirQualityWidget extends StatefulWidget {
  final GenericAirQualityWidgetConfig config;
  const GenericAirQualityWidget({super.key, required this.config});

  @override
  State<GenericAirQualityWidget> createState() =>
      _GenericAirQualityWidgetState();
}

class _GenericAirQualityWidgetState extends BaseState<GenericAirQualityWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String field;
  late String deviceId;
  late String title;
  late String subTitle;
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
  late double interval;
  late double markerBorderWidth;
  late double markerSize;
  late Color markerBorderColor;
  dynamic value;
  String airQualityType = "";
  List<dynamic> rangeLabel = [];
  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    subTitle = config.subTitle;
    titleBgColor = Color(config.titleBgColor);
    markerBorderColor = Color(config.markerBorderColor);
    gaugeAnimate = config.gaugeAnimate;
    positionFactor = config.positionFactor;
    radiusFactor = config.radiusFactor;
    dialStartWidth = config.dialStartWidth;
    dialEndWidth = config.dialEndWidth;
    axisThickness = config.axisThickness;
    angle = config.angle;
    showLabel = config.showLabel;
    interval = config.interval;
    markerBorderWidth = config.markerBorderWidth;
    markerSize = config.markerSize;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    rangeLabel = config.ranges;
    if (radiusFactor > 1 && positionFactor > 1) {
      radiusFactor = 1;
      positionFactor = 1;
    }
    if (radiusFactor < 0 && positionFactor < 0) {
      radiusFactor = 0;
      positionFactor = 0;
    }

    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
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
    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
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
          label: showLabel ? range.label : "",
        ),
      );
    }

    return SfRadialGauge(
      enableLoadingAnimation: gaugeAnimate,
      title: GaugeTitle(
        backgroundColor: titleBgColor,
        text: title,
        textStyle: TextStyle(
          fontFamily: titleFont.fontFamily,
          fontSize: titleFont.fontSize,
          fontWeight: titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
          color: Color(titleFont.fontColor),
        ),
      ),
      axes: [
        RadialAxis(
          pointers: [
            MarkerPointer(
              enableAnimation: gaugeAnimate,
              value: value ?? 0.0,
              enableDragging: false,
              color: Colors.white,
              borderColor: markerBorderColor,
              borderWidth: markerBorderWidth,
              markerType: MarkerType.circle,
              markerHeight: markerSize,
              markerWidth: markerSize,
              overlayRadius: 0,
              offsetUnit: GaugeSizeUnit.factor,
              markerOffset: 0.065,
            )
          ],
          annotations: [
            GaugeAnnotation(
              angle: 130,
              horizontalAlignment: GaugeAlignment.far,
              positionFactor: positionFactor,
              verticalAlignment: GaugeAlignment.near,
              widget: Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  begin.from != null ? begin.from.toString() : '0',
                  style: TextStyle(
                    fontSize: labelFont.fontSize,
                    fontWeight: labelFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(labelFont.fontColor),
                  ),
                ),
              ),
            ),
            GaugeAnnotation(
              angle: 50,
              horizontalAlignment: GaugeAlignment.far,
              positionFactor: positionFactor,
              verticalAlignment: GaugeAlignment.near,
              widget: Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  end.to != null ? end.to.toString() : '100',
                  style: TextStyle(
                    fontSize: labelFont.fontSize,
                    fontWeight: labelFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(labelFont.fontColor),
                  ),
                ),
              ),
            ),
            GaugeAnnotation(
              horizontalAlignment: GaugeAlignment.center,
              verticalAlignment: GaugeAlignment.center,
              widget: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: value != null ? value.toString() : '--',
                            style: TextStyle(
                              fontSize: valueFont.fontSize,
                              fontWeight: valueFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Color(valueFont.fontColor),
                            )),
                      ),
                    ),
                    Center(
                      child: Text(
                        airQualityType,
                        style: TextStyle(
                          fontSize: valueFont.fontSize * 0.55,
                          fontWeight: valueFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(valueFont.fontColor),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        subTitle,
                        style: TextStyle(
                          fontSize: valueFont.fontSize * 0.4,
                          fontWeight: valueFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(valueFont.fontColor).withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
          axisLineStyle: AxisLineStyle(
            thickness: axisThickness + 10,
            cornerStyle: CornerStyle.bothCurve,
          ),
          minimum: begin.from ?? 0,
          maximum: end.to ?? 100,
          showLabels: showLabel,
          radiusFactor: radiusFactor,
          ranges: ranges,
          showFirstLabel: false,
          interval: interval,
          labelsPosition: ElementsPosition.outside,
          axisLabelStyle: GaugeTextStyle(
              fontSize: labelFont.fontSize,
              fontWeight:
                  labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
              color: Color(labelFont.fontColor)),
          showTicks: false,
        ),
      ],
    );
  }

  String getLabelForValue(int value) {
    for (var range in rangeLabel) {
      if (value >= range['from'] &&
          (range['to'] == null || value <= range['to'])) {
        return range['label'];
      }
    }
    return "";
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
            {
              "exists": {"field": "data.$field"}
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
              value = fetchedValue[field] ?? 0;
              airQualityType = getLabelForValue(value);
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

class GenericAirQualityWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericAirQualityWidget(
        config: GenericAirQualityWidgetConfig.fromJson(config));
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
    return "Generic Air Quality Gauge";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericAirQualityWidgetConfig.fromJson(config);
    }
    return GenericAirQualityWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Air Quality Gauge';
  }
}
