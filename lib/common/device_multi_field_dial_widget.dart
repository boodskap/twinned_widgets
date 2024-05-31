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
  bool isValidConfig = false;
  late String deviceId;
  late List<String> fields;
  Map<String, dynamic> fieldValues = {};

  @override
  void initState() {
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;
    fields = widget.config.field;
    deviceId = widget.config.deviceId;
    super.initState();

    // if (isValidConfig) {
    //   load();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 95,
          child: SfRadialGauge(
            axes: _buildRadialAxes(),
          ),
        ),
        Expanded(
          flex: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var field in fields)
                if (fieldValues.containsKey(field))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$field: ${fieldValues[field]}',
                      style: labelStyle,
                    ),
                  ),
            ],
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
      if (fieldValues.containsKey(field)) {
        var value = fieldValues[field] ?? 0.0;
        double minValue = (value - 20 < 0) ? 0 : value - 20;
        double maxValue = value + 20;
        var label = field == 'temperature_value' ? '°C' : '';

        axes.add(
          RadialAxis(
            minimum: minValue,
            maximum: maxValue,
            radiusFactor: 0.1 + (i * spacingFactor),
            axisLineStyle: const AxisLineStyle(
              thickness: 5,
              color: Colors.blue,
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
                widget: Text(
                  '$value$label',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                angle: 0,
                positionFactor: 0.9,
              ),
            ],
          ),
        );
      }
    }
    return axes;
  }

  Future<void> load() async {
    if (!isValidConfig) return;

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
            },
            for (var field in fields)
              {
                "exists": {"field": "data.$field"}
              }
          ],
        );
        debugPrint('Query: ${query.toJson()}');

        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: query,
        );

        debugPrint('Response: ${qRes.body?.toJson()}');

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
                fieldValues[field] = data[field];
              }

              for (var field in fields) {
                debugPrint('$field: ${fieldValues[field]}');
              }
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
