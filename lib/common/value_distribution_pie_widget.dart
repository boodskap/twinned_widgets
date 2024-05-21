import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
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
                  fontWeight: widget.config.labelFont!.fontBold
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: widget.config.labelFont!.fontSize,
                  color: Color(widget.config.labelFont!.fontColor!))),
          series: PyramidSeries<ChartData, String>(
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  showZeroValue: false,
                  overflowMode: OverflowMode.shift,
                  labelIntersectAction: LabelIntersectAction.none,
                  textStyle: TextStyle(
                      fontWeight: widget.config.labelFont!.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: widget.config.labelFont!.fontSize,
                      color: Color(widget.config.labelFont!.fontColor!))),
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
                  fontWeight: widget.config.labelFont!.fontBold
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: widget.config.labelFont!.fontSize,
                  color: Color(widget.config.labelFont!.fontColor!))),
          series: FunnelSeries<ChartData, String>(
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  showZeroValue: false,
                  overflowMode: OverflowMode.shift,
                  labelIntersectAction: LabelIntersectAction.none,
                  textStyle: TextStyle(
                      fontWeight: widget.config.labelFont!.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: widget.config.labelFont!.fontSize,
                      color: Color(widget.config.labelFont!.fontColor!))),
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
                fontWeight: widget.config.labelFont!.fontBold
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: widget.config.labelFont!.fontSize,
                color: Color(widget.config.labelFont!.fontColor!))),
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
                        fontWeight: widget.config.labelFont!.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: widget.config.labelFont!.fontSize,
                        color: Color(widget.config.labelFont!.fontColor!))),
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
                        fontWeight: widget.config.labelFont!.fontBold!
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: widget.config.labelFont!.fontSize,
                        color: Color(widget.config.labelFont!.fontColor!))),
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
                        fontWeight: widget.config.labelFont!.fontBold!
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: widget.config.labelFont!.fontSize,
                        color: Color(widget.config.labelFont!.fontColor!))),
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
}