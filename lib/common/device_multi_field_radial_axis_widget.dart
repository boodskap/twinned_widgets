import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_models/device_multi_field_radial_axis/device_multi_field_radial_axis.dart';
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

    isConfigValid = fields.isNotEmpty && deviceId.isNotEmpty;

    
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

    return SizedBox(
      width: 500,
      height: 500,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        title: GaugeTitle(
          text: title,
          textStyle: TwinUtils.getTextStyle(titleFont),
        ),
        axes: fields.asMap().entries.map((entry) {
          int index = entry.key;
          String fieldName = entry.value;

          double value = fieldValues[fieldName]?.toDouble() ?? 0.0;

          Color fieldColor = Colors.blue; // Placeholder for actual field color
          double radiusFactor = 1 - (index * 0.1);

          return RadialAxis(
            pointers: [
              RangePointer(
                value: value, // Set the dynamic value for the RangePointer
                width: 20,
                color: fieldColor, // Use dynamic color
                enableAnimation: gaugeAnimate,
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 5, // Circle icon size
                      backgroundColor: fieldColor, // Same color as the pointer
                    ),
                    const SizedBox(width: 3), // Space between circle and text
                    Text(
                      fieldName, // Use the field's name as a label
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: fieldColor,
                      ),
                    ),
                  ],
                ),
                angle: 250 - (index * 5),
                positionFactor: 1,
                horizontalAlignment: GaugeAlignment.far,
              ),
            ],
            axisLineStyle: AxisLineStyle(
              thickness: 20,
              color: axisBgColor,
            ),
            minimum: 0,
            maximum: 100,
            startAngle: startAngle,
            endAngle: endAngle,
            showLabels: false,
            showTicks: false,
            radiusFactor: radiusFactor,
          );
        }).toList(),
      ),
    );
  }

  Future<void> _load() async {
    if (!isConfigValid) return;

    if (loading) return;
    loading = true;

    try {
      await execute(() async {
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
        print(qRes.body!.result.toString());

        if (qRes.body != null &&
            qRes.body!.result != null &&
            validateResponse(qRes)) {
          Map<String, dynamic>? json =
              qRes.body!.result! as Map<String, dynamic>?;

          if (json != null) {
            List<dynamic> hits = json['hits']['hits'];

            if (hits.isNotEmpty) {
              Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
              Map<String, dynamic> source =
                  obj['p_source'] as Map<String, dynamic>;
              Map<String, dynamic> data =
                  source['data'] as Map<String, dynamic>;

              for (var field in fields) {
                fieldValues[field] = data[field] ?? 0.0;
              }
            }
            debugPrint('Data output ************ $fieldValues');
          }
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading data: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      loading = false;
      refresh();
    }
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
