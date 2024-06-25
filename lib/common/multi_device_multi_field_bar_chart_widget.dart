import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/multi_device_multi_field_bar_chart/multi_device_multi_field_bar_chart.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:intl/intl.dart';

class MultiDeviceMultiFieldBarChartWidget extends StatefulWidget {
  final MultiDeviceMultiFieldBarChartWidgetConfig config;
  const MultiDeviceMultiFieldBarChartWidget({super.key, required this.config});

  @override
  State<MultiDeviceMultiFieldBarChartWidget> createState() =>
      _MultiDeviceMultiFieldBarChartWidgetState();
}

class _MultiDeviceMultiFieldBarChartWidgetState
    extends BaseState<MultiDeviceMultiFieldBarChartWidget> {
  late String title;
  late List<String> deviceIds;
  late List<String> fields;
  late FontConfig titleFont;
  late FontConfig legendFont;
  late BarChartDirection chartDirection;
  late LegendPosition legendPosition;
  late LegendIconType iconType;
  late List<Color> barColors = [];
  late double barWidth;
  late double barRadius;
  late double legendDuration;
  late Color tooltipBgColor;
  late Color chartBgColor;
  late Color chartAreaColor;
  late FontConfig tooltipFont;
  bool isValidConfig = false;
  List<ChartData> chartData = [];
  late TooltipBehavior _toolTip;

  @override
  void initState() {
    var config = widget.config;
    title = config.title;
    deviceIds = config.deviceIds;
    fields = config.fields;
    titleFont = FontConfig.fromJson(config.titleFont);
    chartDirection = config.chartDirection;
    legendPosition = config.legendPosition;
    barWidth = config.barWidth;
    barRadius = config.barRadius;
    legendDuration = config.toolTipDuration;
    tooltipBgColor = Color(config.tooltipBgColor);
    chartBgColor = Color(config.chartBgColor);
    chartAreaColor = Color(config.chartAreaColor);
    tooltipFont = FontConfig.fromJson(config.tooltipFont);
    barColors = config.barColor.map((colorInt) => Color(colorInt)).toList();

    _toolTip = TooltipBehavior(
        duration: 1000,
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          final ChartData chartData = data;
          final field = series.name;
          final value = chartData.values[field] ?? 0.0;
          return Container(
            color: tooltipBgColor,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$field : $value',
              style: TwinUtils.getTextStyle(tooltipFont),
            ),
          );
        });

    isValidConfig = deviceIds.isNotEmpty && fields.isNotEmpty;
    super.initState();
  }

  List<CartesianSeries<ChartData, String>> _getColumnSeries() {
    List<CartesianSeries<ChartData, String>> series = [];
    if (chartData.isNotEmpty) {
      var fields = chartData.first.values.keys.toList();
      for (var i = 0; i < fields.length; i++) {
        var field = fields[i];
        series.add(ColumnSeries<ChartData, String>(
          dataSource: chartData,
          color: barColors[i % barColors.length],
          borderWidth: barWidth,
          borderRadius: BorderRadius.circular(barRadius),
          xValueMapper: (ChartData data, _) => data.deviceName,
          yValueMapper: (ChartData data, _) => data.values[field] ?? 0.0,
          name: field,
        ));
      }
    }
    return series;
  }

  List<CartesianSeries<ChartData, String>> _getHorizontalSeries() {
    List<CartesianSeries<ChartData, String>> series = [];
    if (chartData.isNotEmpty) {
      var fields = chartData.first.values.keys.toList();
      for (var i = 0; i < fields.length; i++) {
        var field = fields[i];
        series.add(BarSeries<ChartData, String>(
          dataSource: chartData,
          color: barColors[i % barColors.length],
          borderWidth: barWidth,
          borderRadius: BorderRadius.circular(barRadius),
          xValueMapper: (ChartData data, _) => data.deviceName,
          yValueMapper: (ChartData data, _) => data.values[field] ?? 0.0,
          name: field,
        ));
      }
    }
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          loading
              ? const CircularProgressIndicator()
              : SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  title: ChartTitle(
                    text: title.isNotEmpty ? title : '--',
                  ),
                  backgroundColor: chartBgColor,
                  plotAreaBackgroundColor: chartAreaColor,
                  legend: const Legend(isVisible: true),
                  tooltipBehavior: _toolTip,
                  series: chartDirection == BarChartDirection.vertical
                      ? _getColumnSeries()
                      : _getHorizontalSeries(),
                ),
        ],
      ),
    );
  }

  Future load() async {
    if (loading) return;
    loading = true;

    List<ChartData> fetchedData = [];
    Map<String, String> fetchedLabels = {};

    for (var deviceId in deviceIds) {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: [],
          page: 0,
          size: 1,
          conditions: [],
          boolConditions: [],
          queryConditions: [],
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
          ],
          sort: {'updatedStamp': 'desc'},
        ),
      );
      debugPrint(qRes.body.toString());

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];

        if (values.isNotEmpty) {
          var obj = values.first;
          Map<String, double?> dataValues = {};
          for (var field in fields) {
            dataValues[field] = obj['p_source']['data'].containsKey(field)
                ? obj['p_source']['data'][field].toDouble()
                : null;
          }
          String deviceName = obj['p_source']['deviceName'];
          Device? device = await TwinUtils.getDevice(deviceId: deviceId);
          if (device == null) continue;

          deviceName = device.name;
          DeviceModel? deviceModel =
              await TwinUtils.getDeviceModel(modelId: device.modelId);
          for (var field in fields) {
            String? label = TwinUtils.getParameterLabel(field, deviceModel!);
            fetchedLabels[field] =
                label != null && label.isNotEmpty ? label : field;
            debugPrint('Field: $field, Label: ${fetchedLabels[field]}');
          }
          fetchedData
              .add(ChartData(deviceName: deviceName, values: dataValues));
        }
      }
    }

    setState(() {
      chartData = fetchedData;
      loading = false;
    });
  }

  @override
  void setup() {
    load();
  }
}

class ChartData {
  final String deviceName;
  final Map<String, double?> values;

  ChartData({required this.deviceName, required this.values});
}

class MultiDeviceMultiFieldBarChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiDeviceMultiFieldBarChartWidget(
        config: MultiDeviceMultiFieldBarChartWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.all_out_sharp);
  }

  @override
  String getPaletteName() {
    return "Multi Device Multi Field Bar Chart";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return MultiDeviceMultiFieldBarChartWidgetConfig.fromJson(config);
    }
    return MultiDeviceMultiFieldBarChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Bar Chart based on Multi Device Multi Field';
  }
}
