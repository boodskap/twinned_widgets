import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/progress/progress.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';

class DeviceFieldPercentageWidget extends StatefulWidget {
  final DeviceFieldPercentageWidgetConfig config;
  const DeviceFieldPercentageWidget({super.key, required this.config});

  @override
  State<DeviceFieldPercentageWidget> createState() =>
      _DeviceFieldPercentageWidgetState();
}

class _DeviceFieldPercentageWidgetState
    extends BaseState<DeviceFieldPercentageWidget> {
  late String field;
  late String deviceId;
  late Color bgColor;
  late Color fillColor;
  late Color borderColor;
  late double borderRadius;
  late double borderWidth;
  late PercentageWidgetShape widgetShape;
  late Axis waveDirection;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late bool animate;
  double? value;
  double? rawValue;

  bool isValidConfig = false;

  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    bgColor = Color(config.bgColor);
    fillColor = Color(config.fillColor);
    borderColor = Color(config.borderColor);
    borderRadius = config.borderRadius;
    borderWidth = config.borderWidth;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    widgetShape = config.shape;
    waveDirection = config.waveDirection;
    animate = config.animate;

    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Wrap(
        spacing: 8,
        children: [
          Text(
            'Not configured properly',
            style: TextStyle(
              color: Colors.red,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (widget.config.shape == PercentageWidgetShape.rectangle) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.teal,
                  child: Text(
                    widget.config.title,
                    style: TextStyle(
                      fontFamily: titleFont.fontFamily,
                      fontSize: titleFont.fontSize,
                      fontWeight: titleFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(titleFont.fontColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: LiquidLinearProgressIndicator(
              value: value ?? 0.0,
              valueColor: AlwaysStoppedAnimation(fillColor),
              backgroundColor: bgColor,
              borderColor: borderColor,
              borderWidth: borderWidth,
              borderRadius: borderRadius,
              direction: waveDirection,
              center: Text(
                value != null ? '$rawValue%' : '',
                style: TextStyle(
                  fontFamily: labelFont.fontFamily,
                  fontSize: labelFont.fontSize,
                  fontWeight:
                      labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(labelFont.fontColor)
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.config.shape == PercentageWidgetShape.circle) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.teal,
                  child: Text(
                    widget.config.title,
                    style: TextStyle(
                      fontFamily: titleFont.fontFamily,
                      fontSize: titleFont.fontSize,
                      fontWeight: titleFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(titleFont.fontColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: LiquidCircularProgressIndicator(
              value: value ?? 0.0,
              valueColor: AlwaysStoppedAnimation(fillColor),
              backgroundColor: bgColor,
              borderColor: borderColor,
              borderWidth: borderWidth,
              direction: waveDirection,
               center: Text(
                value != null ? '$rawValue%' : '',
                style: TextStyle(
                  fontFamily: labelFont.fontFamily,
                  fontSize: labelFont.fontSize,
                  fontWeight:
                      labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(labelFont.fontColor)
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 100,
          source: ["data.$field"],
          mustConditions: [
            {
              "exists": {"field": "data.$field"}
            },
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            rawValue = obj['p_source']['data'][widget.config.field];
            value = (rawValue! / 100.0).clamp(0.0, 1.0);
            debugPrint('rawvalue-----> ${rawValue.toString()}');
            debugPrint('-----------------------------');
            debugPrint('value-----> ${value.toString()}');
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

class DeviceFieldPercentageWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldPercentageWidget(
        config: DeviceFieldPercentageWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.stacked_line_chart);
  }

  @override
  String getPaletteName() {
    return "Percentage Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceFieldPercentageWidgetConfig.fromJson(config);
    }
    return DeviceFieldPercentageWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Percentage show on the field';
  }
}
