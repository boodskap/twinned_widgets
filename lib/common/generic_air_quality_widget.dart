import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/generic_air_quality/generic_air_quality.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
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
  late FontConfig titleFont;
  late Color titleFontColor;
  late FontConfig valueFont;
  late Color valueFontColor;
  late FontConfig labelFont;
  late Color labelFontColor;
  String title = "";
  String deviceId = "";
  String qualityField = "";
  double airQualityValue = 0;
  String airQualityType = "";
   bool apiLoadingStatus = false;
    String subTitle = "";
  final List<LabelDetails> _labels = [
    LabelDetails(0, '0'),
    LabelDetails(20, '20'),
    LabelDetails(40, '40'),
    LabelDetails(60, '60'),
    LabelDetails(80, '80'),
    LabelDetails(100, '100')
  ];

  @override
  void initState() {
    var config = widget.config;

    titleFont = FontConfig.fromJson(config.titleFont);
    titleFontColor =
        titleFont.fontColor <= 0 ? Colors.black : Color(titleFont.fontColor);

    valueFont = FontConfig.fromJson(config.valueFont);
    valueFontColor =
        valueFont.fontColor <= 0 ? Colors.black : Color(valueFont.fontColor);

    labelFont = FontConfig.fromJson(config.labelFont);
    labelFontColor =
        labelFont.fontColor <= 0 ? Colors.black : Color(labelFont.fontColor);
    title = widget.config.title;
    subTitle = widget.config.subTitle;
    deviceId = widget.config.deviceId;
    qualityField = widget.config.qualityField;
    isValidConfig = widget.config.deviceId.isNotEmpty &&
        widget.config.qualityField.isNotEmpty;

    super.initState();
  }

  String _getAirQualityStatus(double value) {
    if (value <= 20) {
      return "POOR";
    } else if (value <= 40) {
      return "LOW";
    } else if (value <= 60) {
      return "MODERATE";
    } else if (value <= 80) {
      return "GOOD";
    } else {
      return "EXCELLENT";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
        ),
      );
    }
   if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return SfRadialGauge(
      title: GaugeTitle(
        text: title,
        textStyle: TextStyle(
            fontWeight:
                titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            fontSize: titleFont.fontSize,
            color: titleFontColor),
      ),
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          startAngle: 130,
          endAngle: 50,
          maximumLabels: 100,
          canScaleToFit: true,
          showFirstLabel: false,
          interval: 1,
          onLabelCreated: _handleLabelCreated,
          canRotateLabels: true,
          labelsPosition: ElementsPosition.outside,
          showTicks: false,
          axisLineStyle: const AxisLineStyle(
            thickness: 15,
            thicknessUnit: GaugeSizeUnit.logicalPixel,
            cornerStyle: CornerStyle.bothCurve,
          ),
          pointers: <GaugePointer>[
            MarkerPointer(
              value: airQualityValue,
              enableDragging: false,
              color: Colors.white,
              borderColor: Colors.black,
              borderWidth: 2,
              markerType: MarkerType.circle,
              markerHeight: 8,
              markerWidth: 8,
              overlayRadius: 0,
            )
          ],
          ranges: _buildRanges(),
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              angle: 130,
              horizontalAlignment: GaugeAlignment.far,
              positionFactor: 0.90,
              verticalAlignment: GaugeAlignment.near,
              widget: Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text(
                  "0",
                  style: TextStyle(
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: labelFont.fontSize,
                      color: labelFontColor),
                ),
              ),
            ),
            GaugeAnnotation(
              angle: 50,
              horizontalAlignment: GaugeAlignment.near,
              positionFactor: 0.90,
              verticalAlignment: GaugeAlignment.near,
              widget: Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text(
                  "100",
                  style: TextStyle(
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: labelFont.fontSize,
                      color: labelFontColor),
                ),
              ),
            ),
            GaugeAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '${airQualityValue.round()}\n',
                        style: TextStyle(
                            fontWeight: valueFont.fontBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: valueFont.fontSize,
                            color: valueFontColor),
                        children: [
                          TextSpan(
                            text: airQualityType,
                            style: TextStyle(
                                fontWeight: valueFont.fontBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: valueFont.fontSize * 0.55,
                                color: valueFontColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      subTitle,
                      style: TextStyle(
                          fontWeight: valueFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: valueFont.fontSize * 0.4,
                          color: valueFontColor.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Future _load({String? filter, String search = '*'}) async {
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
              airQualityValue = fetchedValue[qualityField] ?? 0;
              if (airQualityValue < 0) {
                airQualityValue = 0;
              } else if (airQualityValue > 100) {
                airQualityValue = 100;
              }
              airQualityType = _getAirQualityStatus(airQualityValue);
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

  void _handleLabelCreated(AxisLabelCreatedArgs args) {
    for (int i = 0; i < _labels.length; i++) {
      LabelDetails details = _labels[i];
      if (details.labelPoint == int.parse(args.text)) {
        args.text = details.customizedLabel;
        args.labelStyle = GaugeTextStyle(
            fontWeight:
                labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
            fontSize: labelFont.fontSize,
            color: labelFontColor);
        return;
      }
    }

    args.text = '';
  }

  List<GaugeRange> _buildRanges() {
    List<GaugeRange> ranges = [];
    ranges.add(GaugeRange(
      startValue: 0,
      endValue: 20,
      color: Color(0xFFE51F1F),
    ));
    ranges.add(GaugeRange(
      startValue: 20.5,
      endValue: 40,
      color: Color(0xFFF2A134),
    ));
    ranges.add(GaugeRange(
      startValue: 40.5,
      endValue: 60,
      color: Color(0xFFF7E379),
    ));
    ranges.add(GaugeRange(
      startValue: 60.5,
      endValue: 80,
      color: Color(0XFFBBDB44),
    ));
    ranges.add(GaugeRange(
      startValue: 80.5,
      endValue: 100,
      color: Color(0XFF44CE1B),
    ));
    return ranges;
  }
}

class LabelDetails {
  LabelDetails(this.labelPoint, this.customizedLabel);
  int labelPoint;
  String customizedLabel;
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
    return const Icon(Icons.air);
  }

  @override
  String getPaletteName() {
    return "Generic Air Quality";
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
    return 'Generic Air Quality';
  }
}
