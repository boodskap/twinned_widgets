import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/models. dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class DeviceFieldScatterChartWidget extends StatefulWidget {
  final DeviceFieldScatterChartWidgetConfig config;
  const DeviceFieldScatterChartWidget({super.key, required this.config});

  @override
  State<DeviceFieldScatterChartWidget> createState() =>
      _DeviceFieldScatterChartWidgetState();
}

class _DeviceFieldScatterChartWidgetState
    extends BaseState<DeviceFieldScatterChartWidget> {
  final List<SeriesData> _chatSeries = [];
  bool isValidConfig = false;
  final DateFormat dateFormat = DateFormat('MM/dd HH:mm:ss aa');

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
            style: TextStyle(
              color: Colors.red,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Center(
      child: loading
          ? const CircularProgressIndicator()
          : SfCartesianChart(
              backgroundColor: Color(widget.config.bgColor),
              title: ChartTitle(text: widget.config.title),
              plotAreaBackgroundColor: Colors.yellow,
              legend: const Legend(
                isVisible: true,
                position: LegendPosition.right,
              ),
              tooltipBehavior: TooltipBehavior(
                  enable: true,
                  duration: 1000,
                  borderColor: Colors.black,
                  color: Colors.amber,
                  // builder: (data, point, series, pointIndex, seriesIndex) => data,
                  textStyle: const TextStyle()),
              borderColor: Colors.black38,
              primaryXAxis: const DateTimeAxis(),
              series: [
                ScatterSeries<SeriesData, DateTime>(
                  name: widget.config.field,
                  dataSource: _chatSeries,
                  xValueMapper: (SeriesData sales, _) => sales.stamp,
                  yValueMapper: (SeriesData sales, _) => sales.value,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 4,
                    width: 4,
                    shape: DataMarkerType.circle,
                    borderWidth: 3,
                    borderColor: Colors.red,
                  ),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> load({String? filter, String search = '*'}) async {
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
          source: [],
          mustConditions: [
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
            {
              "exists": {"field": "data.${widget.config.field}"}
            },
          ],
          sort: {'updatedStamp': 'desc'},
          conditions: [],
          queryConditions: [],
          boolConditions: [],
        ),
      );
      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        for (Map<String, dynamic> obj in values) {
          int millis = obj['p_source']['updatedStamp'];
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
          String formattedDate = dateFormat.format(dateTime);
          dynamic value = obj['p_source']['data'][widget.config.field];
          _chatSeries.add(SeriesData(
            stamp: dateTime,
            formattedStamp: formattedDate,
            value: value,
          ));
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
  final DateTime stamp;
  final String formattedStamp;
  final dynamic value;

  SeriesData({
    required this.stamp,
    required this.formattedStamp,
    required this.value,
  });
}

class DeviceFieldScatterChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldScatterChartWidget(
      config: DeviceCartesianChartWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.scatter_plot);
  }

  @override
  String getPaletteName() {
    return "Scatter Chart";
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
    return 'Scatter chart based on device field';
  }
}
