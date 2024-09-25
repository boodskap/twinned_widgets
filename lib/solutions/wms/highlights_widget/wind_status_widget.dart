import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WindStatusWidget extends StatefulWidget {
  final DeviceFieldRangeGaugeWidgetConfig config;
  const WindStatusWidget({
    super.key,
    required this.config,
  });

  @override
  State<WindStatusWidget> createState() => _WindStatusWidgetState();
}

class _WindStatusWidgetState extends BaseState<WindStatusWidget> {
  bool isValidConfig = false;
  late String deviceId;
  late String title;
  late List<String> fields;
  late double minimum;
  late double maximum;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late FontConfig valueFont;
  late Color markerColor;
  late Color backgroundColor;

  double windDirectionValue = 0;
  double windSpeed = 0;
  // double value = 0;

  bool loading = false;

  @override
  void initState() {
    var config = widget.config;
    fields = config.fields;
    title = config.title;
    deviceId = config.deviceId;
    minimum = config.minimum;
    maximum = config.maximum;
    markerColor = Color(config.markerColor);
    backgroundColor = Color(config.backgroundColor);
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);

    isValidConfig = fields.isNotEmpty && deviceId.isNotEmpty;
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
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(title, style: TwinUtils.getTextStyle(titleFont)),
            ),
            Expanded(
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    startAngle: 0,
                    endAngle: 360,
                    minimum: minimum,
                    maximum: maximum,
                    showTicks: false,
                    showLabels: false,
                    canScaleToFit: true,
                    radiusFactor: 0.90,
                    axisLineStyle: AxisLineStyle(
                      thickness: 20,
                      color: backgroundColor,
                    ),
                    pointers: <GaugePointer>[
                      MarkerPointer(
                        enableAnimation: true,
                        animationType: AnimationType.easeOutBack,
                        value: windDirectionValue ?? 0,
                        markerHeight: 30,
                        markerWidth: 20,
                        color: markerColor,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0.1,
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$windSpeed km/h',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_outward,
                                  size: 24,
                                  color: Color(valueFont.fontColor),
                                ),
                                Text(
                                    getDirectionName(windDirectionValue ?? 0.0),
                                    style: TwinUtils.getTextStyle(valueFont)),
                              ],
                            ),
                          ],
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

  // Function to get direction name based on the angle
  String getDirectionName(double angle) {
    if (angle >= 348.75 || angle < 11.25) return 'N';
    if (angle >= 11.25 && angle < 33.75) return 'NNE';
    if (angle >= 33.75 && angle < 56.25) return 'NE';
    if (angle >= 56.25 && angle < 78.75) return 'ENE';
    if (angle >= 78.75 && angle < 101.25) return 'E';
    if (angle >= 101.25 && angle < 123.75) return 'ESE';
    if (angle >= 123.75 && angle < 146.25) return 'SE';
    if (angle >= 146.25 && angle < 168.75) return 'SSE';
    if (angle >= 168.75 && angle < 191.25) return 'S';
    if (angle >= 191.25 && angle < 213.75) return 'SSW';
    if (angle >= 213.75 && angle < 236.25) return 'SW';
    if (angle >= 236.25 && angle < 258.75) return 'WSW';
    if (angle >= 258.75 && angle < 281.25) return 'W';
    if (angle >= 281.25 && angle < 303.75) return 'WNW';
    if (angle >= 303.75 && angle < 326.25) return 'NW';
    if (angle >= 326.25 && angle < 348.75) return 'NNW';
    return 'NA';
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
              "exists": {"field": "data.${fields[0]}"}
            },
            {
              "exists": {"field": "data.${fields[1]}"}
            },
          ],
        ),
      );
      if (qRes.body != null &&
          qRes.body!.result != null &&
          validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (device == null) return;

        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;
        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            var winddirection = obj['p_source']['data'][fields[0]];
            var windspeed = obj['p_source']['data'][fields[1]];
            // debugPrint(winddirection.toString());

            setState(() {
              windDirectionValue = winddirection;
              windSpeed = windspeed;
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
