import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/graph_card_widget.dart/device_field_graph_card_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class DeviceFieldGraphCardWidget extends StatefulWidget {
  final DeviceFieldGraphCardWidgetConfig config;
  const DeviceFieldGraphCardWidget({super.key, required this.config});

  @override
  _DeviceFieldGraphCardWidgetState createState() =>
      _DeviceFieldGraphCardWidgetState();
}

class _DeviceFieldGraphCardWidgetState
    extends BaseState<DeviceFieldGraphCardWidget> {
  final List<SeriesData> _chartSeries = [];
  final DateFormat dateFormat = DateFormat('MM/dd hh:mm:aa');
  late String deviceId;
  late String field;
  late double elevation;
  late double tooltipDuration;
  late FontConfig valueFont;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late Color cardBgColor;
  late Color chartColor;
  late Color borderColor;
  late Color tooltipColor;

  String fieldIcon = '';
  String fieldLabel = '';
  String value = '-';
  String unit = '';
  bool apiLoadingStatus = false;
  bool isValidConfig = false;

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    field = config.field;
    elevation = config.elevation;
    tooltipDuration = config.tooltipDuration;
    borderColor = Color(config.borderColor);
    cardBgColor = Color(config.cardBgColor);
    chartColor = Color(config.chartColor);
    tooltipColor = Color(config.tooltipColor);
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);
    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
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
    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: loading
          ? const CircularProgressIndicator()
          : Card(
              color: cardBgColor,
              elevation: elevation,
              child: SizedBox(
                height: 200,
                width: 200,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (fieldIcon.isEmpty)
                          const Icon(
                            Icons.question_mark_rounded,
                            size: 40,
                            color: Colors.green,
                          ),
                        if (fieldIcon != "")
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                                height: 30,
                                width: 30,
                                child: TwinImageHelper.getDomainImage(fieldIcon,
                                    height: 40, width: 40)),
                          ),
                        Expanded(
                          child: Text(
                            fieldLabel,
                            overflow: TextOverflow
                                .ellipsis, // Clip the text if it overflows
                            softWrap: false, // Prevent wrapping the text
                            style: TwinUtils.getTextStyle(titleFont),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text('$value ${unit.isEmpty ? '--' : unit}',
                          style: TwinUtils.getTextStyle(valueFont)),
                    ),
                    SizedBox(
                      height: 100,
                      child: SfCartesianChart(
                        enableAxisAnimation: true,
                        primaryYAxis: const NumericAxis(isVisible: false),
                        primaryXAxis: DateTimeAxis(
                          isVisible: false,
                          dateFormat: dateFormat,
                        ),
                        plotAreaBackgroundColor: Colors.transparent,
                        plotAreaBorderWidth: 0,
                        borderWidth: 0,
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          duration: tooltipDuration,
                          borderColor: const Color(0xFF000000),
                          color: tooltipColor,
                        ),
                        series: <SplineAreaSeries<SeriesData, DateTime>>[
                          SplineAreaSeries<SeriesData, DateTime>(
                            borderWidth: 1.5,
                            color: chartColor,
                            borderColor: borderColor,
                            dataSource: _chartSeries,
                            xValueMapper: (SeriesData data, _) => data.stamp,
                            yValueMapper: (SeriesData data, _) => data.field,
                            name: fieldLabel,
                            markerSettings: const MarkerSettings(
                              isVisible: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _load() async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;
    _chartSeries.clear();
    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(page: 0, size: 10, source: [], mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
            {
              "exists": {"field": "data.$field"}
            },
          ], sort: {
            'updatedStamp': 'desc'
          }, conditions: [], queryConditions: [], boolConditions: []));

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];

        if (values.isNotEmpty) {
          dynamic latestValue = values[0]['p_source']['data'][field];

          Map<String, dynamic> latestData = values[0];
          var modelId = latestData['p_source']['modelId'];
          DeviceModel? deviceModel =
              await TwinUtils.getDeviceModel(modelId: modelId);
          fieldLabel = TwinUtils.getParameterLabel(field, deviceModel!);
          fieldIcon = TwinUtils.getParameterIcon(field, deviceModel);
          unit = TwinUtils.getParameterUnit(field, deviceModel);
          value = latestValue.toString();

          for (Map<String, dynamic> obj in values) {
            int millis = obj['p_source']['updatedStamp'];
            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
            dynamic seriesValue = obj['p_source']['data'][field];

            _chartSeries.add(SeriesData(
                stamp: dateTime,
                formattedStamp: dateFormat.format(dateTime),
                field: seriesValue));
          }
        }
      }
    });

    loading = false;
    apiLoadingStatus = true;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}

class SeriesData {
  final DateTime stamp;
  final String formattedStamp;
  final double field;

  SeriesData({
    required this.stamp,
    required this.formattedStamp,
    required this.field,
  });
}

class DeviceFieldGraphCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldGraphCardWidget(
        config: DeviceFieldGraphCardWidgetConfig.fromJson(config));
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceFieldGraphCardWidgetConfig.fromJson(config);
    }
    return DeviceFieldGraphCardWidgetConfig();
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.gradient_sharp);
  }

  @override
  String getPaletteName() {
    return 'Graph Card Widget';
  }

  @override
  String getPaletteTooltip() {
    return 'Graph Card Widget';
  }
}
