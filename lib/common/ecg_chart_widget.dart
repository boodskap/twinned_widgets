import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_models/ecg_graph_widget/ecg_graph_widget.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class ChartData {
  final int x;
  final double y;
  final String formattedTime;

  ChartData({required this.x, required this.y, required this.formattedTime});
}

class EcgChartWidget extends StatefulWidget {
  final EcgGraphWidgetConfig config;
  const EcgChartWidget({
    super.key,
    required this.config,
  });

  @override
  State<EcgChartWidget> createState() => _EcgChartWidgetState();
}

class _EcgChartWidgetState extends BaseState<EcgChartWidget> {
  bool isValidConfig = false;
  List<ChartData> _chartData = [];
  late String title;
  late String deviceId;
  late String field;
  late FontConfig titleFont;
  late Color borderColor;
  late Color chartBgColor;
  late double borderWidth;
  String fieldName = '--';
  String unit = '--';

  @override
  void initState() {
    var config = widget.config;
    title = config.title;
    deviceId = config.deviceId;
    field = config.field;
    borderColor = Color(config.chartLineColor);
    chartBgColor = Color(config.chartBgColor);
    borderWidth = config.borderWidth;
    titleFont = FontConfig.fromJson(config.titleFont);

    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Center(
      child: Card(
        color: Colors.white,
        elevation: 4,
        child: SfCartesianChart(
          title: ChartTitle(
            text: title.isNotEmpty ? title : "--",
            textStyle: TwinUtils.getTextStyle(titleFont),
            alignment: ChartAlignment.near,
          ),
          primaryXAxis: const NumericAxis(
            isVisible: false,
          ),
          primaryYAxis: const NumericAxis(
            isVisible: true,
            axisLine: AxisLine(),
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              ChartData chartData = data;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fieldName.isNotEmpty ? fieldName : '--',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text('${chartData.formattedTime} : ${chartData.y}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            },
          ),
          plotAreaBackgroundColor: chartBgColor,
          enableAxisAnimation: true,
          series: <CartesianSeries<ChartData, int>>[
            LineSeries<ChartData, int>(
              color: borderColor,
              width: borderWidth,
              animationDuration: 1000,
              dataSource: _chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(
                isVisible: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 10000,
          source: [],
          mustConditions: [
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
            {
              "exists": {"field": "data.$field"}
            },
          ],
          sort: {'updatedStamp': 'desc'},
          conditions: [],
          queryConditions: [],
          boolConditions: [],
        ),
      );

      if (validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (device == null) return;

        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);
        fieldName = TwinUtils.getParameterLabel(field, deviceModel!);
        unit = TwinUtils.getParameterUnit(field, deviceModel);
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        _chartData.clear(); // Clear previous data before loading new data

        for (Map<String, dynamic> obj in values) {
          int millis = obj['p_source']['updatedStamp'];
          dynamic value = obj['p_source']['data'][widget.config.field];

          String formattedTime = DateFormat('HH:mm:ss')
              .format(DateTime.fromMillisecondsSinceEpoch(millis));

          _chartData.add(ChartData(
              x: millis, y: value.toDouble(), formattedTime: formattedTime));
        }

        if (_chartData.length > 100) {
          _chartData = _chartData.sublist(0, 100);
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

class EcgChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return EcgChartWidget(
      config: EcgGraphWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.line_axis);
  }

  @override
  String getPaletteName() {
    return "ECG Chart widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return EcgGraphWidgetConfig.fromJson(config);
    }
    return EcgGraphWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'ECG Chart widget';
  }
}
