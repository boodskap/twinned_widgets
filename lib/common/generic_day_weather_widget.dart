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
import 'package:intl/date_symbol_data_local.dart';

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
  dynamic updatedStampValue;

  String formattedSunrise = "--";
  String formattedSunset = "--";

  @override
  void initState() {
    initializeDateFormatting();
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
    // String formattedDate = DateFormat('MMM-dd-yyyy – hh:mm a').format(now);

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
                  color: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          color: Color(widget.config.sunriseColor),
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
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
                                    Text(
                                      sunriseTitle,
                                      style: TextStyle(
                                        fontFamily: labelFont.fontFamily,
                                        fontSize: labelFont.fontSize,
                                        fontWeight: labelFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          labelFont.fontColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formattedSunrise,
                                      style: TextStyle(
                                        fontFamily: titleFont.fontFamily,
                                        fontSize: titleFont.fontSize,
                                        fontWeight: titleFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          titleFont.fontColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          color: Color(widget.config.sunsetColor),
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
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
                                    Text(
                                      sunsetTitle,
                                      style: TextStyle(
                                        fontFamily: labelFont.fontFamily,
                                        fontSize: labelFont.fontSize,
                                        fontWeight: labelFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          labelFont.fontColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formattedSunset,
                                      style: TextStyle(
                                        fontFamily: titleFont.fontFamily,
                                        fontSize: titleFont.fontSize,
                                        fontWeight: titleFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          titleFont.fontColor,
                                        ),
                                      ),
                                    ),
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
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          temperatureTitle,
                          style: TextStyle(
                            fontFamily: labelFont.fontFamily,
                            fontSize: labelFont.fontSize,
                            fontWeight: labelFont.fontBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Color(
                              labelFont.fontColor,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Row(
                          children: [
                            const Icon(Icons.thermostat_outlined),
                            Expanded(
                              child: Card(
                                color: Color(widget.config.currentColor),
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${currentValue ?? '--'} $temperaturSuffix",
                                      style: TextStyle(
                                        fontFamily: titleFont.fontFamily,
                                        fontSize: titleFont.fontSize,
                                        fontWeight: titleFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          titleFont.fontColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      currentTitle,
                                      style: TextStyle(
                                        fontFamily: labelFont.fontFamily,
                                        fontSize: labelFont.fontSize,
                                        fontWeight: labelFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          labelFont.fontColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                color: Color(widget.config.feelsLikeColor),
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${feelsLikeValue ?? '--'} $temperaturSuffix",
                                      style: TextStyle(
                                        fontFamily: titleFont.fontFamily,
                                        fontSize: titleFont.fontSize,
                                        fontWeight: titleFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          titleFont.fontColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      feelsLikeTitle,
                                      style: TextStyle(
                                        fontFamily: labelFont.fontFamily,
                                        fontSize: labelFont.fontSize,
                                        fontWeight: labelFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          labelFont.fontColor,
                                        ),
                                      ),
                                    ),
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
                                color: Color(widget.config.minColor),
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${minValue ?? '--'} $temperaturSuffix",
                                      style: TextStyle(
                                        fontFamily: titleFont.fontFamily,
                                        fontSize: titleFont.fontSize,
                                        fontWeight: titleFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          titleFont.fontColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      minTitle,
                                      style: TextStyle(
                                        fontFamily: labelFont.fontFamily,
                                        fontSize: labelFont.fontSize,
                                        fontWeight: labelFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          labelFont.fontColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                color: Color(widget.config.maxColor),
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${maxValue ?? '--'} $temperaturSuffix",
                                      style: TextStyle(
                                        fontFamily: titleFont.fontFamily,
                                        fontSize: titleFont.fontSize,
                                        fontWeight: titleFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          titleFont.fontColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      maxTitle,
                                      style: TextStyle(
                                        fontFamily: labelFont.fontFamily,
                                        fontSize: labelFont.fontSize,
                                        fontWeight: labelFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(
                                          labelFont.fontColor,
                                        ),
                                      ),
                                    ),
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
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    child: Column(
                      children: [
                        Expanded(
                          child: Card(
                            color: Color(widget.config.pressureColor),
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
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
                                      Text(
                                        pressureTitle,
                                        style: TextStyle(
                                          fontFamily: labelFont.fontFamily,
                                          fontSize: labelFont.fontSize,
                                          fontWeight: labelFont.fontBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: Color(
                                            labelFont.fontColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${pressureValue ?? '--'} $pressureSuffix",
                                        style: TextStyle(
                                          fontFamily: titleFont.fontFamily,
                                          fontSize: titleFont.fontSize,
                                          fontWeight: titleFont.fontBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: Color(
                                            titleFont.fontColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: Color(widget.config.humidityColor),
                            shadowColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
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
                                      Text(
                                        humidityTitle,
                                        style: TextStyle(
                                          fontFamily: labelFont.fontFamily,
                                          fontSize: labelFont.fontSize,
                                          fontWeight: labelFont.fontBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: Color(
                                            labelFont.fontColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${humidityValue ?? '--'} %",
                                        style: TextStyle(
                                          fontFamily: titleFont.fontFamily,
                                          fontSize: titleFont.fontSize,
                                          fontWeight: titleFont.fontBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: Color(
                                            titleFont.fontColor,
                                          ),
                                        ),
                                      ),
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
            Text(
              updatedStampValue ?? '--',
              style: TextStyle(
                fontFamily: titleFont.fontFamily,
                fontSize: titleFont.fontSize,
                fontWeight:
                    titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(
                  titleFont.fontColor,
                ),
              ),
            ),
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

        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: query,
        );

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
              currentValue = data[widget.config.temperatureField] ?? '-';
              pressureValue = data[widget.config.pressureField] ?? '-';
              sunsetValue = data[widget.config.sunsetField] ?? '-';
              sunriseValue = data[widget.config.sunriseField] ?? '-';
              feelsLikeValue = data[widget.config.feelsLikeField] ?? '-';
              minValue = data[widget.config.minField] ?? '-';
              maxValue = data[widget.config.maxField];
              humidityValue = data[widget.config.humidityField];
              updatedStampValue = obj['p_source']['updatedStamp'];

              if (sunsetValue is int) {
                DateTime sunsetDateTime = DateTime.fromMillisecondsSinceEpoch(
                    sunsetValue,
                    isUtc: false);

                formattedSunset = DateFormat('hh:mm a').format(sunsetDateTime);
              } else {
                formattedSunset = "--";
              }

              if (sunriseValue is int) {
                DateTime sunriseDateTime = DateTime.fromMillisecondsSinceEpoch(
                    sunriseValue,
                    isUtc: false);
                formattedSunrise =
                    DateFormat('hh:mm a', 'in').format(sunriseDateTime);
              } else {
                formattedSunrise = "--";
              }

              if (updatedStampValue is int) {
                DateTime updatedStampTime =
                    DateTime.fromMillisecondsSinceEpoch(updatedStampValue);
                updatedStampValue = DateFormat('MMM-dd-yyyy – hh:mm a')
                    .format(updatedStampTime);
              } else {
                updatedStampValue = "--";
              }
            }
          }
        }
      });
    } catch (e) {
      // Handle error
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
