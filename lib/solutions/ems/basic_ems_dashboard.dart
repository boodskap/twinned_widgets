import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/common/circle_progress_bar_widget.dart';
import 'package:twinned_widgets/common/device_multi_field_stats_widget.dart';
import 'package:twinned_widgets/common/generic_card_image_widget.dart';
import 'package:twinned_widgets/common/infrastructure_card_widget.dart';
import 'package:twinned_widgets/common/vertical_progress_bar_widget.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_models/ems/multiple_field_stats.dart';
import 'package:twinned_models/ems/circular_progress_bar.dart';
import 'package:twinned_models/ems/vertical_progress_bar.dart';
import 'package:twinned_models/ems/generic_card_image.dart';
import 'package:twinned_models/ems/infrastructure_card.dart';
import 'package:twinned_api/twinned_api.dart';

class EMSDashboard extends StatefulWidget {
  const EMSDashboard({super.key, required this.title});
  final String title;

  @override
  State<EMSDashboard> createState() => _EMSDashboardState();
}

class _EMSDashboardState extends BaseState<EMSDashboard> {
  String? selectedDeviceId;
  String? deviceId;
  String? deviceModelId = "";
  List<String> deviceNames = [];
  String? selectedDeviceName;
  Map<String, String> deviceNameToIdMap = {};
  Future<Map<String, dynamic>?>? deviceDataFuture;
  List filteredValues = [];
  @override
  void initState() {
    loadDevices();
    super.initState();
  }

