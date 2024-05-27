import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/minmaxavg/minmaxavg.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

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

  @override
  void initState() {
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;

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
        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
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
                  Expanded(
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
                                        color: Color(prefixFont.fontColor)),
                                  ),
                                  Text(
                                    '30',
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
                                    '90',
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
                                    '60',
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
                    ]),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void setup() {
    // load();
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
