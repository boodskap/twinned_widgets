import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/twinned_models.dart';

class ValueDistributionPieChartWidget extends StatefulWidget {
  final ValueDistributionPieChartWidgetConfig config;
  const ValueDistributionPieChartWidget({super.key, required this.config});

  @override
  State<ValueDistributionPieChartWidget> createState() =>
      _ValueDistributionPieChartWidgetState();
}

class ChartData {
  ChartData(this.x, this.y, {this.color});
  final String x;
  final double y;
  final Color? color;
}

class _ValueDistributionPieChartWidgetState
    extends BaseState<ValueDistributionPieChartWidget> {
  final List<ChartData> chartData = [];
  late FontConfig headerFont;
  late Color headerFontColor;
  late FontConfig labelFont;
  late Color labelFontColor;
  late String field;
  late List<String> modelIds;
  bool isValidConfig = false;
  int? value;

  @override
  void initState() {
    //Copy all the config
    var config = widget.config;
    headerFont = FontConfig.fromJson(config.headerFont as Map<String, Object?>);
    labelFont = FontConfig.fromJson(config.labelFont as Map<String, Object?>);
    field = config.field;
    modelIds = config.modelIds;

    headerFontColor =
        headerFont.fontColor <= 0 ? Colors.black : Color(headerFont.fontColor);
    labelFontColor =
        labelFont.fontColor <= 0 ? Colors.black : Color(labelFont.fontColor);

    isValidConfig = field.isNotEmpty;
    isValidConfig = isValidConfig && modelIds.isNotEmpty;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.config.type == DistributionChartType.pyramid) {
      return SfPyramidChart(
          legend: Legend(
              isVisible: true,
              textStyle: TextStyle(
                  fontWeight:
                      labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: labelFont.fontSize,
                  color: labelFontColor)),
          series: PyramidSeries<ChartData, String>(
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  showZeroValue: false,
                  overflowMode: OverflowMode.shift,
                  labelIntersectAction: LabelIntersectAction.none,
                  textStyle: TextStyle(
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: labelFont.fontSize,
                      color: labelFontColor)),
              explode: true,
              dataSource: chartData,
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y));
    }

    if (widget.config.type == DistributionChartType.funnel) {
      return SfFunnelChart(
          legend: Legend(
              isVisible: true,
              textStyle: TextStyle(
                  fontWeight:
                      labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: labelFont.fontSize,
                  color: labelFontColor)),
          series: FunnelSeries<ChartData, String>(
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  showZeroValue: false,
                  overflowMode: OverflowMode.shift,
                  labelIntersectAction: LabelIntersectAction.none,
                  textStyle: TextStyle(
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: labelFont.fontSize,
                      color: labelFontColor)),
              explode: true,
              dataSource: chartData,
              pointColorMapper: (ChartData data, _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y));
    }

    return SfCircularChart(
        legend: Legend(
            isVisible: true,
            textStyle: TextStyle(
                fontWeight:
                    labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                fontSize: labelFont.fontSize,
                color: labelFontColor)),
        series: <CircularSeries>[
          if (widget.config.type == DistributionChartType.pie)
            PieSeries<ChartData, String>(
                dataLabelMapper: (data, index) {
                  return '${data.y}';
                },
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    showZeroValue: false,
                    textStyle: TextStyle(
                        fontWeight: labelFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: labelFont.fontSize,
                        color: labelFontColor)),
                explode: true,
                dataSource: chartData,
                pointColorMapper: (ChartData data, _) => data.color,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y),
          if (widget.config.type == DistributionChartType.doughnut)
            DoughnutSeries<ChartData, String>(
                dataLabelMapper: (data, index) {
                  return '${data.y}';
                },
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    showZeroValue: false,
                    textStyle: TextStyle(
                        fontWeight: labelFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: labelFont.fontSize,
                        color: labelFontColor)),
                explode: true,
                dataSource: chartData,
                pointColorMapper: (ChartData data, _) => data.color,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y),
          if (widget.config.type == DistributionChartType.radial)
            RadialBarSeries<ChartData, String>(
                dataLabelMapper: (data, index) {
                  return '${data.y}';
                },
                dataLabelSettings: DataLabelSettings(
                    showZeroValue: false,
                    isVisible: true,
                    textStyle: TextStyle(
                        fontWeight: labelFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: labelFont.fontSize,
                        color: labelFontColor)),
                cornerStyle: CornerStyle.bothCurve,
                dataSource: chartData,
                trackOpacity: 0.3,
                //radius: '100%',
                gap: '2%',
                innerRadius: '40%',
                enableTooltip: true,
                //pointRadiusMapper: (ChartData data, _) => data.x,
                pointColorMapper: (ChartData data, _) => data.color,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y)
        ]);
  }

  Color? getColor(String label) {
    for (var range in widget.config.segments) {
      if (range.label == label && null != range.color) {
        return Color(range.color!);
      }
    }
    return null;
  }

  Future load() async {
    if (loading) return;
    loading = true;

    chartData.clear();

    Map<String, dynamic> terms = {
      "terms": {"modelId": widget.config.modelIds}
    };

    EqlCondition aggs = EqlCondition(name: 'aggs', condition: {
      "distribution": {
        "range": {
          "field": "data.${widget.config.field}",
          "ranges": widget.config.segments
              .map((e) => {"from": e.from, "to": e.to, "key": e.label})
              .toList()
        }
      }
    });

    await execute(() async {
      TwinnedSession session = TwinnedSession.instance;

      var sRes = await session.twin.queryDeviceData(
          apikey: session.authToken,
          body: EqlSearch(
              conditions: [aggs],
              queryConditions: [],
              mustConditions: [terms],
              boolConditions: [],
              size: 0));

      if (validateResponse(sRes)) {
        debugPrint(sRes.body!.toString());
        var json = sRes.body!.result! as Map<String, dynamic>;

        List<dynamic> buckets = json['aggregations']['distribution']['buckets'];

        for (Map<String, dynamic> obj in buckets) {
          chartData.add(
            ChartData(obj['key'], obj['doc_count'],
                color: getColor(obj['key'])),
          );
        }
      }
    });
    refresh();
    loading = false;
  }

  @override
  void setup() {
    load();
  }
}

class ValueDistributionPieChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return ValueDistributionPieChartWidget(
        config: ValueDistributionPieChartWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.pie_chart);
  }

  @override
  String getPaletteName() {
    return "Distribution Chart";
  }

  @override
  BaseConfig getDefaultConfig() {
    return ValueDistributionPieChartWidgetConfig();
  }
}
