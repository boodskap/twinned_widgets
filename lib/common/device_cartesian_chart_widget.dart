import 'dart:convert';

import 'package:flutter/material.dart';
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
      title: ChartTitle(text: widget.config.title),
      legend: const Legend(isVisible: true),
      series: [
        LineSeries<SeriesData, num>(
            enableTooltip: true,
            dataSource: _chatSeries,
            xValueMapper: (SeriesData sales, _) => sales.stamp,
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
          body: EqlSearch(
              page: 0,
              size: 100,
              conditions: [],
              boolConditions: [],
              queryConditions: [],
              mustConditions: [
                {
                  "exists": {"field": "data.volume"}
                },
                {
                  "match_phrase": {"deviceId": widget.config.deviceId}
                },
              ],
              sort: {
                'updatedStamp': 'desc'
              }));
      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        for (Map<String, dynamic> obj in values) {
          int millis = obj['p_source']['updatedStamp'];
          dynamic value = obj['p_source']['data'][widget.config.field];
          _chatSeries.add(SeriesData(stamp: millis, value: value));
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
  final num stamp;
  final dynamic value;
  SeriesData({required this.stamp, required this.value});
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
  BaseConfig getDefaultConfig() {
    return DeviceCartesianChartWidgetConfig();
  }
}
