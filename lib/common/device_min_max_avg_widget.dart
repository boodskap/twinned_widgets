import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/minmaxavg/minmaxavg.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'dart:math';

class DeviceMinMaxAvgWidget extends StatefulWidget {
  final DeviceMinMaxAvgWidgetConfig config;
  const DeviceMinMaxAvgWidget({super.key, required this.config});

  @override
  State<DeviceMinMaxAvgWidget> createState() => _DeviceMinMaxAvgWidgetState();
}

class _DeviceMinMaxAvgWidgetState extends BaseState<DeviceMinMaxAvgWidget> {
  bool isValidConfig = false;
  late String field;
  late String deviceId;
  late String title;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig prefixFont;
  late FontConfig suffixFont;
  late FontConfig labelFont;
  late String minLabel;
  late String maxLabel;
  late String avgLabel;
  late Color minBgColor;
  late Color maxBgColor;
  late Color avgBgColor;
  late Color borderColor;
  late double borderWidth;
  late double labelSpacing;

  String minValue = '';
  String avgValue = '';
  String maxValue = '';

  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    prefixFont = FontConfig.fromJson(config.prefixFont);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    minLabel = config.minLabel;
    maxLabel = config.maxLabel;
    avgLabel = config.avgLabel;
    minBgColor = Color(config.minBgColor);
    maxBgColor = Color(config.maxBgColor);
    avgBgColor = Color(config.avgBgColor);
    borderColor = Color(config.borderColor);
    borderWidth = config.borderWidth;

    labelSpacing = config.labelSpacing;

    isValidConfig = field.isNotEmpty;
    isValidConfig = isValidConfig && deviceId.isNotEmpty;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly',
            style:
                TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    return Center(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      color: Color(
                        widget.config.titleBgColor,
                      ),
                      child: Text(
                        widget.config.title,
                        style: TextStyle(
                          fontFamily: titleFont.fontFamily,
                          fontSize: titleFont.fontSize,
                          fontWeight: titleFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(
                            titleFont.fontColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: widget.config.borderWidth,
                      color: Color(
                        widget.config.borderColor,
                      ),
                    ),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        color: Color(widget.config.minBgColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.config.prefixLabel,
                                  style: TextStyle(
                                    fontWeight: prefixFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: prefixFont.fontSize,
                                    color: Color(prefixFont.fontColor),
                                  ),
                                ),
                                Text(
                                  minValue,
                                  style: TextStyle(
                                    fontWeight: valueFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: valueFont.fontSize,
                                    color: Color(valueFont.fontColor),
                                  ),
                                ),
                                Text(
                                  widget.config.suffixLabel,
                                  style: TextStyle(
                                      fontWeight: suffixFont.fontBold
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: suffixFont.fontSize,
                                      color: Color(suffixFont.fontColor)),
                                ),
                              ],
                            ),
                            SizedBox(height: labelSpacing),
                            Text(
                              widget.config.minLabel,
                              style: TextStyle(
                                  fontWeight: labelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: labelFont.fontSize,
                                  color: Color(labelFont.fontColor)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Color(widget.config.avgBgColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.config.prefixLabel,
                                  style: TextStyle(
                                      fontWeight: prefixFont.fontBold
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: prefixFont.fontSize,
                                      color: Color(prefixFont.fontColor)),
                                ),
                                Text(
                                  avgValue,
                                  style: TextStyle(
                                    fontWeight: valueFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: valueFont.fontSize,
                                    color: Color(valueFont.fontColor),
                                  ),
                                ),
                                Text(
                                  widget.config.suffixLabel,
                                  style: TextStyle(
                                      fontWeight: suffixFont.fontBold
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: suffixFont.fontSize,
                                      color: Color(suffixFont.fontColor)),
                                ),
                              ],
                            ),
                            SizedBox(height: labelSpacing),
                            Text(
                              widget.config.avgLabel,
                              style: TextStyle(
                                  fontWeight: labelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: labelFont.fontSize,
                                  color: Color(labelFont.fontColor)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Color(widget.config.maxBgColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.config.prefixLabel,
                                  style: TextStyle(
                                      fontWeight: prefixFont.fontBold
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: prefixFont.fontSize,
                                      color: Color(prefixFont.fontColor)),
                                ),
                                Text(
                                  maxValue,
                                  style: TextStyle(
                                    fontWeight: valueFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: valueFont.fontSize,
                                    color: Color(valueFont.fontColor),
                                  ),
                                ),
                                Text(
                                  widget.config.suffixLabel,
                                  style: TextStyle(
                                      fontWeight: suffixFont.fontBold
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: suffixFont.fontSize,
                                      color: Color(suffixFont.fontColor)),
                                ),
                              ],
                            ),
                            SizedBox(height: labelSpacing),
                            Text(
                              widget.config.maxLabel,
                              style: TextStyle(
                                  fontWeight: labelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: labelFont.fontSize,
                                  color: Color(labelFont.fontColor)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future load() async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: [],
          page: 0,
          size: 0,
          mustConditions: [
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
            {
              "exists": {"field": "data.${widget.config.field}"}
            },
          ],
          conditions: [
            EqlCondition(name: 'aggs', condition: {
              "min": {
                "min": {"field": "data.$field"}
              },
              "max": {
                "max": {"field": "data.$field"}
              },
              "avg": {
                "avg": {"field": "data.$field"}
              }
            })
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        num min = json['aggregations']['min']['value'] ?? 0;
        num avg = json['aggregations']['avg']['value'] ?? 0;
        num max = json['aggregations']['max']['value'] ?? 0;

        minValue = min.toStringAsFixed(2);
        avgValue = avg.toStringAsFixed(2);
        maxValue = max.toStringAsFixed(2);
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

class DeviceMinMaxAvgWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceMinMaxAvgWidget(
        config: DeviceMinMaxAvgWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.unfold_less_double_sharp);
  }

  @override
  String getPaletteName() {
    return "Min Max Avg Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceMinMaxAvgWidgetConfig.fromJson(config);
    }
    return DeviceMinMaxAvgWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'device field min max avg values';
  }
}
