import 'package:flutter/material.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/device_model_heatmap_widget/device_model_heatmap_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';

class DeviceModelHeatmapWidget extends StatefulWidget {
  final DeviceModelHeatmapWidgetConfig config;
  const DeviceModelHeatmapWidget({super.key, required this.config});

  @override
  _DeviceModelHeatmapWidgetState createState() =>
      _DeviceModelHeatmapWidgetState();
}

class _DeviceModelHeatmapWidgetState
    extends BaseState<DeviceModelHeatmapWidget> {
  late String deviceModelId;
  late String modelName;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig labelFont;
  late FontConfig unitFont;
  bool isValidConfig = false;

  Map<String, Map<String, int>> datasets =
      {}; // Store heatmap data by device ID and parameter
  Map<String, String> deviceNames = {};
  Map<String, String> parameterUnits = {};

  @override
  void initState() {
    var config = widget.config;
    deviceModelId = config.deviceModelId;
    modelName = '';
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    unitFont = FontConfig.fromJson(config.unitFont);

    isValidConfig = deviceModelId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> deviceIds = datasets.keys.toList();
    List<String> parameters =
        datasets.isNotEmpty ? datasets[deviceIds.first]!.keys.toList() : [];

    if (!isValidConfig) {
      return const Center(
        child: Text(
          "Not Configured Properly",
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heatmap section
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      modelName.isNotEmpty ? modelName : '--',
                      style: TwinUtils.getTextStyle(titleFont),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: parameters.length + 1,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      itemCount: (deviceIds.length + 1) *
                          (parameters.length + 1), // Total items in grid
                      itemBuilder: (context, index) {
                        int row = index ~/ (parameters.length + 1);
                        int col = index % (parameters.length + 1);

                        if (row == deviceIds.length && col == 0) {
                          // Bottom-left corner
                          return Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            child: const Text(''),
                          );
                        } else if (row == deviceIds.length) {
                          // Bottom row: Parameter names and units
                          String parameter = parameters[col - 1];
                          String unit = parameterUnits[parameter] ?? '--';
                          return Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  parameter,
                                  style: TwinUtils.getTextStyle(labelFont)
                                      .copyWith(
                                          overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  unit.isNotEmpty ? '($unit)' : '--',
                                  style: TwinUtils.getTextStyle(unitFont)
                                      .copyWith(
                                          overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          );
                        } else if (col == 0) {
                          // First column: Device names
                          String deviceId = deviceIds[row];
                          String deviceName = deviceNames[deviceId] ??
                              deviceId; // Use device name if available
                          return Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            child: Text(
                              deviceName,
                              style: TwinUtils.getTextStyle(labelFont),
                            ),
                          );
                        } else {
                          // Remaining cells: Parameter values
                          String deviceId = deviceIds[row];
                          String parameter = parameters[col - 1];
                          int value = datasets[deviceId]?[parameter] ?? 0;

                          // Color matching logic
                          Color color = Colors.transparent; // Default color

                          for (var range in widget.config.ranges) {
                            int from = range['from'];
                            int to = range['to'] ??
                                double.infinity; // Handle 'to' being null

                            if (value >= from && value <= to) {
                              color = colorFromInt(
                                  range['color']); // Use the parsed color here
                              break;
                            }
                          }

                          // Now apply `color` to your heatmap cell widget
                          return Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                            ),
                            child: Text('$value',
                                style: TwinUtils.getTextStyle(valueFont)),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Gauge section
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 200,
                width: 70,
                child: SfLinearGauge(
                  animateAxis: true,
                  // Define a gradient background for the axis track
                  axisTrackStyle: LinearAxisTrackStyle(
                    thickness: 15,
                    gradient: LinearGradient(
                      colors: widget.config.ranges.map((range) {
                        return colorFromInt(
                            range['color']); // Convert int to Color
                      }).toList(),
                      stops: widget.config.ranges.map((range) {
                        // Calculate the normalized stop value based on the range
                        double startValue = range['from'].toDouble();
                        return (startValue -
                                (widget.config.ranges.first['from']
                                    as double)) /
                            ((widget.config.ranges.last['to']?.toDouble() ??
                                    300) -
                                (widget.config.ranges.first['from'] as double));
                      }).toList(),
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  orientation: LinearGaugeOrientation.vertical,
                  minimum: widget.config.ranges.isNotEmpty
                      ? widget.config.ranges.first['from'].toDouble()
                      : 0,
                  maximum: widget.config.ranges.isNotEmpty
                      ? widget.config.ranges.last['to']?.toDouble() ?? 300
                      : 600,
                  axisLabelStyle: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    if (!isValidConfig || loading) return;
    loading = true;

    await execute(
      () async {
        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            source: [],
            page: 0,
            size: 100,
            mustConditions: [
              {
                "match_phrase": {
                  "modelId": deviceModelId,
                }
              },
            ],
          ),
        );

        if (validateResponse(qRes)) {
          Map<String, dynamic> json =
              qRes.body!.result! as Map<String, dynamic>;
          List<Map<String, dynamic>> values =
              List<Map<String, dynamic>>.from(json['hits']['hits']);

          datasets = {}; // Reset datasets
          deviceNames = {}; // Reset device names

          for (Map<String, dynamic> obj in values) {
            String deviceId = obj['p_source']['id'];
            String deviceName = obj['p_source']['name'] ?? deviceId;
            String fetchedModelName = obj['p_source']['modelName'] ?? '';

            if (fetchedModelName.isNotEmpty) {
              refresh(
                sync: () {
                  modelName = fetchedModelName;
                },
              );
            }

            Map<String, dynamic> paramNames = obj['p_source']['data'];
            deviceNames[deviceId] = deviceName;

            DeviceModel? deviceModel =
                await TwinUtils.getDeviceModel(modelId: deviceModelId);

            for (String param in paramNames.keys) {
              String label =
                  TwinUtils.getParameterLabel(param, deviceModel!) ?? param;

              if (label.isEmpty) {
                label = param;
              }

              String unit = TwinUtils.getParameterUnit(param, deviceModel);
              parameterUnits[label] = unit;

              var value = obj['p_source']['data'][param];
              if (value is num) {
                datasets.putIfAbsent(deviceId, () => {})[label] =
                    (datasets[deviceId]?[label] ?? 0) + value.toInt();
              }
            }
          }
          refresh();
        }
      },
    );

    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}

Color colorFromInt(int colorValue) {
  return Color(colorValue);
}

class DeviceModelHeatmapWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceModelHeatmapWidget(
      config: DeviceModelHeatmapWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.grid_on);
  }

  @override
  String getPaletteName() {
    return "Device Model Heatmap widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return DeviceModelHeatmapWidgetConfig.fromJson(config);
    }
    return DeviceModelHeatmapWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Device Model Heatmap Widget';
  }
}
