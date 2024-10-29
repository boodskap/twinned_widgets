import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/semi_circle_range_widget/semi_circle_range_widget.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class SemiCircleRangeWidget extends StatefulWidget {
  final SemiCircleRangeWidgetConfig config;
  const SemiCircleRangeWidget({
    super.key,
    required this.config,
  });

  @override
  State<SemiCircleRangeWidget> createState() => _SemiCircleRangeWidgetState();
}

class _SemiCircleRangeWidgetState extends BaseState<SemiCircleRangeWidget> {
  bool isValidConfig = false;
  late String title;
  late String deviceId;
  late String field;
  late double startAngle;
  late double endAngle;
  late double minimum;
  late double maximum;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late FontConfig valueFont;
  late Color backgroundColor;
  late Color valueColor;
  late double interval;
  late bool showFirtLablel;
  late bool showLastLabel;
  late bool showLabel;
  double value = 0;

  @override
  void initState() {
    var config = widget.config;
    title = config.title;
    field = config.field;
    deviceId = config.deviceId;
    minimum = config.minimum;
    maximum = config.maximum;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    valueColor = Color(config.valueColor);
    backgroundColor = Color(config.backgroundColor);
    interval = config.interval;
    showFirtLablel = config.showFirstLabel;
    showLastLabel = config.showLastLabel;
    showLabel = config.showLabel;

    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4), // Border radius
        border: Border.all(
          color: Colors.white, // Border color
          width: 1, // Border width
        ),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(title, style: TwinUtils.getTextStyle(titleFont)),
            ),
            Expanded(
              child: SfRadialGauge(
                enableLoadingAnimation: true,
                axes: <RadialAxis>[
                  RadialAxis(
                    showTicks: false,
                    startAngle: 180,
                    endAngle: 0,
                    maximum: maximum,
                    minimum: minimum,
                    interval: interval,
                    showLastLabel: showLastLabel,
                    showFirstLabel: showFirtLablel,
                    showLabels: showLabel,
                    labelsPosition: ElementsPosition.outside,
                    labelOffset: 15,
                    axisLabelStyle: GaugeTextStyle(
                      fontSize: labelFont.fontSize,
                      color: Color(labelFont.fontColor),
                    ),
                    canScaleToFit: true,
                    radiusFactor: 0.95,
                    axisLineStyle: AxisLineStyle(
                      thickness: 15,
                      color: backgroundColor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        animationType: AnimationType.elasticOut,
                        enableAnimation: true,
                        value: value,
                        color: valueColor,
                        width: 15,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0,
                        widget: Text(value.toString(),
                            style: TwinUtils.getTextStyle(valueFont)),
                      ),
                      GaugeAnnotation(
                        angle: 5,
                        horizontalAlignment: GaugeAlignment.near,
                        positionFactor: 1,
                        widget: Padding(
                          padding: const EdgeInsets.only(top: 15.0, right: 20),
                          child: Text(
                            'High',
                            style: TwinUtils.getTextStyle(labelFont),
                          ),
                        ),
                      ),
                      GaugeAnnotation(
                        horizontalAlignment: GaugeAlignment.near,
                        angle: 175,
                        positionFactor: 1,
                        widget: Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            'Low',
                            style: TwinUtils.getTextStyle(labelFont),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> load() async {
    if (!isValidConfig || loading) return;
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
              "match_phrase": {"deviceId": deviceId}
            },
            {
              "exists": {"field": "data.$field"}
            },
          ],
        ),
      );
      if (qRes.body != null &&
          qRes.body!.result != null &&
          validateResponse(qRes)) {
        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;
        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            value = obj['p_source']['data'][field];
            // debugPrint(value.toString());
            setState(() {
              value = value;
            });
          }
        }
      }
    });
    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}

class SemiCircleRangeWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return SemiCircleRangeWidget(
        config: SemiCircleRangeWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.airline_stops_rounded);
  }

  @override
  String getPaletteName() {
    return "Semi Circle Range Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return SemiCircleRangeWidgetConfig.fromJson(config);
    }
    return SemiCircleRangeWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Semi Circle Range Widget";
  }
}
