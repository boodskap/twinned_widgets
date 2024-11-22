import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/multi_field_stacked_area_chart_widget/multi_field_stacked_area_chart_widget.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

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

class MultiFieldDeviceStackedAreaChartWidget extends StatefulWidget {
  final MultiFieldStackedAreaChartConfig config;
  MultiFieldDeviceStackedAreaChartWidget({
    super.key,
    required this.config,
  });

  @override
  _MultiFieldDeviceStackedAreaChartWidgetState createState() =>
      _MultiFieldDeviceStackedAreaChartWidgetState();
}

class _MultiFieldDeviceStackedAreaChartWidgetState
    extends BaseState<MultiFieldDeviceStackedAreaChartWidget> {
  final List<SeriesData> _chartSeries = [];
  bool isValidConfig = false;
  late String title;
  late List<String> fields;
  late String deviceId;
  List<Color> chartColors = [];
  late LegendPosition legendPosition;
  late bool enableTooltip;
  late bool legendVisibility;
  late bool enableMarkerPoint;
  late bool enableDataLabel;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig labelFont;
  late FontConfig subTitleFont;
  late FontConfig tooltipFont;

  Map<String, String> fieldLabels = {};
  final DateFormat dateFormat = DateFormat('MM/dd hh:mm aa');
  String updatedTimeAgo = '';

  @override
  void initState() {
    var config = widget.config;
    title = config.title;
    deviceId = config.deviceId;
    fields = config.fields;
    chartColors =
        config.chartColors.map((colorInt) => Color(colorInt)).toList();
    enableTooltip = config.enableTooltip;
    legendPosition = config.legendPosition;
    legendVisibility = config.legendVisibility;
    enableDataLabel = config.enableDataLabel;
    enableMarkerPoint = config.enableMarkerPoint;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    subTitleFont = FontConfig.fromJson(config.subTitleFont);
    tooltipFont = FontConfig.fromJson(config.tooltipFont);

    isValidConfig = deviceId.isNotEmpty &&
        fields.isNotEmpty &&
        config.chartColors.length == config.fields.length;
    super.initState();
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

    return Center(
      child: loading
          ? const CircularProgressIndicator()
          : Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TwinUtils.getTextStyle(titleFont),
                          ),
                          Text(
                            updatedTimeAgo,
                            style: TwinUtils.getTextStyle(subTitleFont),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SfCartesianChart(
                        palette: chartColors,
                        primaryYAxis: NumericAxis(
                          labelIntersectAction: AxisLabelIntersectAction.wrap,
                          labelStyle: TwinUtils.getTextStyle(labelFont),
                        ),
                        primaryXAxis: DateTimeAxis(
                          labelStyle: TwinUtils.getTextStyle(labelFont),
                          dateFormat: dateFormat,
                          labelIntersectAction: AxisLabelIntersectAction.wrap,
                          majorGridLines: const MajorGridLines(width: 0),
                          minorGridLines: const MinorGridLines(width: 0),
                        ),
                        legend: Legend(
                          textStyle: TwinUtils.getTextStyle(labelFont),
                          isVisible: legendVisibility,
                          position: legendPosition,
                        ),
                        tooltipBehavior: TooltipBehavior(
                          enable: enableTooltip,
                          borderColor: Colors.black,
                          color: Colors.black54,
                          textStyle: TwinUtils.getTextStyle(tooltipFont),
                        ),
                        borderColor: Colors.transparent,
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

              // Dynamically assign a color from the palette
              Color seriesColor = chartColors.isNotEmpty
                  ? chartColors[seriesList.length % chartColors.length]
                  : Colors.blue;

              seriesList.add(StackedAreaSeries<SeriesData, DateTime>(
                dataSource: _chartSeries,
                xValueMapper: (SeriesData data, _) => data.stamp,
                yValueMapper: (SeriesData data, _) => data.fields[fieldName],
                borderWidth: 1,
                name: label,
                borderColor: seriesColor,
                dataLabelSettings: DataLabelSettings(
                  textStyle: TwinUtils.getTextStyle(valueFont),
                  isVisible: enableDataLabel,
                ),
                markerSettings: MarkerSettings(
                  isVisible: enableMarkerPoint,
                  shape: DataMarkerType.circle,
                  width: 6,
                  height: 6,
                  borderWidth: 2,
                  color: seriesColor,
                  borderColor: Colors.white70,
                ),
              ));
            }
          }
        }
      }
    }

    return seriesList;
  }

  Future<void> load({String? filter, String search = '*'}) async {
    if (!isValidConfig || loading) return;
    loading = true;

    _chartSeries.clear();

    await execute(() async {
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
          ],
          sort: {'updatedStamp': 'desc'},
          conditions: [],
          queryConditions: [],
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
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}

class MultiFieldDeviceStackedAreaChartWidgetBuilder
    extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiFieldDeviceStackedAreaChartWidget(
        config: MultiFieldStackedAreaChartConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.area_chart_outlined);
  }

  @override
  String getPaletteName() {
    return "Device Multi Field Stacked Area Chart";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return MultiFieldStackedAreaChartConfig.fromJson(config);
    }
    return MultiFieldStackedAreaChartConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Device Multi Field Stacked Area Chart';
  }
}
