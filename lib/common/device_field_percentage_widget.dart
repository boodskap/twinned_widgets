import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/progress/progress.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

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

  bool isValidConfig = false;

  @override
  void initState() {
    var config = widget.config;
    // bgColor = config.bgColor <=0 ? Colors.white : Color(config.bgColor);
    // fillColor = config.fillColor <=0? Colors.red : Color(config.fillColor);
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
      return LiquidLinearProgressIndicator(
        value: 0.85,
        valueColor: AlwaysStoppedAnimation(fillColor),
        backgroundColor: bgColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        direction: waveDirection,
        // center: const Text("Loading..."),
      );
    }

    if (widget.config.shape == PercentageWidgetShape.circle) {
      return LiquidCircularProgressIndicator(
        value: 0.8,
        valueColor: AlwaysStoppedAnimation(fillColor),
        backgroundColor: bgColor,
        borderColor: borderColor,
        borderWidth: borderWidth,
        direction: waveDirection,
      );
    }

    return const SizedBox.shrink();
  }

  // Future load({String? filter, String search = '*'}) async {
  //   if (!isValidConfig) return;

  //   if (loading) return;
  //   loading = true;

  //   await execute(() async {
  //     var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
  //       apikey: TwinnedSession.instance.authToken,
  //       body: EqlSearch(
  //         page: 0,
  //         size: 100,
  //         source: [],
  //         mustConditions: [
  //           {
  //             "exists": {"field": "data.volume"}
  //           },
  //           {
  //             "match_phrase": {"deviceId": widget.config.deviceId}
  //           },
  //         ],
  //         sort: {'updatedStamp': 'desc'},
  //       ),
  //     );

  //     if (validateResponse(qRes)) {
  //       Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
  //       List<dynamic> values = json['hits']['hits'];
  //       for (Map<String, dynamic> obj in values) {
  //         int millis = obj['p_source']['updatedStamp'];
  //         Map<String, dynamic> dataValues = {};
  //         // for (String field in widget.config.field) {
  //         //   dataValues[field] = obj['p_source']['data'][field];
  //         // }
  //         // _chatSeries.add(SeriesData(stamp: millis, values: dataValues));
  //       }
  //     }
  //   });

  //   loading = false;
  //   refresh();
  // }

  @override
  void setup() {}
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
