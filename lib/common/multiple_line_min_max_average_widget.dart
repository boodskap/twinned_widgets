import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/cartesian_chart/multiple_line_min_max_average.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/device_dropdown.dart';
import 'package:twinned_widgets/core/twinned_utils.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:intl/intl.dart';


class MultipleLinMinMaxAverageWidget extends StatefulWidget {
  final MultipleLinMinMaxAverageWidgetConfig config;
  const MultipleLinMinMaxAverageWidget({Key? key, required this.config})
      : super(key: key);

  @override
  State<MultipleLinMinMaxAverageWidget> createState() =>
      _MultipleLinMinMaxAverageWidgetState();
}

class _MultipleLinMinMaxAverageWidgetState
    extends BaseState<MultipleLinMinMaxAverageWidget> {
  final List<List<SeriesData>> _allSeriesData = [];
  List<List<SeriesData>> _filteredSeriesData = [];
  final List<String> deviceIds = [];
  List<String> uniqueDeviceIds = [];
  List<String> filterDeviceIds = [];
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String field;
  late List<String> modelIds;
  late Color bgColor;

  String? selectedDeviceId;

  List<CartesianChartAnnotation> annotations = [];
  List<PlotBand> plotBands = [];
  String formattedTotal = "";

  String title = "";
  String totalText = "";
  String unit = "";
  late FontConfig titleFont;
  late FontConfig totalTextFont;
  late FontConfig totalCountFont;
  late Color titleBgColor;
  late Color totalCardBgColor;
  late Color chartThemeColor;
  late Color axisLabelColor;
  late double interval;
  late double width;
  late double height;
  late bool showTotalCard;
  late bool showGrid;
  late bool showAverage;
  late bool showMinValue;
  late bool showMaxValue;
  late bool showLegend;
  late bool showTooltip;
  List<int> colors = [];
  List<int> defaultColors = [
    0xFF0096FF,
    0xFFDC4F3C,
    0xFF088F8F,
    0xFFF2A134,
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
    var config = widget.config;

    isValidConfig =
        widget.config.field.isNotEmpty && widget.config.modelId.isNotEmpty;
    title = config.title;
    totalText = config.totalText;
    unit = config.unit;
    titleFont = FontConfig.fromJson(config.titleFont);
    totalTextFont = FontConfig.fromJson(config.totalTextFont);
    totalCountFont = FontConfig.fromJson(config.totalCountFont);

    titleBgColor = Color(config.titleBgColor);
    totalCardBgColor = Color(config.totalCardBgColor);
    chartThemeColor = Color(config.chartThemeColor);
    axisLabelColor = Color(config.axisLabelColor);
    field = config.field;
    modelIds = config.modelId;
    interval = config.interval;

    width = config.width;
    height = config.height;
    showTotalCard = config.showTotalCard;
    showGrid = config.showGrid;
    showAverage = config.showAverage;
    showMinValue = config.showMinValue;
    showMaxValue = config.showMaxValue;
    showLegend = config.showLegend;
    showTooltip = config.showTooltip;

    colors = defaultColors;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (!isValidConfig) {
      return const Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly',
            style:
                TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

   

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          color: titleBgColor,
          child: Center(
            child: Text(widget.config.title,
                style: TextStyle(
                    fontFamily: titleFont.fontFamily,
                    fontSize: titleFont.fontSize,
                    fontWeight: titleFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(titleFont.fontColor))),
          ),
        ),
        Expanded(
          child: Container(
            color: chartThemeColor,
            child: Column(
              children: [
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (showTotalCard)
                        Container(
                          decoration: BoxDecoration(
                              color: totalCardBgColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  totalText,
                                  style: TextStyle(
                                      fontFamily: totalTextFont.fontFamily,
                                      fontSize: totalTextFont.fontSize,
                                      fontWeight: totalTextFont.fontBold
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Color(totalTextFont.fontColor)),
                                ),
                                Text(
                                  '$formattedTotal $unit',
                                  style: TextStyle(
                                      fontFamily: totalCountFont.fontFamily,
                                      fontSize: totalCountFont.fontSize,
                                      fontWeight: totalCountFont.fontBold
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Color(totalCountFont.fontColor)),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(
                        width: 250,
                        child: DeviceDropdown(
                          selectedItem: selectedDeviceId,
                          onDeviceSelected: (Device? device) {
                            setState(() {
                              selectedDeviceId = device?.id;
                              load();
                            });
                          },
                        ),
                      ),
                     
                    ],
                  ),
                ),
                SizedBox(height: 5),
                _filteredSeriesData.isNotEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: SfCartesianChart(
                              zoomPanBehavior: ZoomPanBehavior(
                                enablePinching: true, // Enables zooming
                              ),
                              primaryXAxis: DateTimeAxis(
                                interval: interval,
                                dateFormat: DateFormat('MM/dd/yyyy HH:mm'),
                                majorGridLines:
                                    MajorGridLines(width: showGrid ? 1 : 0),
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                minorGridLines:
                                    MinorGridLines(width: showGrid ? 1 : 0),
                                labelStyle: TextStyle(color: axisLabelColor),
                              ),
                              primaryYAxis: NumericAxis(
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                title: AxisTitle(
                                    text: unit,
                                    textStyle:
                                        TextStyle(color: axisLabelColor)),
                                plotBands: plotBands,
                                labelStyle: TextStyle(color: axisLabelColor),
                                majorGridLines:
                                    MajorGridLines(width: showGrid ? 1 : 0),
                                minorGridLines:
                                    MinorGridLines(width: showGrid ? 1 : 0),
                              ),
                              tooltipBehavior:
                                  TooltipBehavior(enable: showTooltip),
                              annotations: annotations,
                              legend: Legend(
                                  isVisible: showLegend,
                                  textStyle: TextStyle(color: axisLabelColor)),
                              series: _filteredSeriesData
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                List<SeriesData> seriesData = entry.value;
                                String legendName = seriesData.first.name;
                                return LineSeries<SeriesData, DateTime>(
                                  enableTooltip: showTooltip,
                                  name: legendName,
                                  color: Color(colors[index % colors.length]),
                                  dataSource: seriesData,
                                  xValueMapper: (SeriesData sales, _) =>
                                      DateTime.fromMillisecondsSinceEpoch(
                                          sales.stamp),
                                  yValueMapper: (SeriesData sales, _) =>
                                      sales.value,
                                  width: 2,
                                  markerSettings:
                                      MarkerSettings(isVisible: true),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No data found',
                            style: TextStyle(
                                color: Colors.red,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> load() async {
    if (!isValidConfig) return;
    if (loading) return;
    loading = true;
    _allSeriesData.clear();
    try {
      await execute(() async {
        if (selectedDeviceId == null) {
          var initialResponse =
              await TwinnedSession.instance.twin.queryDeviceData(
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
                  "terms": {"modelId": widget.config.modelId}
                },
              ],
              sort: {'updatedStamp': 'desc'},
            ),
          );
          if (!validateResponse(initialResponse)) return;

          var json = initialResponse.body!.result! as Map<String, dynamic>;
          var values = json['hits']['hits'] as List<dynamic>;
          var deviceIds = values
              .map((e) => e['p_source']['deviceId'] as String)
              .toSet()
              .toList();
          uniqueDeviceIds = deviceIds;

          if (deviceIds.isEmpty) return;
          var seriesDataFutures = deviceIds.map((deviceId) async {
            var deviceResponse =
                await TwinnedSession.instance.twin.queryDeviceHistoryData(
              apikey: TwinnedSession.instance.authToken,
              body: EqlSearch(
                source: [
                  "data.$field",
                  "deviceId",
                  "updatedStamp",
                  "deviceName"
                ],
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

            if (validateResponse(deviceResponse)) {
              var deviceJson =
                  deviceResponse.body!.result! as Map<String, dynamic>;
              var deviceValues = deviceJson['hits']['hits'] as List<dynamic>;

              var seriesData = deviceValues.map((obj) {
                int millis = obj['p_source']['updatedStamp'] as int;
                dynamic value = obj['p_source']['data'][widget.config.field];
                String name = obj['p_source']['deviceName'] as String;
                return SeriesData(stamp: millis, value: value, name: name);
              }).toList();

              if (seriesData.isNotEmpty) {
                _allSeriesData.add(seriesData);
              }
            }
          }).toList();

          await Future.wait(seriesDataFutures);
        } else {
          var deviceResponse =
              await TwinnedSession.instance.twin.queryDeviceHistoryData(
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
                  "match_phrase": {"deviceId": selectedDeviceId}
                },
              ],
              sort: {'updatedStamp': 'desc'},
            ),
          );

          if (validateResponse(deviceResponse)) {
            var deviceJson =
                deviceResponse.body!.result! as Map<String, dynamic>;
            var deviceValues = deviceJson['hits']['hits'] as List<dynamic>;
            var seriesData = deviceValues.map((obj) {
              int millis = obj['p_source']['updatedStamp'] as int;
              dynamic value = obj['p_source']['data'][widget.config.field];
              String name = obj['p_source']['deviceName'] as String;
              return SeriesData(stamp: millis, value: value, name: name);
            }).toList();

            if (seriesData.isNotEmpty) {
              _allSeriesData.add(seriesData);
            }
          }
        }
        _filteredSeriesData = _allSeriesData;
        if (_filteredSeriesData.length <=
            widget.config.chartSeriesColors.length) {
          colors = widget.config.chartSeriesColors;
        } else {
          colors = defaultColors;
        }
        int _findLastMillis() {
          int lastMillis = 0;
          for (var series in _filteredSeriesData) {
            for (var data in series) {
              if (data.stamp > lastMillis) {
                lastMillis = data.stamp;
              }
            }
          }
          return lastMillis;
        }

        int lastMillis = _findLastMillis();

        double totalConsumption = 0.0;
        _filteredSeriesData.forEach((chillerSeries) {
          totalConsumption +=
              chillerSeries.map((e) => e.value).reduce((a, b) => a + b);
        });

        formattedTotal = totalConsumption.toStringAsFixed(2);
        annotations = [];
        plotBands = [];
        for (int i = 0; i < _filteredSeriesData.length; i++) {
          final chillerSeries = _filteredSeriesData[i];
          final minData =
              chillerSeries.reduce((a, b) => a.value < b.value ? a : b);
          final maxData =
              chillerSeries.reduce((a, b) => a.value > b.value ? a : b);
          final avgConsumption =
              chillerSeries.map((e) => e.value).reduce((a, b) => a + b) /
                  chillerSeries.length;
          if (showMinValue) {
            annotations.add(CartesianChartAnnotation(
                widget: Container(
                  width: 33,
                  height: 33,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(colors[i % colors.length]),
                  ),
                  child: Center(
                    child: Text(
                      '${minData.value}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                coordinateUnit: CoordinateUnit.point,
                x: minData.stamp,
                y: minData.value,
                verticalAlignment: ChartAlignment.center,
                horizontalAlignment: ChartAlignment.center,
                clip: ChartClipBehavior.clip));
          }
          if (showMaxValue) {
            annotations.add(CartesianChartAnnotation(
                widget: Container(
                  width: 33,
                  height: 33,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(colors[i % colors.length]),
                  ),
                  child: Center(
                    child: Text(
                      '${maxData.value}',
                      // "45000ddd",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                coordinateUnit: CoordinateUnit.point,
                x: maxData.stamp,
                y: maxData.value,
                verticalAlignment: ChartAlignment.center,
                horizontalAlignment: maxData.stamp == lastMillis
                    ? ChartAlignment.far
                    : ChartAlignment.center,
                clip: ChartClipBehavior.clip));
          }
          if (showAverage) {
            plotBands.add(PlotBand(
              isVisible: true,
              start: avgConsumption,
              end: avgConsumption,
              borderWidth: 2,
              borderColor: Color(colors[i % colors.length]),
              text: '${avgConsumption.toStringAsFixed(2)}',
              textStyle: TextStyle(
                  color: Color(colors[i % colors.length]), fontSize: 12,fontWeight: FontWeight.bold),
              verticalTextAlignment: TextAnchor.start,
              horizontalTextAlignment: TextAnchor.end,
              dashArray: const [4, 5],
            ));
          }
        }
      });
    } finally {
      loading = false;
      apiLoadingStatus = true;
      refresh();
    }
  }

  @override
  void setup() {
    load();
  }
}

class SeriesData {
  final dynamic stamp;
  final dynamic value;
  final String name;
  SeriesData({required this.stamp, required this.value, required this.name});
}

class MultipleLinMinMaxAverageWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultipleLinMinMaxAverageWidget(
        config: MultipleLinMinMaxAverageWidgetConfig.fromJson(config));
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
    return "Multiple Stats Chart";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return MultipleLinMinMaxAverageWidgetConfig.fromJson(config);
    }
    return MultipleLinMinMaxAverageWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Graph based on multiple device model stats";
  }
}
