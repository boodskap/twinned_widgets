import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_models/speedometer_widget/speedometer_widget.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class SpeedometerWidget extends StatefulWidget {
  final SpeedometerWidgetConfig config;
  const SpeedometerWidget({super.key, required this.config});

  @override
  State<SpeedometerWidget> createState() => _SpeedometerWidgetState();
}

class _SpeedometerWidgetState extends BaseState<SpeedometerWidget> {
  late String title;
  late String deviceId;
  late String field;
  late double minimum;
  late double maximum;
  late double positionFactor;
  late bool showLabel;
  late bool showTicks;
  late Color axisColor;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig unitFont;

  double speedvalue = 0;
  bool isValidConfig = false;

  @override
  void initState() {
    var config = widget.config;
    title = config.title;
    deviceId = config.deviceId;
    field = config.field;
    minimum = config.minimum;
    maximum = config.maximum;
    positionFactor = config.positionFactor;
    showLabel = config.showLabel;
    showTicks = config.showTicks;
    axisColor = Color(config.axisColor);
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    unitFont = FontConfig.fromJson(config.unitFont);

    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Wrap(
          spacing: 8,
          children: [
            Text(
              'Not Configured Properly',
              style:
                  TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }

    return Center(
      child: SfRadialGauge(
        axes: <RadialAxis>[
          // Main Axis (Outer line Speedometer)
          RadialAxis(
            axisLineStyle: AxisLineStyle(
              color: axisColor,
              thickness: 10,
            ),
            minimum: minimum,
            maximum: maximum,
            showTicks: false,
            showLabels: false,
          ),
          // Inner Axis (main value is displayed in speedometer)
          RadialAxis(
            radiusFactor: 0.9,
            minimum: minimum,
            maximum: minimum,
            showLabels: showLabel,
            showTicks: showTicks,
            minorTickStyle:
                MinorTickStyle(color: axisColor, length: 15, thickness: 2),
            majorTickStyle:
                MajorTickStyle(thickness: 3, length: 25, color: axisColor),
            axisLineStyle: const AxisLineStyle(
              thickness: 0.1,
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: speedvalue,
                color: axisColor,
                width: 0.1,
                sizeUnit: GaugeSizeUnit.factor,
              ),
            ],
            annotations: <GaugeAnnotation>[
              const GaugeAnnotation(
                widget: Text(
                  'value%',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                angle: 90,
                positionFactor: 0,
              ),
              GaugeAnnotation(
                widget: const Text(
                  ' km/h',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                angle: 90,
                positionFactor: positionFactor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _load() async {
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
        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;

        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            var value = obj['p_source']['data'][field];
            setState(() {
              speedvalue = value;
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
    _load();
  }
}

class SpeedometerWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return SpeedometerWidget(
      config: SpeedometerWidgetConfig.fromJson(config),
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
    return "Speedometer widget ";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return SpeedometerWidgetConfig.fromJson(config);
    }
    return SpeedometerWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Speedometer widget';
  }
}
