import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/thermometer_temperature/thermometer_temperature.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class ThermometerWidget extends StatefulWidget {
  final ThermometerTemperatureWidgetConfig config;
  const ThermometerWidget({
    super.key,
    required this.config,
  });

  @override
  State<ThermometerWidget> createState() => _ThermometerWidgetState();
}

class _ThermometerWidgetState extends BaseState<ThermometerWidget> {
  bool isValidConfig = false;
  late String title;
  late String deviceId;
  late String field;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late Color borderColor;
  late Color foreColor;
  late Color cardColor;
  String minValue = '';
  String avgValue = '';
  String maxValue = '';

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    field = config.field;
    title = config.title;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    borderColor = Color(config.borderColor);
    foreColor = Color(config.foreColor);
    cardColor = Color(config.cardColor);
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
        color: cardColor,
        borderRadius: BorderRadius.circular(4), // Border radius
        border: Border.all(
          color: cardColor, // Border color
          width: 1, // Border width
        ),
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                style: TwinUtils.getTextStyle(titleFont),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Record High',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                            Text(
                              '${maxValue}°',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Record Low',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                            Text(
                              '${minValue}°',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    SfLinearGauge(
                      minimum: -20,
                      showTicks: false,
                      showLabels: false,
                      maximum: 50,
                      interval: 10,
                      minorTicksPerInterval: 0,
                      axisTrackExtent: 23,
                      axisTrackStyle: LinearAxisTrackStyle(
                        thickness: 12,
                        color: foreColor,
                        borderWidth: 2,
                        borderColor: borderColor,
                        edgeStyle: LinearEdgeStyle.bothCurve,
                      ),
                      tickPosition: LinearElementPosition.outside,
                      labelPosition: LinearLabelPosition.outside,
                      orientation: LinearGaugeOrientation.vertical,
                      markerPointers: <LinearMarkerPointer>[
                        //Bottom Round Marker
                        LinearShapePointer(
                          value: -20,
                          markerAlignment: LinearMarkerAlignment.start,
                          shapeType: LinearShapePointerType.circle,
                          borderWidth: 2,
                          borderColor: borderColor,
                          color: foreColor,
                          position: LinearElementPosition.cross,
                          width: 35,
                          height: 35,
                        ),
                        //Bottom of the widget round and side edge color
                        LinearWidgetPointer(
                          value: -20,
                          markerAlignment: LinearMarkerAlignment.start,
                          child: Container(
                            width: 10,
                            height: 3.4,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 2.0,
                                  color: foreColor,
                                ),
                                right: BorderSide(
                                  width: 2.0,
                                  color: foreColor,
                                ),
                              ),
                              color: foreColor,
                            ),
                          ),
                        ),
                      ],
                      barPointers: <LinearBarPointer>[
                        LinearBarPointer(
                          value: 60,
                          enableAnimation: false,
                          thickness: 6,
                          edgeStyle: LinearEdgeStyle.endCurve,
                          color: foreColor,
                        )
                      ],
                    ),
                    Container(
                      transform: Matrix4.translationValues(-6, 0, 0.0),
                      child: SfLinearGauge(
                        maximum: 120,
                        showLabels: false,
                        showTicks: false,
                        showAxisTrack: false,
                        interval: 20,
                        axisTrackExtent: 24,
                        axisTrackStyle:
                            const LinearAxisTrackStyle(thickness: 0),
                        orientation: LinearGaugeOrientation.vertical,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Average High',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                            Text(
                              '${avgValue}°',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                          ],
                        ),
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

  Future load() async {
    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: [],
          page: 0,
          size: 0,
          mustConditions: [
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
            {
              "exists": {"field": "data.${widget.config.field}"}
            },
          ],
          conditions: [
            EqlCondition(name: 'aggs', condition: {
              "min": {
                "min": {"field": "data.$field"}
              },
              "max": {
                "max": {"field": "data.$field"}
              },
              "avg": {
                "avg": {"field": "data.$field"}
              }
            })
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        num min = json['aggregations']['min']['value'] ?? 0;
        num avg = json['aggregations']['avg']['value'] ?? 0;
        num max = json['aggregations']['max']['value'] ?? 0;

        minValue = min.toStringAsFixed(2);
        avgValue = avg.toStringAsFixed(2);
        maxValue = max.toStringAsFixed(2);
      }
      // debugPrint(minValue);
      // debugPrint(avgValue);
      // debugPrint(maxValue);
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}

class ThermometerWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return ThermometerWidget(
      config: ThermometerTemperatureWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.thermostat);
  }

  @override
  String getPaletteName() {
    return "Temperature thermo widget ";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return ThermometerTemperatureWidgetConfig.fromJson(config);
    }
    return ThermometerTemperatureWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Temperature thermo device field widget';
  }
}
