import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/progress/progress.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
  late Color fillColor;
  late Color titleBgColor;
  late Color unfillColor;
  late double circularRadius;
  late double progressbarWidth;
  late PercentageWidgetShape widgetShape;
  late FontConfig titleFont;
  late FontConfig labelFont;
  dynamic value;
  double? rawValue;

  bool isValidConfig = false;

  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    fillColor = Color(config.fillColor);
    unfillColor = Color(config.unfillColor);
    titleBgColor = Color(config.titleBgColor);
    circularRadius = config.circularRadius;
    progressbarWidth = config.progressbarWidth;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    widgetShape = config.shape;
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

    if (widget.config.shape == PercentageWidgetShape.linear) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: titleBgColor,
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
            child: Center(
              child: LinearPercentIndicator(
                animation: true,
                lineHeight: progressbarWidth,
                animationDuration: 2500,
                percent: value ?? 0.0,
                center: Text(
                  value != null ? '$rawValue%' : '',
                  style: TextStyle(
                      fontFamily: labelFont.fontFamily,
                      fontSize: labelFont.fontSize,
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(labelFont.fontColor)),
                ),
                progressColor: fillColor,
                backgroundColor: unfillColor,
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
                  color: titleBgColor,
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
            child: Center(
              child: CircularPercentIndicator(
                radius: circularRadius,
                lineWidth: progressbarWidth,
                animation: true,
                percent: value ?? 0.0,
                center: Text(
                  value != null ? '$rawValue%' : '',
                  style: TextStyle(
                      fontFamily: labelFont.fontFamily,
                      fontSize: labelFont.fontSize,
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(labelFont.fontColor)),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: fillColor,
                backgroundColor: unfillColor,
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
            if (rawValue! < 0) {
              rawValue = 0;
            } else if (rawValue! > 100) {
              rawValue = 100;
            }
            value = (rawValue! / 100.0).clamp(0.0, 1.0);
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
    return const Icon(Icons.data_usage);
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
