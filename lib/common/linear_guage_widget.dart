import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/linear_guage/linear_guage.dart';

class LinearGuageWidget extends StatefulWidget {
  final LinearGuageWidgetConfig config;
  const LinearGuageWidget({super.key, required this.config});

  @override
  State<LinearGuageWidget> createState() => _LinearGuageWidgetState();
}

class _LinearGuageWidgetState extends BaseState<LinearGuageWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String title;
  late String deviceId;
  late String field;
  late FontConfig titleFont;
  late Color color;
  late double min;
  late double max;
  late double thickness;
  late double opacity;
  late double interval;
  late double height;
  late OrientationType orientationType;
  double value = 0;

  @override
  void initState() {
    var config = widget.config;
    isValidConfig =
        widget.config.field.isNotEmpty && widget.config.deviceId.isNotEmpty;
    title = config.title;
    field = config.field;
    deviceId = config.deviceId;
    titleFont = FontConfig.fromJson(config.titleFont);
    color = Color(config.color);
    min = config.min;
    max = config.max;
    thickness = config.thickness;
    opacity = config.opacity;
    interval = config.interval;
    height = config.height;
    orientationType = config.orientationType;

    super.initState();
  }

  LinearGaugeOrientation _orientationType(OrientationType type) {
    switch (type) {
      case OrientationType.horizontal:
        return LinearGaugeOrientation.horizontal;
      default:
        return LinearGaugeOrientation.vertical;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly',
            style: TextStyle(
                color: Color.fromARGB(255, 133, 11, 3),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (title != "")
          Text(title,
              style: TextStyle(
                  fontFamily: titleFont.fontFamily,
                  fontSize: titleFont.fontSize,
                  fontWeight:
                      titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(titleFont.fontColor))),
        SizedBox(
          height: height,
          child: SfLinearGauge(
            minimum: min,
            maximum: max,
            orientation: _orientationType(orientationType),
            axisTrackStyle: LinearAxisTrackStyle(
              color: color.withOpacity(opacity),
              thickness: thickness,
            ),
            interval: interval,
            markerPointers: [
              LinearShapePointer(
                value: value,
                color: color,
                onChanged: (val) {
                  setState(() {
                    value = val;
                  });
                },
              ),
            ],
            barPointers: [
              LinearBarPointer(
                value: value,
                color: color,
              ),
            ],
          ),
        )
      ],
    );
  }

  Future _load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
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
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
             {
                "exists": {"field": "data.${widget.config.field}"}
              },
          ],
         sort: {'updatedStamp': 'desc'})
        
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            value = obj['p_source']['data'][widget.config.field];
            if (value < min) {
              value = min;
            } else if (value > max) {
              value = max;
            }
          }
        }
      }
    });

    loading = false;
    apiLoadingStatus = true;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}



class LinearGuageWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return LinearGuageWidget(config: LinearGuageWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.linear_scale);
  }

  @override
  String getPaletteName() {
    return "Linear Guage";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return LinearGuageWidgetConfig.fromJson(config);
    }
    return LinearGuageWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Linear Guage";
  }
}
