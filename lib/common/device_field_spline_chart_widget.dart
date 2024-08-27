import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/device_field_spline_chart/device_field_spline_chart.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class DeviceFieldSplineAreaChartWidget extends StatefulWidget {
  final DeviceFieldSplineChartWidgetConfig config;

  const DeviceFieldSplineAreaChartWidget({
    super.key,
    required this.config,
  });

  @override
  _DeviceFieldSplineAreaChartWidgetState createState() =>
      _DeviceFieldSplineAreaChartWidgetState();
}

class _DeviceFieldSplineAreaChartWidgetState
    extends BaseState<DeviceFieldSplineAreaChartWidget> {
  final List<SeriesData> _chartSeries = [];
  bool isValidConfig = false;
  final DateFormat dateFormat = DateFormat('MM/dd hh:mm:aa');
  late String deviceId;
  late String field;
  late String title;
  late String subTitle;
  late Color chartColor;
  late Color chartAreaColor;
  late Color chartAreaBorderColor;
  late FontConfig titleFont;
  late FontConfig subTitleFont;
  late FontConfig toolTipFont;
  late double toolTipDuration;
  late double chartAreaBorderWidth;
  late bool dataPointsHighlights;
  late bool enableToolTip;
  String updatedTimeAgo = '';
  String selectedDateRange = 'Today';
  DateTime? customStartDate;
  DateTime? customEndDate;

  // bool loading = false;
  String fieldName = '--';
  String unit = '--';

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    field = config.field;
    title = config.title;
    subTitle = config.subTitle;
    chartColor = Color(config.chartColor);
    chartAreaColor = Color(config.chartAreaColor);
    chartAreaBorderColor = Color(config.chartAreaBorderColor);
    titleFont = FontConfig.fromJson(config.titleFont);
    subTitleFont = FontConfig.fromJson(config.subTitleFont);
    toolTipFont = FontConfig.fromJson(config.tooltipFont);
    toolTipDuration = config.tooltipDuration;
    chartAreaBorderWidth = config.chartAreaBorderWidth;
    dataPointsHighlights = config.dataPointsHighlights;
    enableToolTip = config.enableTooltip;

    chartAreaBorderWidth = widget.config.chartAreaBorderWidth;
    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          "Not Configured Properly",
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return SizedBox(
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4), // Border radius
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            initialValue: selectedDateRange,
                            onSelected: (String? newValue) {
                              setState(() {
                                selectedDateRange = newValue!;
                                if (selectedDateRange == 'Custom') {
                                  _selectDateRange(context);
                                } else {
                                  load(); // Reload data based on the new selection
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'Today',
                                child: Text('Today'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Yesterday',
                                child: Text('Yesterday'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Last 7 Days',
                                child: Text('Last 7 Days'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'Custom',
                                child: Text('Custom'),
                              ),
                            ],
                            child: Row(
                              children: [
                                Text(selectedDateRange),
                                const Icon(Icons.arrow_drop_down)
                              ],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SfCartesianChart(
                          enableAxisAnimation: true,
                          margin: const EdgeInsets.all(0),
                          primaryYAxis: const NumericAxis(
                            isVisible: false,
                          ),
                          primaryXAxis: DateTimeAxis(
                              isVisible: false, dateFormat: dateFormat),
                          tooltipBehavior: TooltipBehavior(
                            enable: enableToolTip,
                            duration: toolTipDuration,
                            borderColor: Colors.black,
                            color: const Color(0XFFCAF0F8),
                            textStyle: TwinUtils.getTextStyle(toolTipFont),
                          ),
                          borderWidth: 0,
                          series: <SplineAreaSeries<SeriesData, DateTime>>[
                            SplineAreaSeries<SeriesData, DateTime>(
                              borderWidth: chartAreaBorderWidth,
                              color: chartAreaColor,
                              borderColor: chartAreaBorderColor,
                              dataSource: _chartSeries,
                              xValueMapper: (SeriesData data, _) =>
                                  data.stamp,
                              yValueMapper: (SeriesData data, _) =>
                                  data.field,
                              name: fieldName,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: false,
                              ),
                              markerSettings: MarkerSettings(
                                isVisible: dataPointsHighlights,
                                shape: DataMarkerType.circle,
                                width: 4,
                                height: 4,
                                borderColor: Colors.purple,
                                borderWidth: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
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
      case 'Custom':
        if (customStartDate != null && customEndDate != null) {
          startDate = customStartDate!;
          endDate = customEndDate!;
        } else {
          // Fallback to default if custom dates are not set
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

    try {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 20,
          source: [],
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
            {
              "exists": {"field": "data.$field"}
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

        fieldName = TwinUtils.getParameterLabel(field, deviceModel!);
        unit = TwinUtils.getParameterUnit(field, deviceModel);
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        for (Map<String, dynamic> obj in values) {
          int millis = obj['p_source']['updatedStamp'];
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
          String formattedDate = dateFormat.format(dateTime);
          dynamic temperature = obj['p_source']['data']['temperature'];
          // dynamic level = obj['p_source']['data']['level'];
          _chartSeries.add(SeriesData(
            stamp: dateTime,
            formattedStamp: formattedDate,
            field: temperature.toDouble(),
            // level: level.toDouble(),
          ));
        }
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
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
                    const BoxConstraints(maxWidth: 400, maxHeight: 600),
                child: child,
              )
            ],
          );
        });

    if (pickedRange != null) {
      setState(() {
        customStartDate = pickedRange.start;
        customEndDate = pickedRange.end;
        selectedDateRange = 'Custom';
        load();
      });
    }
  }

  @override
  void setup() {
    load();
  }
}

class SeriesData {
  final DateTime stamp;
  final String formattedStamp;
  final double field;
  // final double level;

  SeriesData({
    required this.stamp,
    required this.formattedStamp,
    required this.field,
    // required this.level,
  });
}

class DeviceFieldSplineAreaChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldSplineAreaChartWidget(
      config: DeviceFieldSplineChartWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.multiline_chart_outlined);
  }

  @override
  String getPaletteName() {
    return " Temperature Spline chart widget ";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return DeviceFieldSplineChartWidgetConfig.fromJson(config);
    }
    return DeviceFieldSplineChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Temperature spline chart device field widget';
  }
}

