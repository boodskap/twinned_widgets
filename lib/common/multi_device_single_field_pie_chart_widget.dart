import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/multi_device_single_field_pie_chart/multi_device_single_field_pie_chart.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/models.dart';

class DeviceData {
  final String deviceName;
  final double value;

  DeviceData(this.deviceName, this.value);
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
  bool loading = false;
  late List<String> deviceIds;
  late String field;
  late String title;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig labelFont;
  bool isValidConfig = false;

  @override
  void initState() {
    deviceIds = widget.config.deviceIds;
    field = widget.config.field;
    title = widget.config.title;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);
    isValidConfig = deviceIds.isNotEmpty && field.isNotEmpty;
    super.initState();
  }

  Future loadDeviceData() async {
    if (loading) return;
    loading = true;

    List<DeviceData> fetchedData = [];

    for (var deviceId in deviceIds) {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: ["data.$field", "deviceId", "updatedStamp", "deviceName"],
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
      // debugPrint(qRes.body.toString());
      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];

        if (values.isNotEmpty) {
          var obj = values.first;
          double value = obj['p_source']['data'][field].toDouble();
          String deviceName = obj['p_source']['deviceName'];
          fetchedData.add(DeviceData(deviceName, value));
        }
      }
    }

    setState(() {
      deviceData = fetchedData;
      loading = false;
    });
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

    return Center(
      child: loading
          ? const CircularProgressIndicator()
          : SfCircularChart(
              legend: Legend(
                  isVisible:widget.config.legendVisibility ,
                  textStyle: TwinUtils.getTextStyle(
                      FontConfig.fromJson(widget.config.labelFont))),
              series: <CircularSeries>[
                PieSeries<DeviceData, String>(
                  pointColorMapper: (DeviceData data, _) => Color(
                    widget.config.chartColors[deviceData.indexOf(data)],
                  ),
                  dataSource: deviceData,
                  xValueMapper: (DeviceData data, _) => data.deviceName,
                  yValueMapper: (DeviceData data, _) => data.value,
                  dataLabelMapper: (DeviceData data, _) =>
                      'label: ${data.value}',
                  dataLabelSettings:  DataLabelSettings(textStyle:TwinUtils.getTextStyle(
                      FontConfig.fromJson(widget.config.valueFont)) ,
                    isVisible: widget.config.dataLabelVisibility,
                    labelPosition: ChartDataLabelPosition.outside,
                    borderColor: Colors.red,
                    color: Colors.red,
                    overflowMode: OverflowMode.shift,
                    alignment: ChartAlignment.center,
                    angle: 0,
                    borderWidth: 5,
                    borderRadius: 3,
                    opacity: 1.0,
                  ),
                  enableTooltip: true,
                  explodeIndex: 3,
                  explodeGesture: ActivationMode.singleTap,
                  legendIconType: LegendIconType.rectangle,
                  explode: true,
                  opacity: 1,
                  animationDelay: 100,
                  radius: "100",
                  strokeColor: Colors.black87,
                  startAngle: 0,
                ),
              ],
            ),
    );
  }

  @override
  void setup() {
    loadDeviceData();
  }
}

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
