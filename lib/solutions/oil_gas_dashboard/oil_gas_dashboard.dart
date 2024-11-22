import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/circle_progress_bar_widget/circle_progress_bar_widget.dart';
import 'package:twinned_models/dynamic_text_value_widget/dynamic_text_value_widget.dart';
import 'package:twinned_models/dynamic_value_compare_widget/dynamic_value_compare_widget.dart';
import 'package:twinned_models/multi_field_stacked_area_chart_widget/multi_field_stacked_area_chart_widget.dart';
import 'package:twinned_widgets/solutions/oil_gas_dashboard/circular_progress_bar.dart';
import 'package:twinned_widgets/solutions/oil_gas_dashboard/device_multi_field_stacked_area_chart.dart';
import 'package:twinned_widgets/solutions/oil_gas_dashboard/dynamic_value_compare_widget.dart';
import 'package:twinned_widgets/solutions/oil_gas_dashboard/dynamic_value_text_widget.dart';

class OilGasDashboard extends StatefulWidget {
  const OilGasDashboard({super.key});

  @override
  State<OilGasDashboard> createState() => _OilGasDashboardState();
}

class _OilGasDashboardState extends BaseState<OilGasDashboard> {
  String? deviceId;
  List<String> deviceNames = [];
  String? selectedDeviceName;
  Map<String, String> deviceNameToIdMap = {};

  Widget verticalLine = Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: Container(
      height: 30.0,
      width: 1.0,
      color: Colors.black,
    ),
  );

  /// Fetch devices from API and map them to device IDs
  Future<Map<String, String>> fetchDevices() async {
    try {
      var qRes = await TwinnedSession.instance.twin.searchRecentDeviceData(
        apikey: TwinnedSession.instance.authToken,
        modelId: "cbda9465-73b8-482b-a559-58ed2408f10f",
        body: const FilterSearchReq(search: "*", page: 0, size: 100),
      );

      if (validateResponse(qRes)) {
        final jsonResponse = jsonDecode(qRes.body.toString());
        final values = jsonResponse['values'] as List<dynamic>;

        final Map<String, String> fetchedDeviceNameToIdMap = {};

        for (var item in values) {
          final asset = item['asset'] as String?;
          final deviceId = item['deviceId'] as String?;
          final deviceName = item['name'] as String? ?? 'Unknown Device';

          if (deviceId != null && deviceId.isNotEmpty) {
            if (asset != null && asset.isNotEmpty) {
              fetchedDeviceNameToIdMap[asset] = deviceId;
            } else {
              fetchedDeviceNameToIdMap[deviceName] = deviceId;
            }
          }
        }

        return fetchedDeviceNameToIdMap;
      }
    } catch (e) {
      debugPrint("Error fetching devices: $e");
    }
    return {};
  }

  /// Fetch device ID for a given device name
  Future<String?> fetchDeviceId(String deviceName) async {
    // Check if the deviceName is already in the map
    if (deviceNameToIdMap.containsKey(deviceName)) {
      return deviceNameToIdMap[deviceName];
    }

    // Load data if not already present
    await load();
    return deviceNameToIdMap[deviceName];
  }

  /// Load devices and update the state
  Future<void> load() async {
    if (loading) return;
    loading = true;

    try {
      final newDeviceNameToIdMap = await fetchDevices();

      setState(() {
        deviceNameToIdMap = newDeviceNameToIdMap;
        deviceNames = deviceNameToIdMap.keys.toList();
        selectedDeviceName = deviceNames.isNotEmpty ? deviceNames[0] : null;
        deviceId = selectedDeviceName != null
            ? deviceNameToIdMap[selectedDeviceName]
            : null;
      });
    } catch (e) {
      debugPrint("Error loading devices: $e");
    } finally {
      loading = false;
      refresh();
    }
  }

  @override
  void setup() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          toolbarHeight: 50,
          backgroundColor: Colors.white60,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                children: [
                  const Text(
                    'Oil and Gas Monitoring Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  verticalLine,
                  const Icon(Icons.info_outline),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: FutureBuilder<String?>(
              future: fetchDeviceId(selectedDeviceName ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                }
                final id = snapshot.data;
                if (id == null) {
                  return const Center(child: Text('No device selected'));
                }
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 30,
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(2.0),
                                          ),
                                          child: Column(
                                            children: [
                                              const Expanded(
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(3.0),
                                                    child: Text(
                                                      'Device Operator',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                    ),
                                                    child:
                                                        DropdownButton<String>(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      underline: const SizedBox
                                                          .shrink(),
                                                      elevation: 8,
                                                      value: selectedDeviceName,
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          selectedDeviceName =
                                                              newValue;
                                                          deviceId =
                                                              deviceNameToIdMap[
                                                                  newValue!];
                                                        });
                                                      },
                                                      items: deviceNames
                                                          .map((String device) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: device,
                                                          child: Text(device),
                                                        );
                                                      }).toList(),
                                                      isExpanded: true,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Expanded(
                                                child: SizedBox(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 35,
                                        child: DynamicValueTextCardWidget(
                                          config: DynamicTextValueWidgetConfig(
                                            field: 'flow_pressure',
                                            deviceId: id,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 35,
                                        child: DynamicValueTextCardWidget(
                                          config: DynamicTextValueWidgetConfig(
                                            field: 'gas_oil_ratio',
                                            deviceId: id,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: CircularProgressWidget(
                                    config: CircularProgressBarWidgetConfig(
                                      maximum: 1500,
                                      title: 'Oil Production Rate',
                                      field: 'oil_production',
                                      fillColor: 0XFFE7AB42,
                                      deviceId: id,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: CircularProgressWidget(
                                    config: CircularProgressBarWidgetConfig(
                                      maximum: 2500,
                                      title: 'Gas Production Rate',
                                      field: 'gas_production',
                                      fillColor: 0XFF00E6FF,
                                      deviceId: id,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: CircularProgressWidget(
                                    config: CircularProgressBarWidgetConfig(
                                      title: 'Well Update',
                                      field: 'well_update',
                                      fillColor: 0XFFAC6C7F,
                                      deviceId: id,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: MultiFieldDeviceStackedAreaChartWidget(
                              config: MultiFieldStackedAreaChartConfig(
                                title: 'Gas and Oil Production Trends',
                                deviceId: id,
                                legendPosition: LegendPosition.top,
                                fields: ['oil_production', 'gas_production'],
                                chartColors: [0XFFF3D4A1, 0XFF8FA2C7],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: DynamicValueCompareWidget(
                                    config: DynamicValueCompareWidgetConfig(
                                      deviceId: id,
                                      field: 'gas_boepd',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: DynamicValueCompareWidget(
                                    config: DynamicValueCompareWidgetConfig(
                                      deviceId: id,
                                      field: 'oil_boepd',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
