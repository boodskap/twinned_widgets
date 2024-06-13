import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/multi_device_bar_chart/multi_device_bar_chart.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_api/twinned_api.dart';

class MultiDeviceBarChartWidget extends StatefulWidget {
  final MultiDeviceBarChartWidgetConfig config;
  const MultiDeviceBarChartWidget({super.key, required this.config});

  @override
  State<MultiDeviceBarChartWidget> createState() =>
      _MultiDeviceBarChartWidgetState();
}

class _MultiDeviceBarChartWidgetState
    extends BaseState<MultiDeviceBarChartWidget> {
  late String title;
  late List<String> deviceId;
  late String field;
  late FontConfig titleFont;
  late Color barColor;
  late double barWidth;
  late bool showTooltip;
  late BarChartType chartType;
  late BarChartDirection chartDirection;
  late Color barBorderColor;
  late Color chartBgColor;
  late Color chartAreaColor;
  late Color tooltipBgColor;
  late FontConfig tooltipFont;
  bool isValidConfig = false;

  final List<ChartData> _chartSeries = [];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    titleFont = FontConfig.fromJson(config.titleFont);
    barColor = config.barColor <= 0 ? Colors.black : Color(config.barColor);
    barWidth = config.barWidth;
    showTooltip = widget.config.showTooltip;
    chartType = widget.config.chartType;
    chartDirection = widget.config.chartDirection;
    barBorderColor = config.barBorderColor <= 0
        ? Colors.black
        : Color(config.barBorderColor);
    chartAreaColor = config.chartAreaColor <= 0
        ? Colors.black
        : Color(config.chartAreaColor);
    chartBgColor =
        config.chartBgColor <= 0 ? Colors.black : Color(config.chartBgColor);
    tooltipBgColor = config.tooltipBgColor <= 0
        ? Colors.black
        : Color(config.tooltipBgColor);
    tooltipFont = FontConfig.fromJson(config.tooltipFont);
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;

    _tooltip = TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          final ChartData chartData = data;
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${chartData.name}: ${chartData.value}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        });

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
    if (widget.config.chartType == BarChartType.rectangularBar &&
        widget.config.chartDirection == BarChartDirection.vertical) {
      return Center(
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat('MM/dd/yyyy HH:mm'),
          ),
          backgroundColor: chartBgColor,
          plotAreaBackgroundColor: chartAreaColor,
          title: ChartTitle(
            text: widget.config.title,
            textStyle: TextStyle(
              color: Color(titleFont.fontColor),
              fontSize: titleFont.fontSize,
              fontFamily: titleFont.fontFamily,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          tooltipBehavior: _tooltip,
          series: <CartesianSeries<ChartData, DateTime>>[
            ColumnSeries<ChartData, DateTime>(
              dataSource: _chartSeries,
              xValueMapper: (ChartData data, _) =>
                  DateTime.fromMillisecondsSinceEpoch(data.stamp),
              yValueMapper: (ChartData data, _) => data.value,
              borderColor: barBorderColor,
              enableTooltip: showTooltip,
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              color: barColor,
              width: barWidth,
            )
          ],
        ),
      );
    }

    if (widget.config.chartType == BarChartType.rectangularBar &&
        widget.config.chartDirection == BarChartDirection.horizontal) {
      return Center(
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat('MM/dd/yyyy HH:mm'),
          ),
          backgroundColor: chartBgColor,
          plotAreaBackgroundColor: chartAreaColor,
          title: ChartTitle(
            text: widget.config.title,
            textStyle: TextStyle(
              color: Color(titleFont.fontColor),
              fontSize: titleFont.fontSize,
              fontFamily: titleFont.fontFamily,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          tooltipBehavior: _tooltip,
          series: <CartesianSeries<ChartData, DateTime>>[
            BarSeries<ChartData, DateTime>(
              dataSource: _chartSeries,
              xValueMapper: (ChartData data, _) =>
                  DateTime.fromMillisecondsSinceEpoch(data.stamp),
              yValueMapper: (ChartData data, _) => data.value,
                            borderColor: barBorderColor,
              enableTooltip: showTooltip,
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              color: barColor,
              width: barWidth,
            )
          ],
        ),
      );
    }

    if (widget.config.chartType == BarChartType.roundedBar &&
        widget.config.chartDirection == BarChartDirection.vertical) {
      return Center(
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat('MM/dd/yyyy HH:mm'),
          ),
          backgroundColor: chartBgColor,
          plotAreaBackgroundColor: chartAreaColor,
          title: ChartTitle(
            text: widget.config.title,
            textStyle: TextStyle(
              color: Color(titleFont.fontColor),
              fontSize: titleFont.fontSize,
              fontFamily: titleFont.fontFamily,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          tooltipBehavior: _tooltip,
          series: <CartesianSeries<ChartData, DateTime>>[
            ColumnSeries<ChartData, DateTime>(
              dataSource: _chartSeries,
              xValueMapper: (ChartData data, _) =>
                  DateTime.fromMillisecondsSinceEpoch(data.stamp),
              yValueMapper: (ChartData data, _) => data.value,
                            borderColor: barBorderColor,
              enableTooltip: showTooltip,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: barColor,
              width: barWidth,
            )
          ],
        ),
      );
    }

    if (widget.config.chartType == BarChartType.roundedBar &&
        widget.config.chartDirection == BarChartDirection.horizontal) {
      return Center(
        child: SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat('MM/dd/yyyy HH:mm'),
          ),
          backgroundColor: chartBgColor,
          plotAreaBackgroundColor: chartAreaColor,
          title: ChartTitle(
            text: widget.config.title,
            textStyle: TextStyle(
              color: Color(titleFont.fontColor),
              fontSize: titleFont.fontSize,
              fontFamily: titleFont.fontFamily,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          tooltipBehavior: _tooltip,
          series: <CartesianSeries<ChartData, DateTime>>[
            BarSeries<ChartData, DateTime>(
              dataSource: _chartSeries,
              xValueMapper: (ChartData data, _) =>
                  DateTime.fromMillisecondsSinceEpoch(data.stamp),
              yValueMapper: (ChartData data, _) => data.value,
                                       borderColor: barBorderColor,
              enableTooltip: showTooltip,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: barColor,
              width: barWidth,
            )
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    _chartSeries.clear();

    await execute(() async {
      var deviceIds = widget.config.deviceId;
      for (var i = 0; i < deviceIds.length; i++) {
        var deviceId = deviceIds[i];
        var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            source: ["data.$field", "deviceId", "updatedStamp", "deviceName"],
            page: 0,
            size: 100,
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
            for (Map<String, dynamic> obj in values) {
              int millis = obj['p_source']['updatedStamp'];

              dynamic value = obj['p_source']['data'][widget.config.field];
              String name = obj['p_source']['deviceName'];
              _chartSeries
                  .add(ChartData(stamp: millis, value: value, name: name));
            }
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

class ChartData {
  final dynamic stamp;
  final dynamic value;
  final String name;
  ChartData({required this.name, required this.stamp, required this.value});
}

class MultiDeviceBarChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiDeviceBarChartWidget(
        config: MultiDeviceBarChartWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.bar_chart);
  }

  @override
  String getPaletteName() {
    return "Multi Device Bar Chart";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return MultiDeviceBarChartWidgetConfig.fromJson(config);
    }
    return MultiDeviceBarChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Bar Chart based on Multi Device';
  }
}
