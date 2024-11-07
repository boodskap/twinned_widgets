import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/percentage_card_widget/device_field_percentage_card_widget.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class DeviceFieldPercentageCardWidget extends StatefulWidget {
  final DeviceFieldPercentageCardWidgetConfig config;
  const DeviceFieldPercentageCardWidget({super.key, required this.config});

  @override
  State<DeviceFieldPercentageCardWidget> createState() =>
      _DeviceFieldPercentageCardWidgetState();
}

class _DeviceFieldPercentageCardWidgetState
    extends BaseState<DeviceFieldPercentageCardWidget> {
  bool apiLoadingStatus = false;
  bool isValidConfig = false;
  late String deviceId;
  late String field;
  late FontConfig valueFont;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late double circleRadius;
  late double circleWidth;
  late double maximumValue;
  late double elevation;
  late Color percentageColor;
  late Color circleColor;
  String value = '-';
  String fieldLabel = '-';
  String fieldIcon = '-';
  String fieldDescription = '-';
  double percentValue = 0.0;
  double maxValue = 100;
  String unit = '';

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    field = config.field;
    circleWidth = config.circleWidth;
    circleRadius = config.circleRadius;
    circleColor = Color(config.circleColor);
    percentageColor = Color(config.percentageColor);
    elevation = config.elevation;
    maximumValue = config.maximumValue;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);
    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!isValidConfig) {
      return const Center(
        child: Text(
          "Not Configured Properly",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: Card(
              elevation: elevation,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: widget.config.gradientCardBgColor
                        .map((color) => Color(color))
                        .toList(),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (fieldIcon == "")
                              const Icon(
                                Icons.question_mark_rounded,
                                size: 80,
                                color: Colors.green,
                              ),
                            if (fieldIcon != "")
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                    width: 66,
                                    height: 60,
                                    child: TwinImageHelper.getDomainImage(
                                        fieldIcon)),
                              ),
                            const SizedBox(height: 15),
                            const SizedBox(height: 15),
                            Text(
                              fieldLabel,
                              style: TwinUtils.getTextStyle(titleFont),
                              softWrap: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$value ${unit.isEmpty ? '--' : unit}',
                                    style: TwinUtils.getTextStyle(labelFont)
                                      
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: CircularPercentIndicator(
                            lineWidth: circleWidth,
                            radius: circleRadius,
                            animation: true,
                            animationDuration: 1000,
                            backgroundColor: circleColor,
                            percent: percentValue,
                            progressColor: percentageColor,
                            center: Text(
                                '${(percentValue * 100).toStringAsFixed(1)}%',
                                style: TwinUtils.getTextStyle(valueFont)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _load() async {
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
              "match_phrase": {"deviceId": deviceId}
            },
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (device == null) return;
        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);
        if (deviceModel == null) return;

        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<String> deviceFields = TwinUtils.getSortedFields(deviceModel);
        List<dynamic> values = json['hits']['hits'];

        if (values.isNotEmpty) {
          Map<String, dynamic> obj = values[0];
          // int millis = obj['p_source']['updatedStamp'];

          Map<String, dynamic> data = obj['p_source']['data'];

          for (String deviceField in deviceFields) {
            if (deviceField == field) {
              refresh(sync: () {
                value = data[field].toString();
                unit = TwinUtils.getParameterUnit(field, deviceModel);
                fieldLabel = TwinUtils.getParameterLabel(field, deviceModel);
                fieldIcon = TwinUtils.getParameterIcon(field, deviceModel);
                fieldDescription = getParameterDescription(field, deviceModel);
              });
            }
          }
        }
      }

      double rawValue = double.tryParse(value) ?? 0.0;
      percentValue = (rawValue / maximumValue).clamp(0.0, 1.0);
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

getParameterDescription(String name, DeviceModel deviceModel) {
  for (var p in deviceModel.parameters) {
    if (p.name == name) {
      return p.description ?? '-';
    }
  }
  return '-';
}

class DeviceFieldPercentageCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldPercentageCardWidget(
        config: DeviceFieldPercentageCardWidgetConfig.fromJson(config));
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceFieldPercentageCardWidgetConfig.fromJson(config);
    }
    return DeviceFieldPercentageCardWidgetConfig();
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.percent_rounded);
  }

  @override
  String getPaletteName() {
    return 'Percentage Card Widget';
  }

  @override
  String getPaletteTooltip() {
    return 'Percentage Card Widget';
  }
}
