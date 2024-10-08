import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class SunriseSunsetWidget extends StatefulWidget {
  final DeviceFieldRangeGaugeWidgetConfig config;
  const SunriseSunsetWidget({
    super.key,
    required this.config,
  });

  @override
  State<SunriseSunsetWidget> createState() => _SunriseSunsetWidgetState();
}

class _SunriseSunsetWidgetState extends BaseState<SunriseSunsetWidget> {
  bool isValidConfig = false;
  late String deviceId;
  late List<String> fields;
  late String title;
  late double startAngle;
  late double endAngle;
  late double minimum;
  late double maximum;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late FontConfig valueFont;
  late Color backgroundColor;
  late Color valueColor;
  DateTime sunriseValue = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime sunsetValue = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    var config = widget.config;
    fields = config.fields;
    title = config.title;
    titleFont = FontConfig.fromJson(config.titleFont);
    deviceId = config.deviceId;
    startAngle = config.startAngle;
    endAngle = config.endAngle;
    minimum = config.minimum;
    maximum = config.maximum;
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    valueColor = Color(config.valueColor);
    backgroundColor = Color(config.backgroundColor);

    isValidConfig = fields.isNotEmpty && deviceId.isNotEmpty;
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
        color: Colors.transparent,
        elevation: 0,
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
                    startAngle: 180,
                    endAngle: 0,
                    minimum: 0,
                    maximum: 24,
                    showLabels: false,
                    showTicks: false,
                    showLastLabel: true,
                    labelOffset: 10,
                    canScaleToFit: true,
                    radiusFactor: 1,
                    axisLineStyle:
                        AxisLineStyle(thickness: 15, color: backgroundColor),
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: _timeToDouble(sunriseValue) ?? 0,
                        endValue: _timeToDouble(sunsetValue) ?? 0,
                        color: valueColor,
                        startWidth: 15,
                        endWidth: 15,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        verticalAlignment: GaugeAlignment.far,
                        horizontalAlignment: GaugeAlignment.far,
                        angle: 230,
                        positionFactor: 1.1,
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sunrise',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                            Text(
                              _formatTime(sunriseValue) ?? '--',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                          ],
                        ),
                      ),
                      GaugeAnnotation(
                        verticalAlignment: GaugeAlignment.far,
                        horizontalAlignment: GaugeAlignment.near,
                        angle: 310,
                        positionFactor: 1.10,
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Sunset',
                                style: TwinUtils.getTextStyle(valueFont)),
                            Text(_formatTime(sunsetValue) ?? '--',
                                style: TwinUtils.getTextStyle(valueFont)),
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

  double _timeToDouble(DateTime time) {
    return time.hour + time.minute / 60.0;
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
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
            var sunriseEpoch = obj['p_source']['data'][fields[0]];
            var sunsetEpoch = obj['p_source']['data'][fields[1]];

            // Ensure the state is updated only after fetching data
            if (mounted) {
              setState(() {
                sunriseValue =
                    DateTime.fromMillisecondsSinceEpoch(sunriseEpoch);
                sunsetValue = DateTime.fromMillisecondsSinceEpoch(sunsetEpoch);
              });
            }
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

class SunriseSunsetWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return SunriseSunsetWidget(
        config: DeviceFieldRangeGaugeWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.sunny_snowing);
  }

  @override
  String getPaletteName() {
    return "Sunrise & Sunset Widget";
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
    return "Sunrise & Sunset Widget";
  }
}
