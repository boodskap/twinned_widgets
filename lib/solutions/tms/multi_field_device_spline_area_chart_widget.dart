import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/multi_field_device_spline_chart/multi_field_device_spline_chart.dart';
import 'package:timeago/timeago.dart' as timeago;

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

class DeviceFieldSplineAreaChartWidget extends StatefulWidget {
  final MultiFieldDeviceSplineChartWidgetConfig config;
  int size;
  DeviceFieldSplineAreaChartWidget(
      {super.key, required this.config, this.size = 100});

  @override
  _DeviceFieldSplineAreaChartWidgetState createState() =>
      _DeviceFieldSplineAreaChartWidgetState();
}

class _DeviceFieldSplineAreaChartWidgetState
    extends BaseState<DeviceFieldSplineAreaChartWidget> {
  final List<SeriesData> _chartSeries = [];
  late List<String> fields;
  late String deviceId;
  late String subTitle;
  late Color chartBorderColor;
  Map<String, String> fieldLabels = {};
  bool isValidConfig = false;
  bool loading = false;
  final DateFormat dateFormat = DateFormat('MM/dd hh:mm aa');
  late double duration;
  late bool enableTooltip;
  List<Color> gradientColors = [];
  late LegendIconType legendIconType;
  late Color labelBgColor;
  late Color labelBorderColor;
  late Color splineAreaBorderColor;
  late Color temperatureFieldColor;
  late LegendPosition legendPosition;
  late bool legendVisibility;
  late double splineAreaBorderWidth;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig labelFont;
  late FontConfig subtitleFont;
  late FontConfig tooltipFont;
  String updatedTimeAgo = '';
  String selectedDateRange = 'Today';
  DateTime? customStartDate;
  DateTime? customEndDate;
  int? size;

  @override
  void initState() {
    size = widget.size;
    duration = widget.config.duration;
    deviceId = widget.config.deviceId;
    fields = widget.config.field;
    chartBorderColor = Color(widget.config.chartBorderColor);
    enableTooltip = widget.config.enableTooltip;
    legendIconType = widget.config.iconType;
    labelBgColor = Color(widget.config.labelBgColor);
    labelBorderColor = Color(widget.config.labelBorderColor);
    legendPosition = widget.config.legendPosition;
    legendVisibility = widget.config.legendVisibility;
    splineAreaBorderColor = Color(widget.config.splineAreaBorderColor);
    splineAreaBorderWidth = widget.config.splineAreaBorderWidth;
    isValidConfig = deviceId.isNotEmpty && fields.isNotEmpty;
    subTitle = widget.config.subTitle;
    temperatureFieldColor = Color(widget.config.temperatureFieldColor);
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);
    subtitleFont = FontConfig.fromJson(widget.config.subTitleFont);
    tooltipFont = FontConfig.fromJson(widget.config.tooltipFont);

    super.initState();

    load();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Column(
        children: [
          Text(
            "Not Configured Properly",
            style: TextStyle(color: Colors.red),
          )
        ],
      );
    }

    return Center(
      child: loading
          ? const CircularProgressIndicator()
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            updatedTimeAgo,
                            style: TwinUtils.getTextStyle(subtitleFont),
                          ),
                          const SizedBox(width: 16),
                          PopupMenuButton<String>(
                            tooltip: "Select Date",
                            onSelected: (String newValue) {
                              setState(() {
                                selectedDateRange = newValue;
                                if (selectedDateRange == 'DateRange') {
                                  _selectDateRange(context);
                                } else {
                                  load();
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) {
                              return <String>[
                                'Today',
                                'Yesterday',
                                'Last 7 Days',
                                'DateRange'
                              ].map<PopupMenuItem<String>>((String value) {
                                return PopupMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList();
                            },
                            child: Row(
                              children: [
                                Text(selectedDateRange),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          dateFormat: dateFormat,
                          labelIntersectAction: AxisLabelIntersectAction.wrap,
                          majorGridLines: const MajorGridLines(width: 0),
                          minorGridLines: const MinorGridLines(width: 0),
                        ),
                        axes: const <ChartAxis>[
                          NumericAxis(
                            name: 'ValueAxis',
                            opposedPosition: true,
                            majorGridLines: MajorGridLines(width: 0),
                            minorGridLines: MinorGridLines(width: 0),
                          ),
                        ],
                        legend: Legend(
                          isVisible: legendVisibility,
                          position: legendPosition,
                        ),
                        tooltipBehavior: TooltipBehavior(
                          enable: enableTooltip,
                          duration: duration,
                          borderColor: labelBorderColor,
                          color: labelBgColor,
                          textStyle: TwinUtils.getTextStyle(tooltipFont),
                        ),
                        borderColor: chartBorderColor,
                        series: _buildSeries(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<CartesianSeries<dynamic, dynamic>> _buildSeries() {
    List<CartesianSeries<dynamic, dynamic>> seriesList = [];

    for (var data in _chartSeries) {
      for (var fieldName in data.fields.keys) {
        if (fields.contains(fieldName)) {
          var value = data.fields[fieldName];
          if (value is num) {
            if (seriesList
                .every((series) => series.name != fieldLabels[fieldName])) {
              var label = fieldLabels[fieldName] ?? fieldName;
              if (fieldName == 'temperature') {
                seriesList.add(SplineSeries<SeriesData, DateTime>(
                  dataSource: _chartSeries,
                  xValueMapper: (SeriesData data, _) => data.stamp,
                  yValueMapper: (SeriesData data, _) => data.fields[fieldName],
                  color: const Color(0xfff088bb),
                  yAxisName: 'ValueAxis',
                  name: label,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: false,
                  ),
                ));
              } else {
                seriesList.add(SplineAreaSeries<SeriesData, DateTime>(
                  dataSource: _chartSeries,
                  xValueMapper: (SeriesData data, _) => data.stamp,
                  yValueMapper: (SeriesData data, _) => data.fields[fieldName],
                  gradient: const LinearGradient(
                    colors: [Color(0xffa2b0f2), Color(0xffeceffc)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderWidth: 1,
                  name: label,
                  borderColor: const Color(0xff677eea),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: false,
                  ),
                ));
              }
            }
          }
        }
      }
    }

    return seriesList;
  }

  Future<void> load({String? filter, String search = '*'}) async {
    if (!isValidConfig || loading) return;

    setState(() {
      loading = true;
    });

    _chartSeries.clear();

    DateTime startDate;
    DateTime endDate = DateTime.now();

    switch (selectedDateRange) {
      case 'Yesterday':
        startDate = DateTime(endDate.year, endDate.month, endDate.day)
            .subtract(const Duration(days: 1));

        endDate = startDate
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        break;
      case 'Last 7 Days':
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case 'DateRange':
        if (customStartDate != null && customEndDate != null) {
          startDate = customStartDate!;
          endDate = customEndDate!;
        } else {
          startDate = DateTime(endDate.year, endDate.month, endDate.day);
          endDate = DateTime(endDate.year, endDate.month, endDate.day)
              .add(const Duration(days: 1))
              .subtract(const Duration(seconds: 1));
        }
        break;
      case 'Today':
      default:
        startDate = DateTime(endDate.year, endDate.month, endDate.day);
        endDate = DateTime(endDate.year, endDate.month, endDate.day)
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        break;
    }

    String startOfStartDateStr = startDate.toUtc().toIso8601String();
    String endOfEndDateStr = endDate.toUtc().toIso8601String();

    EqlCondition filterRange = EqlCondition(name: 'filter', condition: {
      "range": {
        "updatedStamp": {
          "gte": startOfStartDateStr,
          "lte": endOfEndDateStr,
        }
      }
    });

    var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
      apikey: TwinnedSession.instance.authToken,
      body: EqlSearch(
        page: 0,
        size: widget.size,
        source: [],
        mustConditions: [
          {
            "match_phrase": {"deviceId": deviceId}
          },
        ],
        sort: {'updatedStamp': 'desc'},
        conditions: [],
        queryConditions: [],
        boolConditions: [filterRange],
      ),
    );

    if (validateResponse(qRes)) {
      Device? device = await TwinUtils.getDevice(deviceId: deviceId);
      if (device == null) return;

      DeviceModel? deviceModel =
          await TwinUtils.getDeviceModel(modelId: device.modelId);

      for (String field in fields) {
        String label = TwinUtils.getParameterLabel(field, deviceModel!);
        fieldLabels[field] = label;
      }

      Map<String, dynamic> json = qRes.body!.result as Map<String, dynamic>;
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

      if (_chartSeries.isNotEmpty) {
        updatedTimeAgo = timeago.format(_chartSeries.first.stamp);
      }
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialStartDate =
        customStartDate ?? now.subtract(const Duration(days: 7));
    DateTime initialEndDate = customEndDate ?? now;

    final DateTimeRange? pickedRange = await showDateRangePicker(
        context: context,
        initialDateRange:
            DateTimeRange(start: initialStartDate, end: initialEndDate),
        firstDate: DateTime(2000),
        lastDate: now,
        builder: (context, child) {
          return Column(
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 400, maxHeight: 500),
                child: child,
              )
            ],
          );
        });

    if (pickedRange != null) {
      setState(() {
        customStartDate = pickedRange.start;
        customEndDate = pickedRange.end;
        selectedDateRange = 'DateRange';
        load();
      });
    }
  }

  @override
  void setup() {
    load();
  }
}
