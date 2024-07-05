import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';

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
  double value = 0;

  bool loading = false;

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

    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    interval: 3,
                    showLastLabel: false,
                    showFirstLabel: false,
                    showLabels: true,
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
        // Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        // if (device == null) return;

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
