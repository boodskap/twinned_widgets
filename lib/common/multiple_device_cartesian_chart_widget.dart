import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:intl/intl.dart';

class MultipleDeviceCartesianChartWidget extends StatefulWidget {
  final MultipleDeviceCartesianChartWidgetConfig config;
  const MultipleDeviceCartesianChartWidget({Key? key, required this.config})
      : super(key: key);

  @override
  State<MultipleDeviceCartesianChartWidget> createState() =>
      _MultipleDeviceCartesianChartWidgetState();
}

class _MultipleDeviceCartesianChartWidgetState
    extends BaseState<MultipleDeviceCartesianChartWidget> {
  final List<List<SeriesData>> _chatSeries = [];

  bool isValidConfig = false;
  late String field;
  late List<String> deviceIds;
  late Color bgColor;
  late FontConfig headerFont;
  late Color headerFontColor;
  late FontConfig labelFont;
  late Color labelFontColor;

  @override
  void initState() {
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;
    var config = widget.config;
    field = config.field;
    deviceIds = config.deviceId;
    headerFont = FontConfig.fromJson(config.headerFont);
    headerFontColor =
        headerFont.fontColor <= 0 ? Colors.black : Color(headerFont.fontColor);

    labelFont = FontConfig.fromJson(config.labelFont);
    labelFontColor =
        labelFont.fontColor <= 0 ? Colors.black : Color(labelFont.fontColor);
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
        title: ChartTitle(
            text: widget.config.title,
            textStyle: TextStyle(
                fontWeight:
                    headerFont.fontBold ? FontWeight.bold : FontWeight.normal,
                fontSize: headerFont.fontSize,
                color: headerFontColor)),
        legend: Legend(
            isVisible: true,
            textStyle: TextStyle(
                fontWeight:
                    labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
                fontSize: labelFont.fontSize,
                color: labelFontColor)),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('MM/dd/yyyy HH:mm'),
        ),
        series: _chatSeries.map((seriesData) {
          String legendName = seriesData.first.name;
          return LineSeries<SeriesData, DateTime>(
            enableTooltip: true,
            name: legendName,
            dataSource: seriesData,
            xValueMapper: (SeriesData sales, _) =>
                DateTime.fromMillisecondsSinceEpoch(sales.stamp),
            yValueMapper: (SeriesData sales, _) => sales.value,
            width: 2,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 4,
              width: 4,
              shape: DataMarkerType.circle,
              borderWidth: 3,
              borderColor: Colors.blue,
            ),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.auto,
            ),
          );
        }).toList(),
      ),
    );
  }

  Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    _chatSeries.clear();

    await execute(() async {
      var deviceIds = widget.config.deviceId;
      for (var i = 0; i < deviceIds.length; i++) {
        var deviceId = deviceIds[i];
        var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
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
                "match_phrase": {"deviceId": deviceId}
              },
            ],
            sort: {'updatedStamp': 'desc'},
          ),
        );

        if (validateResponse(qRes)) {
          Map<String, dynamic> json =
              qRes.body!.result! as Map<String, dynamic>;
          List<dynamic> values = json['hits']['hits'];
          List<SeriesData> seriesData = [];
          if (values.isNotEmpty) {
            for (Map<String, dynamic> obj in values) {
              int millis = obj['p_source']['updatedStamp'];

              dynamic value = obj['p_source']['data'][widget.config.field];
              String name = obj['p_source']['deviceName'];
              seriesData
                  .add(SeriesData(stamp: millis, value: value, name: name));
            }
            _chatSeries.add(seriesData);
          }
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
  final dynamic stamp;
  final dynamic value;
  final String name;
  SeriesData({required this.stamp, required this.value, required this.name});
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
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return MultipleDeviceCartesianChartWidgetConfig.fromJson(config);
    }
    return MultipleDeviceCartesianChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Graph bases on multiple device values";
  }
}
