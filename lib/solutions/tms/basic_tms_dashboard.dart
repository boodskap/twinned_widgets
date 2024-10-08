import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/device_field_spherical_tank/device_field_spherical_tank.dart';
import 'package:twinned_models/multi_field_device_spline_chart/multi_field_device_spline_chart.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';
import 'package:twinned_widgets/solutions/tms/device_field_radial_gauge_widget.dart.dart';
import 'package:twinned_widgets/solutions/tms/device_field_spherical_tank_widget.dart';
import 'package:twinned_widgets/solutions/tms/device_field_temperature_gauge_widget.dart';
import 'package:twinned_widgets/solutions/tms/multi_field_device_spline_area_chart_widget.dart';

class BasicTMSDashboardScreen extends StatefulWidget {
  final DeviceData deviceData;
  const BasicTMSDashboardScreen({super.key, required this.deviceData});

  @override
  State<BasicTMSDashboardScreen> createState() =>
      _BasicTMSDashboardScreenState();
}

class _BasicTMSDashboardScreenState extends BaseState<BasicTMSDashboardScreen> {
  String field = "volume";
  String? deviceId;
  String? modelId;

  // bool loading = false;

  List<String> deviceNames = [];
  String? selectedDeviceName;
  Map<String, String> deviceNameToIdMap = {};

  Future<Map<String, dynamic>?>? deviceDataFuture;

  @override
  void initState() {
    var dd = widget.deviceData;
    modelId = dd.modelId;
    super.initState();
    // loadDevices();
  }

  Future<void> loadDevices() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.searchRecentDeviceData(
        apikey: TwinnedSession.instance.authToken,
        modelId: modelId,
        body: const FilterSearchReq(search: "*", page: 0, size: 100),
      );

      // debugPrint(qRes.bodyString.toString());

      if (validateResponse(qRes)) {
        final jsonResponse = jsonDecode(qRes.body.toString());
        final values = jsonResponse['values'] as List<dynamic>;

        final Map<String, String> newDeviceNameToIdMap = {};

        for (var item in values) {
          final asset = item['asset'] as String?;
          final deviceId = item['deviceId'] as String?;
          final deviceName = item['name'] as String? ?? 'Unknown Device';

          if (asset != null && asset.isNotEmpty) {
            newDeviceNameToIdMap[asset] = deviceId ?? '';
          } else {
            newDeviceNameToIdMap[deviceName] = deviceId ?? '';
          }
        }

        setState(() {
          deviceNameToIdMap = newDeviceNameToIdMap;
          deviceNames = deviceNameToIdMap.keys.toList();
          selectedDeviceName = deviceNames.isNotEmpty ? deviceNames[0] : null;
          deviceId =
              deviceNames.isNotEmpty ? deviceNameToIdMap[deviceNames[0]]! : '';
          deviceDataFuture = loadDeviceData();
        });
      }

      loading = false;
      refresh();
    });
  }

  Future<Map<String, dynamic>?> loadDeviceData() async {
    if (deviceId == null) return null;

    await Future.delayed(const Duration(seconds: 1));

    return {
      'temperature': 22.0,
      'humidity': 55.0,
      'pressure': 1500.0,
      'battery': 4000.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: deviceDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final deviceData = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color(0XFF005583),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Tooltip(
                      message: 'Home',
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.keyboard_backspace,
                          color: Color(0XFFFFFFFF),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Tank Monitoring System",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0XFFFFFFFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: "Select Device",
                      onSelected: (value) {
                        setState(() {
                          selectedDeviceName = value;
                          deviceId = deviceNameToIdMap[value!];
                          deviceDataFuture = loadDeviceData();
                        });
                      },
                      itemBuilder: (context) {
                        return deviceNames.map((deviceName) {
                          return PopupMenuItem<String>(
                            value: deviceName,
                            child: Text(deviceName),
                          );
                        }).toList();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedDeviceName ?? 'Select Device',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0XFFFFFFFF),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0XFFFFFFFF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 50,
                child: Row(
                  children: [
                    Expanded(
                      flex: 30,
                      child: DeviceFieldSphericalTankWidget(
                        config: DeviceFieldSphericalTankWidgetConfig(
                          deviceId: deviceId ?? "",
                          field: "volume",
                          valueFont: {
                            "fontSize": 40,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                          titleFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                          subTitleFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": false,
                          },
                        ),
                      ),
                    ),
                    divider(horizontal: true),
                    Expanded(
                      flex: 70,
                      child: MultiFieldDeviceSplineChartWidget(
                        config: MultiFieldDeviceSplineChartWidgetConfig(
                          deviceId: deviceId ?? '',
                          fields: [
                            "temperature",
                            "level",
                          ],
                          chartBorderColor: 0x00ffffff,
                          labelBgColor: 0xFF9E9E9E,
                          legendPosition: LegendPosition.bottom,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Climate",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(
                flex: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: DeviceFieldTemperatureGaugeWidget(
                        deviceId: deviceId ?? "",
                        field: "temperature",
                        minimum: 0,
                        maximum: 100,
                        aboveTemperatureColor: Colors.red,
                        gaugeColor: Colors.black26,
                        belowTemperatureColor: Colors.blue,
                        temperatureValue: 0,
                      ),
                    ),
                    divider(horizontal: true),
                    Expanded(
                      child: DeviceFieldRadialGaugeWidget(
                        config: DeviceFieldRangeGaugeWidgetConfig(
                          deviceId: deviceId ?? '',
                          field: "level",
                          gradientColors: [0xff95a9c2, 0xff6fa2d1, 0xff4797de],
                          valueFont: {
                            "fontSize": 20,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                          titleFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                          subTitleFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": false,
                          },
                          labelFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                        ),
                      ),
                    ),
                    divider(horizontal: true),
                    Expanded(
                      child: DeviceFieldRadialGaugeWidget(
                        config: DeviceFieldRangeGaugeWidgetConfig(
                          deviceId: deviceId ?? "",
                          field: "distance",
                          minimum: 0,
                          maximum: 200,
                          interval: 100,
                          gradientColors: [0xffa6a9b3, 0xffcf9874, 0xffeb8938],
                          valueFont: {
                            "fontSize": 20,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                          titleFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                          subTitleFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": false,
                          },
                          labelFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                        ),
                      ),
                    ),
                    divider(horizontal: true),
                    Expanded(
                      child: DeviceFieldRadialGaugeWidget(
                        config: DeviceFieldRangeGaugeWidgetConfig(
                          deviceId: deviceId ?? "",
                          field: "battery",
                          minimum: 2000,
                          maximum: 6000,
                          interval: 2000,
                          gradientColors: [
                            0xffd17c6b,
                            0xff47b582,
                            0xff429ed6,
                          ],
                          valueFont: {
                            "fontSize": 20,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                          titleFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                          subTitleFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": false,
                          },
                          labelFont: {
                            "fontSize": 12,
                            "fontColor": 0xff000000,
                            "fontBold": true,
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void setup() {
    loadDevices();
  }
}
