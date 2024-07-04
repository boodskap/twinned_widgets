import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/ems/multiple_field_stats.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class MultipleFieldStatsWidget extends StatefulWidget {
  final MultipleFieldStatsWidgetConfig config;
  const MultipleFieldStatsWidget({super.key, required this.config});

  @override
  State<MultipleFieldStatsWidget> createState() =>
      _MultipleFieldStatsWidgetState();
}

class _MultipleFieldStatsWidgetState
    extends BaseState<MultipleFieldStatsWidget> {
  final List<SeriesData> _chartSeries = [];
  bool isValidConfig = false;
  bool loading = false;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  late Map<String, dynamic> aggsData = {};
  late DeviceModel? deviceModel;

  late String title;
  late String subTitle;
  late String deviceId;
  late List<String> fieldList;
  late FontConfig titleFont;
  late FontConfig subTitleFont;
  late FontConfig axisLabelFont;
  late FontConfig statsHeadingFont;
  late FontConfig statsValueFont;
  late double width;
  late double height;
  late bool showAvgValue;
  late bool showLabel;
  late bool showLegend;
  late bool showMaxValue;
  late bool showMinValue;
  late bool showStats;
  late bool showTotalValue;
  late bool showTooltip;
  late bool showTodayData;
  late String minLabelText;
  late String maxLabelText;
  late String avgLabelText;
  late String totalLabelText;
  List<int> colorList = [];
  late List<int> chartSeriesColors;
  late ChartType chartType;
  late String chartSelectedType;
  List<int> defaultColors = [
    0xFF088F8F,
    0xFFF2A134,
    0xFF0096FF,
    0xFFDC4F3C,
    0xFFF7E379,
    0XFFBBDB44,
    0XFF44CE1B,
    0XFF9F2B68,
    0XFFFF7F50,
    0XFFFF69B4,
    0XFF770737,
    0XFFFDDA0D,
    0XFF8B8000,
    0XFFDAA520,
    0XFF93C572
  ];

  @override
  void initState() {
    super.initState();
    var config = widget.config;

    title = config.title;
    subTitle = config.subTitle;
    deviceId = config.deviceId;
    fieldList = config.field;
    titleFont = FontConfig.fromJson(config.titleFont);
    subTitleFont = FontConfig.fromJson(config.subTitleFont);
    axisLabelFont = FontConfig.fromJson(config.axisLabelFont);
    statsHeadingFont = FontConfig.fromJson(config.statsHeadingFont);
    statsValueFont = FontConfig.fromJson(config.statsValueFont);
    width = config.width;
    height = config.height;
    chartSeriesColors = config.chartSeriesColors;
    showAvgValue = config.showAvgValue;
    showLabel = config.showLabel;
    showAvgValue = config.showAvgValue;
    showLegend = config.showLegend;
    showMaxValue = config.showMaxValue;
    showMinValue = config.showMinValue;
    showStats = config.showStats;
    showTotalValue = config.showTotalValue;
    showTooltip = config.showTooltip;
    showTodayData = config.showTodayData;
    minLabelText = config.minLabelText;
    maxLabelText = config.maxLabelText;
    avgLabelText = config.avgLabelText;
    totalLabelText = config.totalLabelText;
    chartType = config.chartType;
    chartSelectedType = _getChartType(chartType);
    isValidConfig = deviceId.isNotEmpty && fieldList.isNotEmpty;

    if (fieldList.length <= config.chartSeriesColors.length) {
      colorList = config.chartSeriesColors;
    } else {
      colorList = defaultColors;
    }
    load();
  }

  String _getChartType(ChartType type) {
    switch (type) {
      case ChartType.line:
        return 'line';
      case ChartType.spline:
        return 'spline';
      case ChartType.column:
        return 'column';
      case ChartType.area:
        return 'area';

      default:
        return 'spline';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chartSeries.isEmpty) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(title,
                  style: TextStyle(
                      fontFamily: titleFont.fontFamily,
                      fontSize: titleFont.fontSize,
                      fontWeight: titleFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(titleFont.fontColor))),
            ),
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.access_time,
                      size: subTitleFont.fontSize,
                      color: Color(subTitleFont.fontColor)),
                  SizedBox(width: 3),
                  Text(subTitle,
                      style: TextStyle(
                          fontFamily: subTitleFont.fontFamily,
                          fontSize: subTitleFont.fontSize,
                          fontWeight: subTitleFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(subTitleFont.fontColor))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: width,
                    height: height+74,
                    child: Column(
                      children: [
                        SizedBox(
                          height: height,
                          child: SfCartesianChart(
                            primaryXAxis: DateTimeAxis(
                              isVisible: true,
                              dateFormat: DateFormat('MM/dd/yyyy HH:mm'),
                              // dateFormat: DateFormat.Hm(),
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              minorTickLines: MinorTickLines(width: 0),
                              majorTickLines: MajorTickLines(width: 0),
                              axisLine: const AxisLine(width: 0),
                              labelStyle: TextStyle(
                                  fontFamily: axisLabelFont.fontFamily,
                                  fontSize: axisLabelFont.fontSize,
                                  fontWeight: axisLabelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(axisLabelFont.fontColor)),
                            ),
                            primaryYAxis: NumericAxis(
                              isVisible: false,
                              labelStyle: TextStyle(
                                  fontFamily: axisLabelFont.fontFamily,
                                  fontSize: axisLabelFont.fontSize,
                                  fontWeight: axisLabelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(axisLabelFont.fontColor)),
                            ),
                            axes: _buildAxes(),
                            // zoomPanBehavior: ZoomPanBehavior(
                            //   enablePanning: true,
                            //   enableMouseWheelZooming: true,
                            // ),
                            legend: Legend(
                              isVisible: showLegend,
                              position: LegendPosition.top,
                              textStyle: TextStyle(
                                  fontFamily: axisLabelFont.fontFamily,
                                  fontSize: axisLabelFont.fontSize,
                                  fontWeight: axisLabelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(axisLabelFont.fontColor)),
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: showTooltip,
                              duration: 1000,
                              borderColor: Colors.black,
                              color: Colors.grey,
                              textStyle: const TextStyle(),
                            ),
                            series: _buildSeries(),
                          ),
                        ),
                        if (showStats)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _buildStatistics(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CartesianSeries<dynamic, dynamic>> _buildSeries() {
    List<CartesianSeries<dynamic, dynamic>> seriesList = [];
    int colorIndex = 0;

    fieldList.forEach((fieldName) {
      if (_chartSeries.isNotEmpty) {
        final color = colorList[colorIndex % colorList.length];
        colorIndex++;
        if (chartSelectedType == 'column') {
          seriesList.add(ColumnSeries<SeriesData, DateTime>(
            dataSource: _chartSeries,
            xValueMapper: (SeriesData data, _) => data.stamp,
            yValueMapper: (SeriesData data, _) => data.fields[fieldName],
            color: Color(color),
            yAxisName: fieldName,
            width:0.4,
            name: TwinUtils.getParameterLabel(fieldName, deviceModel!),
            dataLabelSettings: DataLabelSettings(
              isVisible: showLabel,
            ),
          ));
        }
        else  if (chartSelectedType == 'area') {
          seriesList.add(AreaSeries<SeriesData, DateTime>(
            dataSource: _chartSeries,
            xValueMapper: (SeriesData data, _) => data.stamp,
            yValueMapper: (SeriesData data, _) => data.fields[fieldName],
            color: Color(color),
            yAxisName: fieldName,
            name: TwinUtils.getParameterLabel(fieldName, deviceModel!),
            dataLabelSettings: DataLabelSettings(
              isVisible: showLabel,
            ),
          ));
        }
         else  if (chartSelectedType == 'line') {
          seriesList.add(LineSeries<SeriesData, DateTime>(
            dataSource: _chartSeries,
            xValueMapper: (SeriesData data, _) => data.stamp,
            yValueMapper: (SeriesData data, _) => data.fields[fieldName],
            color: Color(color),
            yAxisName: fieldName,
            name: TwinUtils.getParameterLabel(fieldName, deviceModel!),
            dataLabelSettings: DataLabelSettings(
              isVisible: showLabel,
            ),
          ));
        }
         else {
          seriesList.add(SplineSeries<SeriesData, DateTime>(
            dataSource: _chartSeries,
            xValueMapper: (SeriesData data, _) => data.stamp,
            yValueMapper: (SeriesData data, _) => data.fields[fieldName],
            color: Color(color),
            yAxisName: fieldName,
            name: TwinUtils.getParameterLabel(fieldName, deviceModel!),
            dataLabelSettings: DataLabelSettings(
              isVisible: showLabel,
            ),
          ));
        }
      }
    });

    return seriesList;
  }

  List<ChartAxis> _buildAxes() {
    List<ChartAxis> axesList = [];
    fieldList.asMap().forEach((index, fieldName) {
      String label = TwinUtils.getParameterLabel(fieldName, deviceModel!);
      String unit = TwinUtils.getParameterUnit(fieldName, deviceModel!);
      axesList.add(NumericAxis(
        name: fieldName,
        opposedPosition: index % 2 != 0,
        majorGridLines: const MajorGridLines(width: 1),
        minorGridLines: const MinorGridLines(width: 0),
        majorTickLines: MajorTickLines(width: 0),
        minorTickLines: MinorTickLines(width: 0),
        title: AxisTitle(
            text: '$label, $unit',
            textStyle: TextStyle(
                fontFamily: axisLabelFont.fontFamily,
                fontSize: axisLabelFont.fontSize,
                fontWeight: axisLabelFont.fontBold
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: Color(axisLabelFont.fontColor))),
        axisLine: AxisLine(width: 0),
        labelStyle: TextStyle(
            fontFamily: axisLabelFont.fontFamily,
            fontSize: axisLabelFont.fontSize,
            fontWeight:
                axisLabelFont.fontBold ? FontWeight.bold : FontWeight.normal,
            color: Color(axisLabelFont.fontColor)),
      ));
    });

    return axesList;
  }

  Widget _buildStatistics() {
    List<Widget> statWidgets = [];
    int colorIndex = 0;
    double statsWidth = width / 6;
    aggsData.forEach((key, value) {
      String formattedLabel = key.replaceAll('_stats', '');
      String label = TwinUtils.getParameterLabel(formattedLabel, deviceModel!);
      String unit = TwinUtils.getParameterUnit(formattedLabel, deviceModel!);

      statWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: statsWidth + 30,
                      child: Column(
                        children: [
                          Text(''),
                          Row(
                            children: [
                              Container(
                                width: 15,
                                height: 5,
                                color: Color(
                                    colorList[colorIndex % colorList.length]),
                              ),
                              SizedBox(width: 5),
                              Text(label,
                                  style: TextStyle(
                                      fontFamily: statsValueFont.fontFamily,
                                      fontSize: statsValueFont.fontSize,
                                      fontWeight: statsValueFont.fontBold
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Color(statsValueFont.fontColor))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (showMinValue)
                      SizedBox(
                        width: statsWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(minLabelText,
                                style: TextStyle(
                                    fontFamily: statsHeadingFont.fontFamily,
                                    fontSize: statsHeadingFont.fontSize,
                                    fontWeight: statsHeadingFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(statsHeadingFont.fontColor))),
                            Text(
                                '${value['min'].toStringAsFixed(2) ?? ''} $unit',
                                style: TextStyle(
                                    fontFamily: statsValueFont.fontFamily,
                                    fontSize: statsValueFont.fontSize,
                                    fontWeight: statsValueFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(statsValueFont.fontColor))),
                          ],
                        ),
                      ),
                    if (showMaxValue) ...[
                      SizedBox(width: 10),
                      SizedBox(
                        width: statsWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(maxLabelText,
                                style: TextStyle(
                                    fontFamily: statsHeadingFont.fontFamily,
                                    fontSize: statsHeadingFont.fontSize,
                                    fontWeight: statsHeadingFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(statsHeadingFont.fontColor))),
                            Text(
                                '${value['max'].toStringAsFixed(2) ?? ''} $unit',
                                style: TextStyle(
                                    fontFamily: statsValueFont.fontFamily,
                                    fontSize: statsValueFont.fontSize,
                                    fontWeight: statsValueFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(statsValueFont.fontColor))),
                          ],
                        ),
                      ),
                    ],
                    if (showTotalValue) ...[
                      SizedBox(width: 10),
                      SizedBox(
                        width: statsWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(totalLabelText,
                                style: TextStyle(
                                    fontFamily: statsHeadingFont.fontFamily,
                                    fontSize: statsHeadingFont.fontSize,
                                    fontWeight: statsHeadingFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(statsHeadingFont.fontColor))),
                            Text(
                                '${value['sum'].toStringAsFixed(2) ?? ''} $unit',
                                style: TextStyle(
                                    fontFamily: statsValueFont.fontFamily,
                                    fontSize: statsValueFont.fontSize,
                                    fontWeight: statsValueFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(statsValueFont.fontColor))),
                          ],
                        ),
                      ),
                    ],
                    if (showAvgValue) ...[
                      SizedBox(width: 10),
                      SizedBox(
                        width: statsWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(avgLabelText,
                                style: TextStyle(
                                    fontFamily: statsHeadingFont.fontFamily,
                                    fontSize: statsHeadingFont.fontSize,
                                    fontWeight: statsHeadingFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(statsHeadingFont.fontColor))),
                            Text(
                                '${value['avg'].toStringAsFixed(2) ?? ''} $unit',
                                style: TextStyle(
                                    fontFamily: statsValueFont.fontFamily,
                                    fontSize: statsValueFont.fontSize,
                                    fontWeight: statsValueFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(statsValueFont.fontColor))),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      colorIndex++;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: statWidgets,
    );
  }

  Future<void> load({String? filter, String search = '*'}) async {
    if (!isValidConfig || loading) return;

    setState(() {
      loading = true;
    });

    _chartSeries.clear();

    try {
      List<Object> mustConditions = [
        {
          "match_phrase": {"deviceId": deviceId}
        }
      ];

      for (String field in fieldList) {
        mustConditions.add(
          {
            "exists": {"field": "data.$field"}
          },
        );
      }

      Map<String, dynamic> aggs = {
        for (var field in fieldList)
          "${field}_stats": {
            "stats": {"field": "data.$field"}
          }
      };

      EqlCondition stats = EqlCondition(name: 'aggs', condition: aggs);
     EqlCondition filterRange = const EqlCondition(name: 'filter', condition: {
        "range": {
          "updatedStamp": {
            "gte": "now/d",
            "lte": "now+1d/d"
          }
        }
      });
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 100,
          source: [],
          mustConditions: mustConditions,
          sort: {'updatedStamp': 'desc'},
          conditions: [stats],
          queryConditions: [],
          boolConditions: showTodayData ? [
         filterRange
          ] : [],
        ),
      );

      if (validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (null == device) return;
        deviceModel = await TwinUtils.getDeviceModel(modelId: device.modelId);
        if (null == deviceModel) return;

        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['hits']['hits'];

        for (Map<String, dynamic> obj in values) {
          int millis = obj['p_source']['updatedStamp'];
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
          String formattedDate = dateFormat.format(dateTime);
          Map<String, dynamic> fields =
              Map<String, dynamic>.from(obj['p_source']['data']);

          fields['stamp'] = dateTime;
          fields['formattedStamp'] = formattedDate;
          _chartSeries.add(SeriesData(
            stamp: dateTime,
            formattedStamp: formattedDate,
            fields: fields,
          ));
        }

        aggsData = json['aggregations'];
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}

class SeriesData {
  final DateTime stamp;
  final String formattedStamp;
  final Map<String, dynamic> fields;

  SeriesData({
    required this.stamp,
    required this.formattedStamp,
    required this.fields,
  });
}

class MultipleFieldStatsWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultipleFieldStatsWidget(
        config: MultipleFieldStatsWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.query_stats);
  }

  @override
  String getPaletteName() {
    return "Multiple Field Stats Chart";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return MultipleFieldStatsWidgetConfig.fromJson(config);
    }
    return MultipleFieldStatsWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Graph based on multiple field stats";
  }
}
