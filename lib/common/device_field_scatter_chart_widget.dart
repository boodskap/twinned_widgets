import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/device_field_scatter_chart/device_field_scatter_chart.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
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
  final DateFormat dateFormat = DateFormat(' HH:mm aa');
  String label = "";
// bool loading =false;
  late String deviceId;
  late String field;
  late String title;
  late FontConfig titleFont;
  late FontConfig tooltipFont;
  late FontConfig legendFont;
  late Color bgColor;
  late Color borderColor;
  late Color plotAreaBackgroundColor;
  late Color toolTipColor;
  late Color toolTipBorderColor;
  late Color markerColor;
  late double duration;
  late bool legendVisibility;
  late LegendPosition legendPosition;
  late LegendIconType legendIconType;
  late DataMarkerType dataMarkerType;
  late bool dataLabelVisibility;
  late bool enableTooltip;

  @override
  void initState() {
    field = widget.config.field;
    deviceId = widget.config.deviceId;
    title = widget.config.title;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    tooltipFont = FontConfig.fromJson(widget.config.tooltipFont);
    legendFont = FontConfig.fromJson(widget.config.legendFont);
    bgColor = Color(widget.config.bgColor);
    borderColor = Color(widget.config.borderColor);
    plotAreaBackgroundColor = Color(widget.config.plotAreaBackgroundColor);
    toolTipColor = Color(widget.config.toolTipColor);
    toolTipBorderColor = Color(widget.config.toolTipBorderColor);
    markerColor = Color(widget.config.markerColor);
    duration = widget.config.duration;
    legendVisibility = widget.config.legendVisibility;
    legendPosition = widget.config.legendPosition;
    legendIconType = widget.config.iconType;
    dataMarkerType = widget.config.dataMarkerType;
    dataLabelVisibility = widget.config.dataLabelVisibility;
    enableTooltip = widget.config.enableTooltip;
    isValidConfig =
        widget.config.field.isNotEmpty && widget.config.deviceId.isNotEmpty;
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
              backgroundColor: bgColor,
              title: ChartTitle(
                text: title,
                textStyle: TwinUtils.getTextStyle(titleFont),
              ),
              plotAreaBackgroundColor: plotAreaBackgroundColor,
              legend: Legend(
                isVisible: legendVisibility,
                position: legendPosition,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: enableTooltip,
                duration: duration,
                borderColor: toolTipBorderColor,
                color: toolTipColor,
                textStyle: TwinUtils.getTextStyle(tooltipFont),
                format: 'point.tooltipContent',
                builder: (dynamic data, dynamic point, dynamic series,
                    int pointIndex, int seriesIndex) {
                  final SeriesData seriesData = _chatSeries[pointIndex];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8),
                        child: Text('${seriesData.label}: ${seriesData.value}',
                            style: TwinUtils.getTextStyle(tooltipFont)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8),
                        child: Text(dateFormat.format(seriesData.stamp),
                            style: TwinUtils.getTextStyle(tooltipFont)),
                      ),
                    ],
                  );
                },
              ),
              borderColor: borderColor,
              primaryXAxis: const DateTimeAxis(),
              series: [
                ScatterSeries<SeriesData, DateTime>(
                  name: field,
                  dataSource: _chatSeries,
                  xValueMapper: (SeriesData data, _) => data.stamp,
                  yValueMapper: (SeriesData data, _) => data.value,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 5,
                    width: 5,
                    shape: dataMarkerType,
                    borderWidth: 3,
                    borderColor: markerColor,
                  ),
                  legendIconType: legendIconType,
                  legendItemText: label,
                  dataLabelSettings:
                      DataLabelSettings(isVisible: dataLabelVisibility),
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
              "match_phrase": {"deviceId": deviceId}
            },
            {
              "exists": {"field": "data.$field"}
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
          dynamic value = obj['p_source']['data'][field];

          Device? device = await TwinUtils.getDevice(deviceId: deviceId);
          if (device == null) continue;

          // deviceName = device.name;
          DeviceModel? deviceModel =
              await TwinUtils.getDeviceModel(modelId: device.modelId);
          label = TwinUtils.getParameterLabel(field, deviceModel!);

          _chatSeries.add(SeriesData(
            stamp: dateTime,
            formattedStamp: formattedDate,
            value: value,
            label: label,
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
  final String label;

  SeriesData({
    required this.stamp,
    required this.formattedStamp,
    required this.value,
    required this.label,
  });
}

class DeviceFieldScatterChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldScatterChartWidget(
      config: DeviceFieldScatterChartWidgetConfig.fromJson(config),
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
      return DeviceFieldScatterChartWidgetConfig.fromJson(config);
    }
    return DeviceFieldScatterChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Scatter chart based on device field';
  }
}
