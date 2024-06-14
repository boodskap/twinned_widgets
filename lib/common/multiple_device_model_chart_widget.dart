import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:intl/intl.dart';

import '../core/device_dropdown.dart';

class MultipleDeviceModelChartWidget extends StatefulWidget {
  final MultipleDeviceModelChartWidgetConfig config;
  const MultipleDeviceModelChartWidget({Key? key, required this.config})
      : super(key: key);

  @override
  State<MultipleDeviceModelChartWidget> createState() =>
      _MultipleDeviceModelChartWidgetState();
}

class _MultipleDeviceModelChartWidgetState
    extends BaseState<MultipleDeviceModelChartWidget> {
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
  late FontConfig headerFont;
  late Color headerFontColor;
  late FontConfig labelFont;
  late Color labelFontColor;
  String? selectedDeviceId;

  @override
  void initState() {
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.modelId.isNotEmpty;
    var config = widget.config;
    field = config.field;
    modelIds = config.modelId;
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

    if (_filteredSeriesData.isEmpty) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 350,
              child: DeviceDropdown(
                selectedItem: selectedDeviceId,
                onDeviceSelected: (Device? device) {
                  setState(() {
                    selectedDeviceId = device?.id;
                    load();
                  });
                },
              ),
            )
          ],
        ),
        Expanded(
          child: Center(
            child: SfCartesianChart(
              title: ChartTitle(
                  text: widget.config.title,
                  textStyle: TextStyle(
                      fontWeight: headerFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: headerFont.fontSize,
                      color: headerFontColor)),
              legend: Legend(
                  isVisible: true,
                  textStyle: TextStyle(
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: labelFont.fontSize,
                      color: labelFontColor)),
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat('MM/dd/yyyy HH:mm'),
              ),
              series: _filteredSeriesData.map((seriesData) {
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

class MultipleDeviceModelChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultipleDeviceModelChartWidget(
        config: MultipleDeviceModelChartWidgetConfig.fromJson(config));
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
    return "Multiple Line Filter Chart";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return MultipleDeviceModelChartWidgetConfig.fromJson(config);
    }
    return MultipleDeviceModelChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Graph based on multiple device model values";
  }
}
