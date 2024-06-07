import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/generic_day_weather/generic_day_weather.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class GenericDayWeatherWidget extends StatefulWidget {
  final GenericDayWeatherWidgetConfig config;
  const GenericDayWeatherWidget({super.key, required this.config});

  @override
  State<GenericDayWeatherWidget> createState() =>
      _GenericDayWeatherWidgetState();
}

class _GenericDayWeatherWidgetState extends BaseState<GenericDayWeatherWidget> {
  DateTime now = DateTime.now();

  late String deviceId;
  late String minTitle;
  late String maxTitle;
  late String sunriseTitle;
  late String sunsetTitle;
  late String temperatureTitle;
  late String currentTitle;
  late String feelsLikeTitle;
  late String pressureTitle;
  late String humidityTitle;
  late String temperaturSuffix;
  late String pressureSuffix;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late String sunriseField;
  late String sunsetField;
  late String temperatureField;
  late String feelsLikeField;
  late String minField;
  late String maxField;
  late String pressureField;
  late String humidityField;
  bool isConfigValid = false;

  dynamic sunsetValue;
  dynamic sunriseValue;

  dynamic currentValue;
  dynamic feelsLikeValue;
  dynamic minValue;
  dynamic maxValue;
  dynamic humidityValue;
  dynamic pressureValue;

  String formattedSunrise = "--";
  String formattedSunset = "--";

  @override
  void initState() {
    deviceId = widget.config.deviceId;
    minTitle = widget.config.minTitle;
    maxTitle = widget.config.maxTitle;
    sunriseTitle = widget.config.sunriseTitle;
    sunsetTitle = widget.config.sunsetTitle;
    temperatureTitle = widget.config.temperatureTitle;
    currentTitle = widget.config.currentTitle;
    feelsLikeTitle = widget.config.feelsLikeTitle;
    pressureTitle = widget.config.pressureTitle;
    humidityTitle = widget.config.humidityTitle;
    temperaturSuffix = widget.config.temperaturSuffix;
    pressureSuffix = widget.config.pressureSuffix;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);
    sunriseField = widget.config.sunriseField;
    sunsetField = widget.config.sunsetField;
    temperatureField = widget.config.temperatureField;
    feelsLikeField = widget.config.feelsLikeField;
    maxField = widget.config.maxField;
    minField = widget.config.minField;
    pressureField = widget.config.pressureField;
    humidityField = widget.config.humidityField;
    isConfigValid = deviceId.isNotEmpty;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // String formattedDate = DateFormat('MMMM-dd-yyyy – hh:mm a').format(now);
    String formattedDate = DateFormat('hh:mm a').format(now);

    if (!isConfigValid) {
      return const Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly',
            style:
                TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 25,
                child: Card(
                  color: Colors.grey,
                  elevation: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                  child: Icon(Icons.wb_sunny_rounded)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(sunriseTitle),
                                    Text(formattedSunrise),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                  child: Icon(Icons.nights_stay_rounded)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(sunsetTitle),
                                    Text(formattedSunset),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 50,
                  child: Card(
                    color: Colors.grey,
                    elevation: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(temperatureTitle),
                        Expanded(
                            child: Row(
                          children: [
                            const Icon(Icons.thermostat_outlined),
                            Expanded(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("$currentValue $temperaturSuffix"),
                                    Text(currentTitle),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("$feelsLikeValue $temperaturSuffix"),
                                    Text(feelsLikeTitle),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            const Icon(Icons.thermostat_outlined),
                            Expanded(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("$minValue $temperaturSuffix"),
                                    Text(minTitle),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("$maxValue $temperaturSuffix"),
                                    Text(maxTitle),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ))
                      ],
                    ),
                  )),
              Expanded(
                  flex: 25,
                  child: Card(
                    color: Colors.grey,
                    elevation: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Icon(Icons.air),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(pressureTitle),
                                      Text("$pressureValue $pressureSuffix"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Expanded(
                                    child: Icon(Icons.water_drop_rounded)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(humidityTitle),
                                      Text("$humidityValue %"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(formattedDate),
          ],
        )
      ],
    );
  }

  Future<void> load() async {
    if (!isConfigValid) return;

    if (loading) return;
    loading = true;

    try {
      await execute(() async {
        var query = EqlSearch(
          source: ["data"],
          page: 0,
          size: 1,
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            }
          ],
        );
        // debugPrint('Query: ${query.toJson()}');

        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: query,
        );

        // debugPrint('Response: ${qRes.body?.toJson()}');

        if (qRes.body != null &&
            qRes.body!.result != null &&
            validateResponse(qRes)) {
          Map<String, dynamic>? json =
              qRes.body!.result! as Map<String, dynamic>?;

          if (json != null) {
            List<dynamic> hits = json['hits']['hits'];

            if (hits.isNotEmpty) {
              Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
              Map<String, dynamic> source =
                  obj['p_source'] as Map<String, dynamic>;
              Map<String, dynamic> data =
                  source['data'] as Map<String, dynamic>;
              currentValue = obj['p_source']['data']['current'];
              pressureValue = obj['p_source']['data']['pressure'];
              sunsetValue = obj['p_source']['data']['sunset'];
              sunriseValue = obj['p_source']['data']['sunrise'];
              feelsLikeValue = obj['p_source']['data']['feelsLike'];
              minValue = obj['p_source']['data']['max'];
              maxValue = obj['p_source']['data']['min'];

              humidityValue = obj['p_source']['data']['humidity'];

              DateTime sunsetDateTime =
                  DateTime.fromMillisecondsSinceEpoch(sunsetValue);
              DateTime sunriseDateTime =
                  DateTime.fromMillisecondsSinceEpoch(sunriseValue);

              // Define the desired time format
              DateFormat timeFormat = DateFormat('hh:mm a');

              // Format the DateTime objects into the desired string format
              formattedSunset = timeFormat.format(sunsetDateTime);
              formattedSunrise = timeFormat.format(sunriseDateTime);
            }
          }
        }
      });
    } catch (e) {
      // debugPrint('Error loading data: $e');
      // debugPrint('Stack trace: $stackTrace');
    } finally {
      loading = false;
      refresh();
    }
  }

  @override
  void setup() {
    load();
  }
}

class GenericDayWeatherWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericDayWeatherWidget(
      config: GenericDayWeatherWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.cloudy_snowing);
  }

  @override
  String getPaletteName() {
    return "Generic Day Weather Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return GenericDayWeatherWidgetConfig.fromJson(config);
    }
    return GenericDayWeatherWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Day Weather Widget values';
  }
}
