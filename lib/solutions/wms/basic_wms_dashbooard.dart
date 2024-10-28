import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/device_field_spline_chart/device_field_spline_chart.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';
import 'package:twinned_models/linear_progress_widget_bar/linear_progress_bar_widget.dart';
import 'package:twinned_models/thermometer_temperature/thermometer_temperature.dart';
import 'package:twinned_widgets/common/parameter_info_widget.dart';
import 'package:twinned_widgets/common/parameter_value_widget.dart';
import 'package:twinned_widgets/solutions/wms/current_temperature.dart';
import 'package:twinned_widgets/solutions/wms/forecast_widget.dart';
import 'package:twinned_widgets/solutions/wms/highlights_widget/linear_progressbar_widget.dart';
import 'package:twinned_widgets/solutions/wms/highlights_widget/sunrise_sunset_widget.dart';
import 'package:twinned_widgets/solutions/wms/highlights_widget/uv_index_widget.dart';
import 'package:twinned_widgets/solutions/wms/highlights_widget/compass_widget.dart';
import 'package:twinned_widgets/solutions/wms/spline_chart_wms.dart';
import 'package:twinned_widgets/solutions/wms/thermometer_widget.dart';
import 'package:twinned_widgets/solutions/wms/week_humidity_widget.dart';
import 'package:twinned_models/parameter_info_widget/parameter_info_widget.dart';
import 'package:twinned_models/parameter_value_widget/parameter_value_widget.dart';
import 'package:twinned_models/compass_widget/compass_widget.dart';

class BasicWmsDashboard extends StatefulWidget {
  const BasicWmsDashboard({super.key});

  @override
  State<BasicWmsDashboard> createState() => _BasicWmsDashboardState();
}

class _BasicWmsDashboardState extends BaseState<BasicWmsDashboard> {
  bool loading = false;
  String? deviceId;
  List<String> deviceNames = [];
  String? selectedDeviceName;
  Map<String, String> deviceNameToIdMap = {};

  Future<Map<String, dynamic>?>? deviceDataFuture;

  @override
  void initState() {
    super.initState();
    loadDevices();
  }

  Future<void> loadDevices() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.searchRecentDeviceData(
        apikey: TwinnedSession.instance.authToken,
        modelId: "4bcbae44-72c2-4aa0-b745-432ae1b6c3e3",
        body: const FilterSearchReq(search: "*", page: 0, size: 100),
      );

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
      'uv': 220.0,
      'winddirection': 178.0,
      'windspeed': 130.0,
      'sunrise': 1719965109000,
      'sunset': 1719967354000,
      'visibility': 12,
      'airquality': 220,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          color: const Color(0XFF005583),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Weather Monitor Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0XFFFFFFFF),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: "Select Device",
                onSelected: (value) {
                  setState(() {
                    selectedDeviceName = value;
                    deviceId = deviceNameToIdMap[value];
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
                        fontWeight: FontWeight.bold,
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
          child: FutureBuilder<Map<String, dynamic>?>(
            future: deviceDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final deviceData = snapshot.data!;
              return buildDashboard(deviceData);
            },
          ),
        ),
      ],
    );
  }

  Widget buildDashboard(Map<String, dynamic> deviceData) {
    return Column(
      children: [
        Expanded(
          flex: 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 30,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CurrentTemperatureWidget(
                    config: DeviceFieldRangeGaugeWidgetConfig(
                      deviceId: deviceId ?? "",
                      fields: ['temperature', 'humidity', 'windspeed'],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 70,
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 77,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: DeviceFieldSplineAreaChartWidget(
                                  config: DeviceFieldSplineChartWidgetConfig(
                                    deviceId: deviceId ?? "",
                                    field: 'temperature',
                                    enableTooltip: true,
                                  ),
                                ),
                              ),
                            ),
                            divider(width: 4, horizontal: true),
                            Expanded(
                              flex: 23,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, right: 4),
                                child: ThermometerWidget(
                                  config: ThermometerTemperatureWidgetConfig(
                                    deviceId: deviceId ?? "",
                                    field: 'temperature',
                                    title: 'Temperature Record',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 4, right: 4, bottom: 4),
                        child: HumidityWeekWidget(
                          config: DeviceFieldRangeGaugeWidgetConfig(
                            deviceId: deviceId ?? "",
                          ),
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
          flex: 50,
          child: Row(
            children: [
              Expanded(
                flex: 30,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                  child: ForecastWidget(
                    config: DeviceFieldRangeGaugeWidgetConfig(
                      deviceId: deviceId ?? "",
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 70,
                child: Column(
                  children: [
                    Expanded(
                      flex: 10,
                      child: Container(
                        color: const Color(0XFFEEF7FF),
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "TODAY'S HIGHLIGHTS",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 60,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(),
                              child: UvIndexWidget(
                                config: DeviceFieldRangeGaugeWidgetConfig(
                                  deviceId: deviceId ?? "",
                                  field: 'uv',
                                  title: 'UV Index',
                                  minimum: 0,
                                  maximum: 15,
                                  valueFont: {
                                    "fontSize": 16,
                                    "fontColor": 0XFF7DA9E1,
                                    "fontBold": true
                                  },
                                  labelFont: {
                                    "fontSize": 12,
                                    "fontColor": 0xff000000,
                                    "fontBold": false
                                  },
                                  backgroundColor: 0xFFB3E5FC,
                                  valueColor: 0XFF7DA9E1,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: CompassWidget(
                                config: CompassWidgetConfig(
                                  deviceId: deviceId ?? "",
                                  title: 'Wind Status',
                                  // minimum: 0,
                                  // maximum: 360,
                                  valueFont: {
                                    "fontSize": 16,
                                    "fontColor": 0XFF7DA9E1,
                                    "fontBold": true
                                  },
                                  // backgroundColor: 0xFFB3E5FC,
                                  // markerColor: 0XFF7DA9E1,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 4),
                              child: SunriseSunsetWidget(
                                config: DeviceFieldRangeGaugeWidgetConfig(
                                  deviceId: deviceId ?? "",
                                  field: 'pressure',
                                  fields: ['sunrise', 'sunset'],
                                  title: 'Sunrise & Sunset',
                                  backgroundColor: 0xFFB3E5FC,
                                  valueColor: 0XFF7DA9E1,
                                  labelFont: {
                                    "fontSize": 12,
                                    "fontColor": 0xff000000,
                                    "fontBold": false
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 30,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ProgressBarWidget(
                                config: LinearProgressBarWidgetConfig(
                                  deviceId: deviceId ?? "",
                                  field: 'humidity',
                                  title: 'Humidity',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, top: 4, bottom: 4),
                              child: ParameterInfoWidget(
                                config: ParameterInfoWidgetConfig(
                                  deviceId: deviceId ?? "",
                                  field: 'visibility',
                                  title: 'Visibility',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: ParameterValueWidget(
                                config: ParameterValueWidgetConfig(
                                  deviceId: deviceId ?? "",
                                  field: 'airquality',
                                  title: 'Air Quality',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void setup() {
    loadDevices();
  }
}
