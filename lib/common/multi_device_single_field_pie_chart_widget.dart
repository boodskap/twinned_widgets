import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/multi_device_single_field_pie_chart/multi_device_single_field_pie_chart.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class DeviceData {
  final String deviceName;
  final String assetId;
  final double value;

  DeviceData(this.deviceName, this.assetId, this.value);
}

class MultiDeviceSingleFieldPieChartWidget extends StatefulWidget {
  final MultiDeviceSingleFieldPieChartWidgetConfig config;
  const MultiDeviceSingleFieldPieChartWidget({super.key, required this.config});

  @override
  _MultiDeviceSingleFieldPieChartWidgetState createState() =>
      _MultiDeviceSingleFieldPieChartWidgetState();
}

class _MultiDeviceSingleFieldPieChartWidgetState
    extends BaseState<MultiDeviceSingleFieldPieChartWidget> {
  List<DeviceData> deviceData = [];
  bool isValidConfig = false;
  late List<String> deviceIds;
  late String field;
  late String title;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig labelFont;
  late List<Color> chartColors;
  late bool legendVisibility;
  late bool dataLabelVisibility;
  late bool enableTooltip;
  late bool explode;
  late LegendIconType legendIconType;
  late LegendPosition legendPosition;
  late Color labelBgColor;
  late Color labelBorderColor;
  late double angle;
  late double labelBorderRadius;
  late double labelBorderWidth;
  late double labelOpacity;
  late double opacity;
  late double chartRadius;
  late Color strokeColor;
  String label = "";

  @override
  void initState() {
    deviceIds = widget.config.deviceIds;
    field = widget.config.field;
    title = widget.config.title;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);

    chartColors =
        widget.config.chartColors.map((colorInt) => Color(colorInt)).toList();
    legendVisibility = widget.config.legendVisibility;
    dataLabelVisibility = widget.config.dataLabelVisibility;
    legendIconType = widget.config.iconType ;
    legendPosition = widget.config.legendPosition;
    labelBgColor = Color(widget.config.labelBgColor);
    labelBorderColor = Color(widget.config.labelBorderColor);
    angle = widget.config.angle;
    labelBorderRadius = widget.config.labelBorderRadius;
    labelBorderWidth = widget.config.labelBorderWidth;
    labelOpacity = widget.config.labelOpacity;
    enableTooltip = widget.config.enableTooltip;
    explode = widget.config.explode;
    opacity = widget.config.opacity;
    chartRadius = widget.config.chartRadius;
    strokeColor = Color(widget.config.strokeColor);

    isValidConfig = deviceIds.isNotEmpty &&
        field.isNotEmpty &&
        (chartColors.length == deviceIds.length);
    super.initState();
  }

  Future<void> load() async {
    // if (isValidConfig) return;
    if (loading) return;
    loading = true;

    List<DeviceData> fetchedData = [];

    await execute(() async {
      for (var deviceId in deviceIds) {
        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            source: [
              "data.$field",
              "deviceId",
              "updatedStamp",
              "deviceName",
              "asset"
            ],
            page: 0,
            size: 1,
            conditions: [],
            boolConditions: [],
            queryConditions: [],
            mustConditions: [
              {
                "exists": {"field": "data.$field"}
              },
              {
                "match_phrase": {"deviceId": deviceId}
              },
            ],
            sort: {'updatedStamp': 'desc'},
          ),
        );

        if (validateResponse(qRes)) {
          Map<String, dynamic> json =
              qRes.body!.result! as Map<String, dynamic>;
          List<dynamic> values = json['hits']['hits'];

          if (values.isNotEmpty) {
            var obj = values.first;
            double value = obj['p_source']['data'][field].toDouble();
            String deviceName = obj['p_source']['deviceName'];
            String assetName = obj['p_source']['asset'] ?? "--";

            Device? device = await TwinUtils.getDevice(deviceId: deviceId);
            if (device == null) continue;

            deviceName = device.name;
            DeviceModel? deviceModel =
                await TwinUtils.getDeviceModel(modelId: device.modelId);
            label = TwinUtils.getParameterLabel(field, deviceModel!);

            fetchedData.add(DeviceData(deviceName, assetName, value));
          }
        }
      }
    });
    setState(() {
      deviceData = fetchedData;
    });
    loading = false;
    refresh();
  }

  
  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not Configured Properly.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      children: [
        Text(
          title,
          style: TwinUtils.getTextStyle(titleFont),
        ),
        Center(
          child: loading
              ? const CircularProgressIndicator()
              : SfCircularChart(
                  legend: Legend(
                    position: legendPosition,
                    isVisible: legendVisibility,
                    textStyle: TwinUtils.getTextStyle(
                        FontConfig.fromJson(widget.config.labelFont)),
                  ),
                  series: <CircularSeries>[
                    PieSeries<DeviceData, String>(
                      pointColorMapper: (DeviceData data, _) =>
                          chartColors[deviceData.indexOf(data)],
                      dataSource: deviceData,
                      xValueMapper: (DeviceData data, _) => data.assetId == "--"
                          ? '${data.deviceName} --'
                          : '${data.deviceName} -- ${data.assetId}',
                      yValueMapper: (DeviceData data, _) => data.value,
                      dataLabelMapper: (DeviceData data, _) =>
                          '$label: ${data.value}',
                      dataLabelSettings: DataLabelSettings(
                        textStyle: TwinUtils.getTextStyle(
                            FontConfig.fromJson(widget.config.valueFont)),
                        isVisible: dataLabelVisibility,
                        labelPosition: widget.config.labelPosition ==
                                ChartDataLabelPosition.inside
                            ? ChartDataLabelPosition.inside
                            : ChartDataLabelPosition.outside,
                        borderColor: labelBorderColor,
                        color: labelBgColor,
                        overflowMode: OverflowMode.shift,
                        alignment: ChartAlignment.center,
                        angle: angle.toInt(),
                        borderWidth: labelBorderWidth,
                        borderRadius: labelBorderRadius,
                        opacity: labelOpacity,
                      ),
                      enableTooltip: enableTooltip,
                      explodeIndex: 3,
                      explodeGesture: ActivationMode.singleTap,
                      legendIconType: legendIconType,
                      explode: explode,
                      opacity: opacity,
                      animationDelay: 100,
                      radius: chartRadius.toString(),
                      strokeColor: strokeColor,
                      startAngle: 0,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  void setup() {
    load();
  }
}

class IconType {}

class MultiDeviceSingleFieldPieChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiDeviceSingleFieldPieChartWidget(
      config: MultiDeviceSingleFieldPieChartWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.pie_chart_rounded);
  }

  @override
  String getPaletteName() {
    return "Multi Device Single Field Pie Chart Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return MultiDeviceSingleFieldPieChartWidgetConfig.fromJson(config);
    }
    return MultiDeviceSingleFieldPieChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Multi Device Field Card Widget values';
  }
}
