import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
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
  late bool isConfigValid;
  late String deviceId;
  late List<String> fields;
  Map<String, dynamic> fieldValues = {};
  late String title;
  late FontConfig titleFont;
  late Color titleBgColor;

  void _initState() {
    fields = widget.config.field;
    deviceId = widget.config.deviceId;
    title = widget.config.title;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    titleBgColor = Color(widget.config.titleBgColor);
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
          flex: 95,
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

    double spacingFactor = 0.8 / numFields;

    for (int i = 0; i < numFields; i++) {
      var field = fields[i];
      Range range = Range.fromJson(widget.config.ranges[i]);
      if (fieldValues.containsKey(field)) {
        var value = fieldValues[field] ?? 0.0;
        double minValue = range.from ?? 0;
        double maxValue = range.to ?? 100;
        var label = range.label;

        axes.add(
          RadialAxis(
            minimum: minValue,
            maximum: maxValue,
            radiusFactor: 0.1 + (i * spacingFactor),
            axisLineStyle: AxisLineStyle(
              thickness: 5,
              color: Color(range.color ?? Colors.black.value),
            ),
            pointers: <GaugePointer>[
              NeedlePointer(
                value: value,
                enableAnimation: true,
                animationDuration: 1000,
                needleStartWidth: 1,
                needleEndWidth: 5,
                needleLength: 0.8,
                knobStyle: const KnobStyle(knobRadius: 0.09),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                verticalAlignment: GaugeAlignment.center,
                widget: Row(
                  children: [
                    Text(
                      '$value$label',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                angle: 90,
                positionFactor: 1,
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
    } catch (e, stackTrace) {
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
