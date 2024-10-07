import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class UvIndexWidget extends StatefulWidget {
  final DeviceFieldRangeGaugeWidgetConfig config;
  const UvIndexWidget({
    super.key,
    required this.config,
  });

  @override
  State<UvIndexWidget> createState() => _UvIndexWidgetState();
}

class _UvIndexWidgetState extends BaseState<UvIndexWidget> {
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
    startAngle = config.startAngle;
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TwinUtils.getTextStyle(titleFont),
              ),
            ),
            Expanded(
              child: SfRadialGauge(
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
                    labelOffset: 10,
                    axisLabelStyle: GaugeTextStyle(
                      fontSize: labelFont.fontSize,
                      color: Color(labelFont.fontColor),
                    ),
                    canScaleToFit: true,
                    radiusFactor: 1,
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
                        angle: 0,
                        horizontalAlignment: GaugeAlignment.near,
                        positionFactor: 1,
                        widget: Text(
                          'High',
                          style: TwinUtils.getTextStyle(labelFont),
                        ),
                      ),
                      GaugeAnnotation(
                        horizontalAlignment: GaugeAlignment.far,
                        angle: 180,
                        positionFactor: 1,
                        widget: Text(
                          'Low',
                          style: TwinUtils.getTextStyle(labelFont),
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

class UvIndexWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return UvIndexWidget(
        config: DeviceFieldRangeGaugeWidgetConfig.fromJson(config));
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
    return "UV Index Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return DeviceFieldRangeGaugeWidgetConfig.fromJson(config);
    }
    return DeviceFieldRangeGaugeWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "UV Index Widget";
  }
}
