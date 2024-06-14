import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:intl/intl.dart'; // Import intl package

class DeviceMultiFieldChartWidget extends StatefulWidget {
  final DeviceMultiFieldChartWidgetConfig config;
  const DeviceMultiFieldChartWidget({super.key, required this.config});

  @override
  State<DeviceMultiFieldChartWidget> createState() =>
      _DeviceMultiFieldChartWidgetState();
}

class _DeviceMultiFieldChartWidgetState
    extends BaseState<DeviceMultiFieldChartWidget> {
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
        title: ChartTitle(text: widget.config.title),
        legend: const Legend(isVisible: true),
        primaryXAxis:
            const CategoryAxis(), // Change to CategoryAxis to display formatted date strings
        series: widget.config.field.map((field) {
          return LineSeries<SeriesData, String>(
            name: field,
            enableTooltip: true,
            dataSource: _chatSeries,
            xValueMapper: (SeriesData data, _) => data.formattedStamp,
            yValueMapper: (SeriesData data, _) => data.values[field],
            width: 2,
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

    List<Object> mustConditions = [
      {
        "match_phrase": {"deviceId": widget.config.deviceId}
      }
    ];

    for (String field in widget.config.field) {
      mustConditions.add(
        {
          "exists": {"field": "data.$field"}
        },
      );
    }

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 100,
          source: [],
          mustConditions: mustConditions,
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
          String formattedDate = dateFormat.format(dateTime); // Format the date
          dynamic value = obj['p_source']['data'][widget.config.field];
          Map<String, dynamic> dataValues = {};
          for (String field in widget.config.field) {
            dataValues[field] = obj['p_source']['data'][field];
          }
          _chatSeries.add(SeriesData(
              stamp: dateTime,
              formattedStamp: formattedDate,
              values: dataValues));
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
  final Map<String, dynamic> values;
  SeriesData(
      {required this.stamp,
      required this.formattedStamp,
      required this.values});
}

class DeviceMultiFieldChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceMultiFieldChartWidget(
        config: DeviceMultiFieldChartWidgetConfig.fromJson(config));
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
      return DeviceMultiFieldChartWidgetConfig.fromJson(config);
    }
    return DeviceMultiFieldChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Graph based on device multi field';
  }
}
