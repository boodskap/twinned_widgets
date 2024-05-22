import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class MultipleDeviceCartesianChartWidget extends StatefulWidget {
  final MultipleDeviceCartesianChartWidgetConfig config;
  const MultipleDeviceCartesianChartWidget({super.key, required this.config});

  @override
  State<MultipleDeviceCartesianChartWidget> createState() =>
      _MultipleDeviceCartesianChartWidgetState();
}

class _MultipleDeviceCartesianChartWidgetState
    extends BaseState<MultipleDeviceCartesianChartWidget> {
  final List<SeriesData> _chatSeries = [];
  bool isValidConfig = false;
  late String field;
  late List<String> deviceIds;
  late Color bgColor;

  @override
  void initState() {
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;
    var config = widget.config;
    field = config.field;
    deviceIds = config.deviceId;
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
            yValueMapper: (SeriesData sales, _) => sales.value1,
            width: 2,
            markerSettings: const MarkerSettings(
                isVisible: true,
                height: 4,
                width: 4,
                shape: DataMarkerType.circle,
                borderWidth: 3,
                borderColor: Colors.blue),
            dataLabelSettings: const DataLabelSettings(
                isVisible: true, labelAlignment: ChartDataLabelAlignment.auto)),
        LineSeries<SeriesData, num>(
            enableTooltip: true,
            dataSource: _chatSeries,
            xValueMapper: (SeriesData sales, _) => sales.stamp,
            yValueMapper: (SeriesData sales, _) => sales.value2,
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

    EqlCondition deviceStats = EqlCondition(name: 'aggs', condition: {
      "by_time": {
        "date_histogram": {
          "field": "updatedStamp",
          "calendar_interval": "month",
          "min_doc_count": 1
        },
        "aggs": {
          "by_device_id": {
            "terms": {"field": "deviceId", "size": 10},
            "aggs": {
              "by_field": {
                "avg": {"field": "data.$field"}
              }
            }
          }
        }
      }
    });

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(page: 0, size: 0, conditions: [
            deviceStats
          ], boolConditions: [], queryConditions: [], mustConditions: [
            {
              "exists": {"field": "data.volume"}
            },
            {
              "terms": {"deviceId": widget.config.deviceId}
            },
          ], sort: {
            'updatedStamp': 'desc'
          }));

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['aggregations']['by_time']['buckets'];

        for (Map<String, dynamic> obj in values) {
          int millis = obj['key'];
          List<dynamic> deviceValues = obj['by_device_id']['buckets'];

          dynamic value1 = deviceValues[0]['by_field']['value'] ?? 0;
          dynamic value2 = deviceValues.length > 1
              ? deviceValues[1]['by_field']['value']
              : 0;

          _chatSeries
              .add(SeriesData(stamp: millis, value1: value1, value2: value2));
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
  final dynamic value1;
  final dynamic value2;
  SeriesData({required this.stamp, required this.value1, required this.value2});
}

class MultipleDeviceCartesianChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultipleDeviceCartesianChartWidget(
        config: MultipleDeviceCartesianChartWidgetConfig.fromJson(config));
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
    return "Multiple Line Chart";
  }

  @override
  BaseConfig getDefaultConfig() {
    return MultipleDeviceCartesianChartWidgetConfig();
  }
}
