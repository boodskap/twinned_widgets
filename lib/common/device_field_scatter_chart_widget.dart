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
  final DateFormat dateFormat = DateFormat('MM/dd HH:mm:ss aa');
  String label = "";
  @override
  void initState() {
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
              backgroundColor: Color(widget.config.bgColor),
              title: ChartTitle(
                text: widget.config.title,
                textStyle: TwinUtils.getTextStyle(
                    FontConfig.fromJson(widget.config.titleFont)),
              ),
              plotAreaBackgroundColor:
                  Color(widget.config.plotAreaBackgroundColor),
              legend: Legend(
                isVisible: widget.config.legendVisibility,
                position: widget.config.legendPosition,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: widget.config.enableTooltip,
                duration: widget.config.duration.toDouble(),
                borderColor: Color(widget.config.toolTipBorderColor),
                color: Color(widget.config.toolTipColor),

                // builder: (data, point, series, pointIndex, seriesIndex) => data,
                textStyle: TwinUtils.getTextStyle(
                    FontConfig.fromJson(widget.config.valueFont)),
              ),
              borderColor: Color(widget.config.borderColor),
              primaryXAxis: const DateTimeAxis(),
              series: [
                ScatterSeries<SeriesData, DateTime>(
                  name: widget.config.field,
                  dataSource: _chatSeries,
                  xValueMapper: (SeriesData sales, _) => sales.stamp,
                  yValueMapper: (SeriesData sales, _) => sales.value,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    height: 5,
                    width: 5,
                    shape: DataMarkerType.circle,
                    borderWidth: 3,
                    borderColor: Color(widget.config.markerColor),
                  ),
                  legendIconType: widget.config.iconType,
                  dataLabelSettings: DataLabelSettings(
                      isVisible: widget.config.dataLabelVisibility),
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
          // double values =
          //     obj['p_source']['data'][widget.config.field].toDouble();
          // String deviceName = obj['p_source']['deviceName'];
          // String assetName = obj['p_source']['asset'] ?? "--";

          Device? device =
              await TwinUtils.getDevice(deviceId: widget.config.deviceId);
          if (device == null) continue;

          // deviceName = device.name;
          DeviceModel? deviceModel =
              await TwinUtils.getDeviceModel(modelId: device.modelId);
          label =
              TwinUtils.getParameterLabel(widget.config.field, deviceModel!);

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
