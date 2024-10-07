import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/device_multi_field_radial_axis/device_multi_field_radial_axis.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class DeviceMultiFieldRadialAxisWidget extends StatefulWidget {
  final DeviceMultiFieldRadialAxisWidgetConfig config;
  const DeviceMultiFieldRadialAxisWidget({super.key, required this.config});

  @override
  State<DeviceMultiFieldRadialAxisWidget> createState() =>
      _DeviceMultiFieldRadialAxisWidgetState();
}

class _DeviceMultiFieldRadialAxisWidgetState
    extends BaseState<DeviceMultiFieldRadialAxisWidget> {
  bool isConfigValid = false;
  late String deviceId;
  late List<String> fields;
  late String title;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late double radiusFactor;
  late double axisLineThickness;
  late double startAngle;
  late double endAngle;
  late Color axisBgColor;
  late bool gaugeAnimate;

  dynamic value;
  Map<String, dynamic> fieldValues = {};

  @override
  void initState() {
    var config = widget.config;
    fields = config.fields;
    deviceId = config.deviceId;
    title = config.title;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    radiusFactor = config.radiusFactor;
    axisLineThickness = config.axisLineThickness;
    startAngle = config.startAngle;
    endAngle = config.endAngle;
    axisBgColor = Color(config.axisBgColor);
    gaugeAnimate = config.gaugeAnimate;

    isConfigValid = fields.isNotEmpty &&
        deviceId.isNotEmpty &&
        (config.fields.length == config.ranges.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isConfigValid) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return loading
        ? const Center(child: CircularProgressIndicator())
        : SfRadialGauge(
            enableLoadingAnimation: gaugeAnimate,
            title: GaugeTitle(
              text: title,
              textStyle: TwinUtils.getTextStyle(titleFont),
            ),
            axes: widget.config.ranges.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> range = entry.value;

              double from = range['from']?.toDouble() ?? 0.0;
              double to = range['to']?.toDouble() ?? 100.0;
              String label = range['label'] ?? 'Unknown';
              Color fieldColor = Color(range['color']);

              double value = fieldValues[fields[index]]?.toDouble() ?? 0.0;
              double radiusFactorNew = radiusFactor - (index * 0.1);

              return RadialAxis(
                pointers: [
                  //individual range properties
                  RangePointer(
                    value: value,
                    width: axisLineThickness,
                    color: fieldColor,
                    enableAnimation: gaugeAnimate,
                  ),
                ],
                annotations: [
                  GaugeAnnotation(
                    widget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: fieldColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$label $value',
                          style: TwinUtils.getTextStyle(labelFont)
                              .copyWith(color: fieldColor),
                        ),
                      ],
                    ),
                    angle: 250 - (index * 5),
                    positionFactor: 1,
                    horizontalAlignment: GaugeAlignment.far,
                  ),
                ],
                axisLineStyle: AxisLineStyle(
                  thickness: axisLineThickness,
                  color: axisBgColor,
                ),
                minimum: from,
                maximum: to,
                startAngle: startAngle,
                endAngle: endAngle,
                radiusFactor: radiusFactorNew,
                showLabels: false,
                showTicks: false,
              );
            }).toList(),
          );
  }

  Future<void> _load() async {
    if (!isConfigValid || loading) return;

    loading = true;

    var query = EqlSearch(
      source: ["data"],
      page: 0,
      size: 1,
      mustConditions: [
        {
          "match_phrase": {"deviceId": deviceId}
        }
      ],
    );

    var qRes = await TwinnedSession.instance.twin.queryDeviceData(
      apikey: TwinnedSession.instance.authToken,
      body: query,
    );

    if (qRes.body != null &&
        qRes.body!.result != null &&
        validateResponse(qRes)) {
      Map<String, dynamic>? json = qRes.body!.result as Map<String, dynamic>?;

      if (json != null) {
        List<dynamic> hits = json['hits']['hits'];

        if (hits.isNotEmpty) {
          Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
          Map<String, dynamic> source = obj['p_source'] as Map<String, dynamic>;
          Map<String, dynamic> data = source['data'] as Map<String, dynamic>;

          for (var field in fields) {
            fieldValues[field] = data[field] ?? 0.0;
          }
        }
      }
    }

    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}

class DeviceMultiFieldRadialAxisWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceMultiFieldRadialAxisWidget(
        config: DeviceMultiFieldRadialAxisWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.radar_outlined);
  }

  @override
  String getPaletteName() {
    return "Multi Radial Axis Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return DeviceMultiFieldRadialAxisWidgetConfig.fromJson(config);
    }
    return DeviceMultiFieldRadialAxisWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Multi Radial Axis Widget";
  }
}
