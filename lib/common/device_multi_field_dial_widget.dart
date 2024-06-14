import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/dial/dial.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_models/models.dart';

class DeviceMultiFieldDialWidget extends StatefulWidget {
  final DeviceMultiFieldDialWidgetConfig config;

  const DeviceMultiFieldDialWidget({super.key, required this.config});

  @override
  State<DeviceMultiFieldDialWidget> createState() =>
      _DeviceMultiFieldDialWidgetState();
}

class _DeviceMultiFieldDialWidgetState
    extends BaseState<DeviceMultiFieldDialWidget> {
  final TextStyle labelStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  bool isConfigValid = false;
  late String deviceId;
  late List<String> fields;
  Map<String, dynamic> fieldValues = {};
  late String title;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late Color titleBgColor;
  late double positionFactor;
  late double radiusFactor;
  late double axisThickness;
  late double needleLength;
  late double angle;
  late bool gaugeAnimate;

  void _initState() {
    fields = widget.config.field;
    deviceId = widget.config.deviceId;
    title = widget.config.title;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);
    titleBgColor = Color(widget.config.titleBgColor);
    positionFactor = widget.config.positionFactor;
    radiusFactor = widget.config.radiusFactor;
    axisThickness = widget.config.axisThickness;
    angle = widget.config.angle;
    needleLength = widget.config.needleLength;
    gaugeAnimate = widget.config.gaugeAnimate;
    isConfigValid = fields.isNotEmpty &&
        deviceId.isNotEmpty &&
        (widget.config.field.length == widget.config.ranges.length);
  }

  @override
  Widget build(BuildContext context) {
    _initState();
    if (!isConfigValid) {
      return const Center(
          child: Text(
        'Not configured properly',
        style: TextStyle(color: Colors.red),
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              color: Color(
                widget.config.titleBgColor,
              ),
              child: Text(
                widget.config.title,
                style: TextStyle(
                  fontFamily: titleFont.fontFamily,
                  fontSize: titleFont.fontSize,
                  fontWeight:
                      titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(
                    titleFont.fontColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SfRadialGauge(
            axes: _buildRadialAxes(),
          ),
        ),
      ],
    );
  }

  List<RadialAxis> _buildRadialAxes() {
    List<RadialAxis> axes = [];

    int numFields = fields.length;
    double spacingFactor = 0.7 / numFields;

    for (int i = 0; i < numFields; i++) {
      var field = fields[i];
      Range range = Range.fromJson(widget.config.ranges[i]);
      if (fieldValues.containsKey(field)) {
        var value = fieldValues[field] ?? 0.0;
        double minValue = (value - 20 < 0) ? 0 : value - 20;
        double maxValue = value + 20;
        var labelField = range.label;
        axes.add(
          RadialAxis(
            minimum: minValue,
            maximum: maxValue,
            radiusFactor: radiusFactor + (i * spacingFactor),
            axisLineStyle: AxisLineStyle(
              thickness: axisThickness,
              color: Color(range.color ?? Colors.black.value),
            ),
            pointers: <GaugePointer>[
              NeedlePointer(
                value: value,
                enableAnimation: gaugeAnimate,
                animationDuration: 1000,
                needleStartWidth: 1,
                needleEndWidth: 5,
                needleLength: needleLength,
                knobStyle: const KnobStyle(knobRadius: 0.09),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  children: [
                    Text(
                      '$value  $labelField',
                      style: TextStyle(
                        fontSize: labelFont.fontSize,
                        fontWeight: labelFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: Color(range.color ?? Colors.black.value),
                      ),
                    ),
                  ],
                ),
                angle: angle,
                positionFactor: positionFactor,
                verticalAlignment: GaugeAlignment.near,
              ),
            ],
          ),
        );
      }
    }
    return axes;
  }

  Future<void> load() async {
    _initState();
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
        // debugPrint('Query: ${query.toJson()}');

        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: query,
        );

        // debugPrint('Response: ${qRes.body?.toJson()}');

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
          }
        }
      });
    } catch (e) {
      // debugPrint('Error loading data: $e');
      // debugPrint('Stack trace: $stackTrace');
    } finally {
      loading = false;
      refresh();
    }
  }

  @override
  void setup() {
    load();
  }
}

class DeviceMultiFieldDialWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceMultiFieldDialWidget(
      config: DeviceMultiFieldDialWidgetConfig.fromJson(config),
    );
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
    return "MultiField Radial Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return DeviceMultiFieldDialWidgetConfig.fromJson(config);
    }
    return DeviceMultiFieldDialWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Device multi field radial values';
  }
}
