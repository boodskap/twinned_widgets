import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class ValueDistributionPieChartWidget extends StatefulWidget {
  final ValueDistributionPieChartWidgetConfig config;
  const ValueDistributionPieChartWidget(
      {super.key, this.style, required this.config});
  final TextStyle? style;
  @override
  State<ValueDistributionPieChartWidget> createState() =>
      _ValueDistributionPieChartWidgetState();
}

class ChartData {
  ChartData(this.x, this.y, {this.color});
  final String x;
  final dynamic y;
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
  bool isValidConfig = false;
  int? value;
  List<Range> segments = [];
  List<Map<String, dynamic>> segmentsEql = [];

  @override
  void initState() {
    //Copy all the config
    var config = widget.config;
    headerFont = FontConfig.fromJson(config.headerFont as Map<String, Object?>);
    labelFont = FontConfig.fromJson(config.labelFont as Map<String, Object?>);
    field = config.field;

    headerFontColor =
        headerFont.fontColor <= 0 ? Colors.black : Color(headerFont.fontColor);
    labelFontColor =
        labelFont.fontColor <= 0 ? Colors.black : Color(labelFont.fontColor);

    isValidConfig = field.isNotEmpty;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    if (!isValidConfig) {
      return Center(
        child: Wrap(
          spacing: 8.0,
          children: [
            Text(
              'Not configured properly',
              style: labelStyle.copyWith(
                  color: Colors.red, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }

    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.config.type == DistributionChartType.pyramid) {
      return SfPyramidChart(
          legend: Legend(
              isVisible: true,
              textStyle: labelStyle.copyWith(
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
                  textStyle: labelStyle.copyWith(
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
              textStyle: labelStyle.copyWith(
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
                  textStyle: labelStyle.copyWith(
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
            textStyle: labelStyle.copyWith(
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
                    textStyle: labelStyle.copyWith(
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
                    textStyle: labelStyle.copyWith(
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
                    textStyle: labelStyle.copyWith(
                        fontWeight: labelFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: labelFont.fontSize,
                        color: labelFontColor)),
                cornerStyle: CornerStyle.bothCurve,
                dataSource: chartData,
                trackOpacity: 0.3,
                //rad: '100%',
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
    for (var range in segments) {
      if (range.label == label && null != range.color) {
        return Color(range.color!);
      }
    }
    return null;
  }

  Future load() async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    chartData.clear();
    segments.clear();
    segmentsEql.clear();

    Map<String, dynamic> terms = {
      "terms": {"modelId": widget.config.modelIds}
    };

    for (Map<String, dynamic> obj in widget.config.segments) {
      Range range = Range.fromJson(obj);
      segments.add(range);
      segmentsEql.add({'from': range.from, 'to': range.to, 'key': range.label});
    }

    EqlCondition aggs = EqlCondition(name: 'aggs', condition: {
      "distribution": {
        "range": {"field": "data.${widget.config.field}", "ranges": segmentsEql}
      }
    });

    await execute(() async {
      TwinnedSession session = TwinnedSession.instance;

      var sRes = await session.twin.queryDeviceData(
          apikey: session.authToken,
          body: EqlSearch(
              source: [],
              conditions: [aggs],
              mustConditions: [
                if (widget.config.modelIds.isNotEmpty)
                  {
                    "terms": {"modelId": widget.config.modelIds}
                  },
                if (widget.config.assetModelIds.isNotEmpty)
                  {
                    "terms": {"assetModelId": widget.config.assetModelIds}
                  },
                if (widget.config.premiseIds.isNotEmpty)
                  {
                    "terms": {"premiseId": widget.config.premiseIds}
                  },
                if (widget.config.facilityIds.isNotEmpty)
                  {
                    "terms": {"facilityId": widget.config.facilityIds}
                  },
                if (widget.config.floorIds.isNotEmpty)
                  {
                    "terms": {"floorId": widget.config.floorIds}
                  },
                if (widget.config.assetIds.isNotEmpty)
                  {
                    "terms": {"assetId": widget.config.assetIds}
                  },
                if (widget.config.clientIds.isNotEmpty)
                  {
                    "terms": {"clientIds.keyword": widget.config.clientIds}
                  },
              ],
              size: 0,
              queryConditions: [],
              boolConditions: []));

      if (validateResponse(sRes)) {
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
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return ValueDistributionPieChartWidgetConfig.fromJson(config);
    }
    return ValueDistributionPieChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Pie chart based on device field data ranges';
  }
}
