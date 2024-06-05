import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/generic_day_weather/generic_day_weather.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
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

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM-dd-yyyy – hh:mm a').format(now);

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
                              Expanded(
                                child: Image.asset(
                                  'assets/images/sunrise.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text("SUNRISE"),
                                    Text("5.55 am"),
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
                              Expanded(
                                child: Image.asset(
                                  'assets/images/night.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text("SUNSET"),
                                    Text("6.55 pm"),
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
                        const Text("Temperature"),
                        Expanded(
                            child: Row(
                          children: [
                            Image.asset(
                              'assets/images/temperature.png',
                              height: 30,
                              width: 30,
                            ),
                            const Expanded(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("32.4.c"),
                                    Text("Current"),
                                  ],
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("42.4.c"),
                                    Text("Feels Like"),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                        Expanded(
                            child: Row(
                          children: [
                            Image.asset(
                              'assets/images/minmax.png',
                              height: 30,
                              width: 30,
                            ),
                            const Expanded(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("29.4.c"),
                                    Text("Min"),
                                  ],
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Card(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("42.4.c"),
                                    Text("Max"),
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
                                Expanded(
                                  child: Image.asset(
                                    'assets/images/pressure.png',
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("Pressure"),
                                      Text("410 hPa"),
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
                                Expanded(
                                  child: Image.asset(
                                    'assets/images/humidity.png',
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("Humidity"),
                                      Text("64 %"),
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
            Text('$formattedDate'),
          ],
        )
      ],
    );
  }

  @override
  void setup() {}
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
