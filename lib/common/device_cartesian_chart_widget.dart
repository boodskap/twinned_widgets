import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class DeviceCartesianChartWidget extends StatefulWidget {
  final DeviceCartesianChartWidgetConfig config;
  const DeviceCartesianChartWidget({super.key, required this.config});

  @override
  State<DeviceCartesianChartWidget> createState() =>
      _DeviceCartesianChartWidgetState();
}

class _DeviceCartesianChartWidgetState
    extends BaseState<DeviceCartesianChartWidget> {
  final List<SeriesData> _chatSeries = [];
  bool isValidConfig = false;
  final DateFormat dateFormat = DateFormat('MM/dd HH:mm:ss');

  @override
  void initState() {
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    return Center(
        child: SfCartesianChart(
      backgroundColor: Color(widget.config.bgColor),
      title: ChartTitle(text: widget.config.title),
      legend: const Legend(isVisible: true),

      primaryXAxis:
          CategoryAxis(), // Change to CategoryAxis to display formatted date strings
      series: [
        LineSeries<SeriesData, String>(
            name: widget.config.field,
            enableTooltip: true,
            dataSource: _chatSeries,
            xValueMapper: (SeriesData sales, _) => sales.formattedStamp,
            yValueMapper: (SeriesData sales, _) => sales.value,
            width: 2,
            markerSettings: const MarkerSettings(
                isVisible: true,
                height: 4,
                width: 4,
                shape: DataMarkerType.circle,
                borderWidth: 3,
                borderColor: Colors.red),
            dataLabelSettings: const DataLabelSettings(
                isVisible: true, labelAlignment: ChartDataLabelAlignment.auto)),
      ],
    ));
  }

  Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    _chatSeries.clear();

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(page: 0, size: 100, source: [], mustConditions: [
            {
              "exists": {"field": "data.volume"}
            },
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
          ], sort: {
            'updatedStamp': 'desc'
          }));
      // debugPrint(qRes.toString());
      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        for (Map<String, dynamic> obj in values) {
          int millis = obj['p_source']['updatedStamp'];
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
          String formattedDate = dateFormat.format(dateTime); // Format the date
          dynamic value = obj['p_source']['data'][widget.config.field];
          _chatSeries.add(SeriesData(
              stamp: dateTime, formattedStamp: formattedDate, value: value));
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

class SeriesData {
  final DateTime stamp; // Original DateTime stamp
  final String formattedStamp; // Formatted date string
  final dynamic value;
  SeriesData(
      {required this.stamp, required this.formattedStamp, required this.value});
}

class DeviceCartesianChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceCartesianChartWidget(
        config: DeviceCartesianChartWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.stacked_line_chart);
  }

  @override
  String getPaletteName() {
    return "Line Chart";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceCartesianChartWidgetConfig.fromJson(config);
    }
    return DeviceCartesianChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Graph based on device field';
  }
}
