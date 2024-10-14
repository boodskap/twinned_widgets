import 'package:flutter/material.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/device_model_heatmap_widget/device_model_heatmap_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

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
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig labelFont;
  late FontConfig unitFont;
  bool isValidConfig = false;

  Map<String, Map<String, int>> datasets =
      {}; // Store heatmap data by device ID and parameter
  Map<String, String> deviceNames = {}; // Map to store device IDs to names
  Map<String, String> parameterUnits = {}; // Store units for each parameter
  Map<String, Color> colorSets = {
    'low': Colors.lightBlue,
    'mid_low': Colors.green,
    'medium': Colors.teal,
    'mid_high': Colors.yellow,
    'high': Colors.orange,
    'very_high': Colors.red,
  };

  @override
  void initState() {
    var config = widget.config;
    deviceModelId = config.deviceModelId;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    unitFont = FontConfig.fromJson(config.unitFont);

    isValidConfig = deviceModelId.isNotEmpty;
    super.initState();
    loadDeviceData();
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
                          String unit = parameterUnits[parameter] ??
                              '--'; // Get unit for this parameter
                          return Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  parameter,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  unit.isNotEmpty ? '($unit)' : '--',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
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
                            child: Text(deviceName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          );
                        } else {
                          // Remaining cells: Parameter values
                          String deviceId = deviceIds[row];
                          String parameter = parameters[col - 1];
                          int value = datasets[deviceId]?[parameter] ?? 0;

                          Color color;
                          if (value < 50) {
                            color = colorSets['low']!;
                          } else if (value < 100) {
                            color = colorSets['mid_low']!;
                          } else if (value < 150) {
                            color = colorSets['medium']!;
                          } else if (value < 200) {
                            color = colorSets['mid_high']!;
                          } else if (value < 250) {
                            color = colorSets['high']!;
                          } else {
                            color = colorSets['very_high']!;
                          }

                          return Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                            ),
                            child: Text('$value',
                                style: const TextStyle(color: Colors.white)),
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
                  orientation: LinearGaugeOrientation.vertical,
                  minimum: 0,
                  maximum: 300,
                  axisLabelStyle: const TextStyle(fontSize: 10),
                  axisTrackStyle: LinearAxisTrackStyle(
                    thickness: 15, // Adjust the thickness of the axis
                    gradient: LinearGradient(
                      colors: [
                        colorSets['low']!,
                        colorSets['mid_low']!,
                        colorSets['medium']!,
                        colorSets['mid_high']!,
                        colorSets['high']!,
                        colorSets['very_high']!,
                      ],
                      stops: const [
                        0.0,
                        0.2,
                        0.4,
                        0.6,
                        0.8,
                        1.0,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  ranges: const [
                    LinearGaugeRange(
                      startValue: 0,
                      endValue: 50,
                      color: Colors.transparent,
                    ),
                    LinearGaugeRange(
                      startValue: 50,
                      endValue: 100,
                      color: Colors.transparent,
                    ),
                    LinearGaugeRange(
                      startValue: 100,
                      endValue: 150,
                      color: Colors.transparent,
                    ),
                    LinearGaugeRange(
                      startValue: 150,
                      endValue: 200,
                      color: Colors.transparent,
                    ),
                    LinearGaugeRange(
                      startValue: 200,
                      endValue: 250,
                      color: Colors.transparent,
                    ),
                    LinearGaugeRange(
                      startValue: 250,
                      endValue: 300,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadDeviceData() async {
    try {
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
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<Map<String, dynamic>> values =
            List<Map<String, dynamic>>.from(json['hits']['hits']);

        datasets = {}; // Reset datasets
        deviceNames = {}; // Reset device names

        for (Map<String, dynamic> obj in values) {
          String deviceId = obj['p_source']['id']; // Get device ID
          String deviceName =
              obj['p_source']['name'] ?? deviceId; // Get device name

          Map<String, dynamic> paramNames = obj['p_source']['data'];
          deviceNames[deviceId] = deviceName; // Store device name

          DeviceModel? deviceModel =
              await TwinUtils.getDeviceModel(modelId: deviceModelId);

          for (String param in paramNames.keys) {
            String label =
                TwinUtils.getParameterLabel(param, deviceModel!) ?? param;

            if (label.isEmpty) {
              label = param;
            }

            String unit = TwinUtils.getParameterUnit(param, deviceModel);
            parameterUnits[label] = unit; // Store the unit for this parameter

            var value = obj['p_source']['data'][param];
            if (value is num) {
              datasets.putIfAbsent(deviceId, () => {})[label] =
                  (datasets[deviceId]?[label] ?? 0) +
                      value.toInt(); // Use label as key.
            }
          }
        }

        setState(() {});
      } else {
        debugPrint('Invalid API response.');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  void setup() {
    loadDeviceData();
  }
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
