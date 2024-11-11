import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/device_field_spline_chart/device_field_spline_chart.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/models.dart';

class DeviceFieldBarChartWidget extends StatefulWidget {
  final DeviceFieldSplineChartWidgetConfig config;

  const DeviceFieldBarChartWidget({super.key, required this.config});

  @override
  _DeviceFieldBarChartWidgetState createState() =>
      _DeviceFieldBarChartWidgetState();
}

class _DeviceFieldBarChartWidgetState
    extends BaseState<DeviceFieldBarChartWidget> {
  final List<ChartData> _chartData = [];
  bool isValidConfig = false;
  final DateFormat dateFormat = DateFormat('EEE');
  late String deviceId;
  late String field;
  late String title;
  late Color chartColor;
  late bool enableToolTip;
  String fieldName = '--';
  String unit = '--';

  @override
  void initState() {
    super.initState();
    var config = widget.config;
    deviceId = config.deviceId;
    field = config.field;
    title = config.title;
    chartColor = Colors.blue;
    enableToolTip = true;

    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
    setup();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text("Not Configured Properly",
            style: TextStyle(color: Colors.red)),
      );
    }

    return Center(
      child: loading
          ? const CircularProgressIndicator()
          : Card(
              color: Colors.transparent,
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Expanded(child: _buildBarChart()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryYAxis: NumericAxis(
        labelFormat: '{value} $unit',
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        axisLine: const AxisLine(width: 0), // Removes Y-axis line
        majorGridLines: const MajorGridLines(width: 0), // Removes grid lines
        majorTickLines: const MajorTickLines(size: 0), // Removes Y-axis ticks
      ),
      primaryXAxis: const CategoryAxis(
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        axisLine: AxisLine(width: 0), // Removes X-axis line
        majorGridLines: MajorGridLines(width: 0), // Removes vertical grid lines
        majorTickLines: MajorTickLines(size: 0), // Removes X-axis ticks
      ),
      tooltipBehavior: TooltipBehavior(enable: enableToolTip),
      series: <ColumnSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) =>
              double.parse(data.y.toStringAsFixed(2)),
          dataLabelMapper: (ChartData data, _) =>
              data.y != 0 ? data.y.toStringAsFixed(2) : '',
          // Dynamically set color based on the value
          pointColorMapper: (ChartData data, _) {
            return data.y < 5000 ? Colors.teal.shade200 : Colors.teal;
          },
          name: fieldName,
          width: 0.15,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
                color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
          ),
          borderRadius: BorderRadius.circular(8), // Rounded edges
        ),
      ],
      backgroundColor: Colors.transparent,
      borderWidth: 0, // Removes the outer chart border
      borderColor: Colors.transparent, // Ensures the border is not visible
      plotAreaBorderColor: Colors.transparent,
      plotAreaBorderWidth: 0,
    );
  }

  Future<void> load() async {
    if (!isValidConfig || loading) return;

    setState(() {
      loading = true;
    });

    _chartData.clear();

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 7));

    String startOfStartDateStr = startDate.toUtc().toIso8601String();
    String endOfEndDateStr = endDate.toUtc().toIso8601String();

    EqlCondition filterRange = EqlCondition(name: 'filter', condition: {
      "range": {
        "updatedStamp": {
          "gte": startOfStartDateStr,
          "lte": endOfEndDateStr, // Corrected end date
        }
      }
    });

    try {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 1000,
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

        // Initialize a map to store sums and counts for each day
        Map<String, List<double>> dailyValues = {};

        for (Map<String, dynamic> obj in values) {
          int millis = obj['p_source']['updatedStamp'];
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
          dynamic fieldValue = obj['p_source']['data'][field];

          // Get the day of the week
          String dayKey =
              DateFormat('EEE').format(dateTime); // E.g., "Mon", "Tue"

          // Initialize the list if not present
          if (!dailyValues.containsKey(dayKey)) {
            dailyValues[dayKey] = [];
          }

          // Add the value to the corresponding day
          dailyValues[dayKey]!.add(fieldValue.toDouble());
        }

        // Dynamically get the order of days starting with "Today"
        DateTime today = DateTime.now();
        List<String> orderedDays = [];

        for (int i = 0; i < 7; i++) {
          orderedDays
              .add(DateFormat('EEE').format(today.subtract(Duration(days: i))));
        }

        // Calculate averages for each day, filling in zero for days with no data
        for (String day in orderedDays) {
          if (dailyValues.containsKey(day) && dailyValues[day]!.isNotEmpty) {
            double average = dailyValues[day]!.reduce((a, b) => a + b) /
                dailyValues[day]!.length;
            _chartData.add(ChartData(x: day, y: average));
          } else {
            _chartData.add(
                ChartData(x: day, y: 0.0)); // Add zero for days with no data
          }
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

  @override
  void setup() {
    load();
  }
}

class ChartData {
  final String x; // Day of the week for x-axis
  final double y; // Average value for y-axis

  ChartData({required this.x, required this.y});
}

class BarChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldBarChartWidget(
      config: DeviceFieldSplineChartWidgetConfig.fromJson(config),
    );
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
    return "Bar Chart widget ";
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
    return 'Bar Chart widget';
  }
}