  Future<void> loadDevices() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.searchRecentDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: FilterSearchReq(search: "*", page: 0, size: 1000),
      );
      debugPrint(qRes.bodyString.toString());
      if (validateResponse(qRes)) {
        final jsonResponse = jsonDecode(qRes.body.toString());
        final values = jsonResponse['values'] as List<dynamic>;

        filteredValues = values
            .where((item) => (item['asset'] as String).isNotEmpty)
            .toList();

     
        setState(() {
          deviceNameToIdMap = {
            for (var item in filteredValues)
              item['asset'] as String: item['deviceId'] as String
          };
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

    await Future.delayed(const Duration(seconds: 0));
    return {};
  }

  @override
  Widget build(BuildContext context) {
    if (!TwinnedSession.instance.authToken.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(0),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: deviceDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(0),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 50,
                  color: const Color(0XFF005583),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDeviceName,
                          hint: const Text('Select Device'),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          items: deviceNames.map((deviceName) {
                            return DropdownMenuItem<String>(
                              value: deviceName,
                              child: Text(
                                deviceName,
                                style:
                                    const TextStyle(color: Color(0XFF005583)),
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return deviceNames.map((deviceName) {
                              return Text(
                                deviceName,
                                style: const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedDeviceName = value;
                              deviceId = deviceNameToIdMap[value!]!;
                           
                              for (var deviceData in filteredValues) {
                                if (deviceData['deviceId'] == deviceId) {
                                  deviceModelId = deviceData['modelId'];
                                }
                              }
                              deviceDataFuture = loadDeviceData();
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          iconSize: 24,
                          isDense: true,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 380,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex:20,
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 200,
                            maxHeight: 380,
                          ),
                          child: GenericCardImageWidget(
                              config: GenericCardImageWidgetConfig(
                                  deviceId: deviceId!,
                                  field: "energy",
                                  unit: "kwh",
                                  backgroundImage:
                                      "efe31993-89ad-447d-8f0d-b04021ca692f",
                                  backgroundColor: 4294422314,
                                  heading: "Total",
                                  headingFont: {
                                    "fontFamily": "Open Sans",
                                    "fontSize": 16,
                                    "fontColor": 4294967295,
                                    "fontBold": true
                                  },
                                  valueFont: {
                                    "fontFamily": "Open Sans",
                                    "fontSize": 30,
                                    "fontColor": 4294967295,
                                    "fontBold": false
                                  },
                                  content: "Energy consumed per minute",
                                  contentFont: {
                                    "fontFamily": "Open Sans",
                                    "fontSize": 15,
                                    "fontColor": 4294422314,
                                    "fontBold": true
                                  },
                                  contentImage:
                                      "c4552a0a-a60c-4639-9d8e-d856888ec3b8",
                                  width: 320,
                                  height: 380,
                                  opacity: 0.6,
                                  seconds: 60,
                                  backgroundImageHeight: 300)),
                        ),
                      ),
                      Expanded(
                        flex:40,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CardLayoutSection(
                            minHeight: 200,
                            maxHeight: 380,
                            child: MultipleFieldStatsWidget(
                                config: MultipleFieldStatsWidgetConfig(
                                    title: "Current (Amperage) and Power",
                                    titleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 20,
                                      "fontColor": 4278190080,
                                      "fontBold": true
                                    },
                                    subTitle: "Realtime - last day",
                                    subTitleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 16,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    deviceId: deviceId!,
                                    field: ["current", "power"],
                                    chartType: ChartType.spline,
                                    axisLabelFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 12,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    statsHeadingFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 13,
                                      "fontColor": 4294642700,
                                      "fontBold": true
                                    },
                                    statsValueFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 11,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    width: 600,
                                    height: 250,
                                    chartSeriesColors: [4294920249, 4285872317],
                                    minLabelText: "Min",
                                    maxLabelText: "Max",
                                    avgLabelText: "Avg",
                                    totalLabelText: "Total",
                                    showLabel: false,
                                    showStats: true,
                                    showMinValue: true,
                                    showMaxValue: true,
                                    showTotalValue: false,
                                    showAvgValue: true,
                                    showTooltip: true,
                                    showLegend: true)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex:40,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CardLayoutSection(
                            minHeight: 200,
                            maxHeight: 380,
                            child: MultipleFieldStatsWidget(
                                config: MultipleFieldStatsWidgetConfig(
                                    title: "Voltage and Frequency",
                                    titleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 20,
                                      "fontColor": 4278190080,
                                      "fontBold": true
                                    },
                                    subTitle: "Realtime - last day",
                                    subTitleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 16,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    deviceId: deviceId!,
                                    field: ["voltage", "frequency"],
                                    chartType: ChartType.spline,
                                    axisLabelFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 12,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    statsHeadingFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 13,
                                      "fontColor": 4294642700,
                                      "fontBold": true
                                    },
                                    statsValueFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 11,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    width: 600,
                                    height: 250,
                                    chartSeriesColors: [4288995580, 4282490921],
                                    minLabelText: "Min",
                                    maxLabelText: "Max",
                                    avgLabelText: "Avg",
                                    totalLabelText: "Total",
                                    showLabel: false,
                                    showStats: true,
                                    showMinValue: true,
                                    showMaxValue: true,
                                    showTotalValue: false,
                                    showAvgValue: true,
                                    showTooltip: true,
                                    showLegend: true)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 380,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex:20,
                        child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 200,
                              maxHeight: 380,
                            ),
                            child: InfrastructureCardWidget(
                                config: InfrastructureCardWidgetConfig(
                                    deviceModelId: deviceModelId!,
                                    deviceId: deviceId!,
                                    backgroundColor: 4294967295,
                                    title: "Infrastructure",
                                    titleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 22,
                                      "fontColor": 4278190080,
                                      "fontBold": true
                                    },
                                    titleIcon:
                                        "cf581f8c-ac6c-4579-9c56-a40a7997e651",
                                    premiseHeading: "Premise",
                                    premiseIcon:
                                        "f3612da8-ae99-490e-9fa4-7179151d31ae",
                                    facilityHeading: "Facility",
                                    facilityIcon:
                                        "d8d1f658-3c94-4eb3-b986-512fbf9e7ec2",
                                    floorHeading: "Floor",
                                    floorIcon:
                                        "8004656f-509f-4139-811a-1f831956e97c",
                                    assetHeading: "Asset",
                                    assetIcon:
                                        "37b3ea67-5ff1-4a5f-9cf5-27e36cbf2ab5",
                                    headingFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 16,
                                      "fontColor": 4278190080,
                                      "fontBold": true
                                    },
                                    valueFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 14,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    width: 320,
                                    height: 380))),
                      ),
                      Expanded(
                        flex:48,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CardLayoutSection(
                            minHeight: 200,
                            maxHeight: 380,
                            child: MultipleFieldStatsWidget(
                                config: MultipleFieldStatsWidgetConfig(
                                    title: "Energy Consumption",
                                    titleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 20,
                                      "fontColor": 4278190080,
                                      "fontBold": true
                                    },
                                    subTitle: "Realtime - last day",
                                    subTitleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 16,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    deviceId: deviceId!,
                                    field: ["energy"],
                                    chartType: ChartType.column,
                                    axisLabelFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 12,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    statsHeadingFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 13,
                                      "fontColor": 4294642700,
                                      "fontBold": true
                                    },
                                    statsValueFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 11,
                                      "fontColor": 4278190080,
                                      "fontBold": false
                                    },
                                    width: 700,
                                    height: 260,
                                    chartSeriesColors: [4285872317],
                                    minLabelText: "Min",
                                    maxLabelText: "Max",
                                    avgLabelText: "Avg",
                                    totalLabelText: "Total",
                                    showLabel: false,
                                    showStats: true,
                                    showMinValue: true,
                                    showMaxValue: true,
                                    showTotalValue: true,
                                    showAvgValue: true,
                                    showTooltip: true,
                                    showLegend: true)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex:16,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CardLayoutSection(
                                minHeight: 100,
                                maxHeight: 180,
                                child: CircularProgressBarWidget(
                                    config: CircularProgressBarWidgetConfig(
                                        title: "Power",
                                        titleFont: {
                                          "fontFamily": "Open Sans",
                                          "fontSize": 22,
                                          "fontColor": 4286653679,
                                          "fontBold": true
                                        },
                                        deviceId: deviceId!,
                                        field: "power",
                                        unit: "W",
                                        chartColor: 4285872317,
                                        valueFont: {
                                          "fontFamily": "Open Sans",
                                          "fontSize": 14,
                                          "fontColor": 4285872317,
                                          "fontBold": true
                                        },
                                        width: 250,
                                        height: 200,
                                        opacity: 0.3)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CardLayoutSection(
                                minHeight: 100,
                                maxHeight: 180,
                                child: CircularProgressBarWidget(
                                    config: CircularProgressBarWidgetConfig(
                                        title: "Current",
                                        titleFont: {
                                          "fontFamily": "Open Sans",
                                          "fontSize": 22,
                                          "fontColor": 4294920249,
                                          "fontBold": true
                                        },
                                        deviceId: deviceId!,
                                        field: "current",
                                        unit: "A",
                                        chartColor: 4294920249,
                                        valueFont: {
                                          "fontFamily": "Open Sans",
                                          "fontSize": 14,
                                          "fontColor": 4294920249,
                                          "fontBold": true
                                        },
                                        width: 250,
                                        height: 200,
                                        opacity: 0.3)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex:8,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CardLayoutSection(
                            minHeight: 200,
                            maxHeight: 380,
                            maxWidth: 128,
                            child: VerticalProgressBarWidget(
                                config: VerticalProgressBarWidgetConfig(
                                    title: "Voltage",
                                    titleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 16,
                                      "fontColor": 4281120759,
                                      "fontBold": true
                                    },
                                    deviceId: deviceId!,
                                    field: "voltage",
                                    unit: "V",
                                    chartColor: 4288995580,
                                    valueFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 18,
                                      "fontColor": 4282368509,
                                      "fontBold": true
                                    },
                                    height: 300,
                                    dashCount: 50,
                                    dashHeight: 3,
                                    dashWidth: 50,
                                    dashSpace: 1.5,
                                    opacity: 0.3)),
                          ),
                        ),
                      ),
                      Expanded(
                        flex:8,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CardLayoutSection(
                            minHeight: 200,
                            maxHeight: 380,
                            maxWidth: 128,
                            child: VerticalProgressBarWidget(
                                config: VerticalProgressBarWidgetConfig(
                                    title: "Frequency",
                                    titleFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 16,
                                      "fontColor": 4282490921,
                                      "fontBold": true
                                    },
                                    deviceId: deviceId!,
                                    field: "frequency",
                                    unit: "Hz",
                                    chartColor: 4282490921,
                                    valueFont: {
                                      "fontFamily": "Open Sans",
                                      "fontSize": 18,
                                      "fontColor": 4282490921,
                                      "fontBold": true
                                    },
                                    height: 300,
                                    dashCount: 50,
                                    dashHeight: 3,
                                    dashWidth: 50,
                                    dashSpace: 1.5,
                                    opacity: 0.3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void setup() {}
}

class CardLayoutSection extends StatelessWidget {
  final double minHeight;
  final double maxHeight;
  final double maxWidth;
  final double minWidth;
  final Widget child;
  const CardLayoutSection(
      {super.key,
      required this.child,
      required this.minHeight,
      required this.maxHeight,
      this.maxWidth = double.infinity,
      this.minWidth = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(
          minHeight: minHeight,
          maxHeight: maxHeight,
          minWidth: minWidth,
          maxWidth: maxWidth,
        ),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: child);
  }
}
