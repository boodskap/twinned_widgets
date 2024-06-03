import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/range_label_dial/range_label_dial.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_widgets/twinned_widgets.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DeviceFieldRangeLabelDialWidget extends StatefulWidget {
  final DeviceFieldRangeLabelDialWidgetConfig config;
  const DeviceFieldRangeLabelDialWidget({super.key, required this.config});

  @override
  State<DeviceFieldRangeLabelDialWidget> createState() =>
      _DeviceFieldRangeLabelDialWidgetState();
}

class _DeviceFieldRangeLabelDialWidgetState
    extends BaseState<DeviceFieldRangeLabelDialWidget> {
  bool isValidConfig = false;
  late String field;
  late String deviceId;
  late String title;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late FontConfig valueFont;
  late Color titleBgColor;
  late bool animate;
  dynamic temperatureValue;
  dynamic volume;
  dynamic value;

  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    titleBgColor = Color(config.titleBgColor);
    animate = config.gaugeAnimate;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);

    isValidConfig = isValidConfig && deviceId.isNotEmpty;
    isValidConfig = field.isNotEmpty;
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
    return Center(
      child: SfRadialGauge(
        enableLoadingAnimation: animate,
        title: GaugeTitle(
          backgroundColor: titleBgColor,
          text: title,
          textStyle: TextStyle(
            fontFamily: titleFont.fontFamily,
            fontSize: titleFont.fontSize,
            fontWeight:
                titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            color: Color(titleFont.fontColor),
          ),
        ),
        axes: [
          RadialAxis(
            pointers: [
              NeedlePointer(
                enableAnimation: animate,
                value: value ?? 0.0,
              )
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  value != null ? '$value' : '-',
                  style: TextStyle(
                    color: Color(valueFont.fontColor),
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
            axisLineStyle: const AxisLineStyle(
              thickness: 100,
            ),
            minimum: 0,
            maximum: 100,
            showLabels: true,
            radiusFactor: 0.9,
            ranges: [
              GaugeRange(
                labelStyle: GaugeTextStyle(
                  fontFamily: labelFont.fontFamily,
                  color: Color(labelFont.fontColor),
                  fontSize: labelFont.fontSize,
                  fontWeight:
                      labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                ),
                startWidth: 100,
                endWidth: 100,
                startValue: 0,
                endValue: 40,
                color: Colors.green,
                label: 'Low',
              ),
              GaugeRange(
                labelStyle: GaugeTextStyle(
                  fontFamily: labelFont.fontFamily,
                  color: Color(labelFont.fontColor),
                  fontSize: labelFont.fontSize,
                  fontWeight:
                      labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                ),
                startWidth: 100,
                endWidth: 100,
                startValue: 40,
                endValue: 70,
                color: Colors.yellow,
                label: 'Medium',
              ),
              GaugeRange(
                labelStyle: GaugeTextStyle(
                  fontFamily: labelFont.fontFamily,
                  color: Color(labelFont.fontColor),
                  fontSize: labelFont.fontSize,
                  fontWeight:
                      labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                ),
                startWidth: 100,
                endWidth: 100,
                startValue: 70,
                endValue: 100,
                color: Colors.red,
                label: 'High',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void setup() {
    load();
  }

  Future<void> load() async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    try {
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
                ]));

        if (qRes.body != null &&
            qRes.body!.result != null &&
            validateResponse(qRes)) {
          Map<String, dynamic>? json =
              qRes.body!.result! as Map<String, dynamic>?;

          if (json != null) {
            List<dynamic> hits = json['hits']['hits'];

            if (hits.isNotEmpty) {
              Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
              // Map<String, dynamic> source =
              //     obj['p_source'] as Map<String, dynamic>;
              // Map<String, dynamic> data =
              //     source['data'] as Map<String, dynamic>;
              value = obj['p_source']['data'][widget.config.field];
              debugPrint(value.toString());
              // debugPrint('temperature_value: $temperatureValue');
              // debugPrint('volume: $volume');
            } else {
              debugPrint('No hits found in response.');
            }
          } else {
            debugPrint('Failed to parse JSON response.');
          }
        } else {
          debugPrint('Failed to validate response: ${qRes.statusCode}');
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
}

class DeviceFieldRangeLabelDialWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldRangeLabelDialWidget(
        config: DeviceFieldRangeLabelDialWidgetConfig.fromJson(config));
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
    return "Range Label Dial";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceFieldRangeLabelDialWidgetConfig.fromJson(config);
    }
    return DeviceFieldRangeLabelDialWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Range label dial show on the field';
  }
}
