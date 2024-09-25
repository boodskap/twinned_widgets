import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_models/humidity_week_widget/humidity_week_widget.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class HumidityWeekWidget extends StatefulWidget {
  final HumidityWeekWidgetConfig config;
  const HumidityWeekWidget({super.key, required this.config});

  @override
  State<HumidityWeekWidget> createState() => _HumidityWeekWidgetState();
}

class _HumidityWeekWidgetState extends BaseState<HumidityWeekWidget> {
  bool isValidConfig = true;
  late String deviceId;
  late String title;
  late String field;
  late Color cardColor;
  late FontConfig titleFont;
  late FontConfig valueFont;
  List<Map<String, dynamic>> humidityData = [];

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    title = config.title;
    field = config.field;
    cardColor = Color(config.cardColor);
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  IconData getHumidityIcon(double temperature) {
    if (temperature > 70) {
      return Icons.water_drop;
    } else if (temperature > 60) {
      return Icons.cloud;
    } else if (temperature > 50) {
      return Icons.air_outlined;
    } else if (temperature > 40) {
      return Icons.grain;
    } else if (temperature > 30) {
      return Icons.terrain;
    } else {
      return Icons.wb_sunny;
    }
  }

  String getClimateDescription(double humidity) {
    if (humidity > 80) {
      return 'Stormy: High levels of moisture in the air, often leading to storms and heavy rainfall.';
    } else if (humidity > 60) {
      return 'Rainy: The air is quite humid, with frequent rain showers and overcast skies.';
    } else if (humidity > 40) {
      return 'Windy: Moderate humidity with a likelihood of windy conditions, making it feel cooler.';
    } else if (humidity > 20) {
      return 'Weather: Mild and comfortable with balanced humidity, suitable for most activities.';
    } else {
      return 'Sunny: Low humidity with clear skies, ideal for outdoor activities and sunny weather.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          "Not Configured Properly",
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                    title.isEmpty ? 'Last 7 days Humidity Level' : title,
                    style: TwinUtils.getTextStyle(titleFont)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: humidityData.map((data) {
                    bool isToday =
                        data['date'] == getFormattedDate(DateTime.now());

                    // Get the appropriate image for the humidity level
                    String imageAsset;
                    if (data['humidity'] > 80) {
                      imageAsset = 'assets/images/stormy.png';
                    } else if (data['humidity'] > 60 &&
                        data['humidity'] <= 80) {
                      imageAsset = 'assets/images/rainy.png';
                    } else if (data['humidity'] > 40 &&
                        data['humidity'] <= 60) {
                      imageAsset = 'assets/images/windy.png';
                    } else if (data['humidity'] > 20 &&
                        data['humidity'] <= 40) {
                      imageAsset = 'assets/images/weather.png';
                    } else {
                      imageAsset = 'assets/images/sunny.png';
                    }

                    String climateDescription =
                        getClimateDescription(data['humidity']);

                    return Container(
                      width: MediaQuery.of(context).size.width / 8,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 4),
                      child: Card(
                        color: isToday ? const Color(0XFF5596F6) : cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${data['date']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isToday ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    imageAsset,
                                    height: 60,
                                    width: 60,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    climateDescription,
                                    style: isToday
                                        ? TextStyle(
                                            fontWeight: valueFont.fontBold
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: valueFont.fontSize,
                                            color: Colors.white,
                                          )
                                        : TwinUtils.getTextStyle(valueFont),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Humidity ${data['humidity'].toStringAsFixed(2)}%',
                                        style: isToday
                                            ? TextStyle(
                                                fontWeight: valueFont.fontBold
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: valueFont.fontSize,
                                                color: Colors.white,
                                              )
                                            : TwinUtils.getTextStyle(valueFont),
                                      ),
                                    ),
                                    Icon(
                                      getHumidityIcon(data['humidity']),
                                      size: 24,
                                      color: isToday
                                          ? Colors.white
                                          : Colors.lightBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('EEE, MMM dd').format(date);
  }

  Future<void> load() async {
    if (!isValidConfig || loading) return;
    loading = true;

    try {
      DateTime now = DateTime.now();
      DateTime startOfToday = DateTime(now.year, now.month, now.day);

      List<Map<String, dynamic>> dateRanges = [];
      for (int i = 0; i < 7; i++) {
        DateTime startOfDay = startOfToday.subtract(Duration(days: i));
        DateTime endOfDay = startOfDay
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));

        dateRanges.add({
          'start': startOfDay,
          'end': endOfDay,
          'date': getFormattedDate(startOfDay),
        });
      }

      List<Map<String, dynamic>> fetchedData = [];

      for (var dateRange in dateRanges) {
        String startStr =
            (dateRange['start'] as DateTime).toUtc().toIso8601String();
        String endStr =
            (dateRange['end'] as DateTime).toUtc().toIso8601String();

        EqlCondition filterRange = EqlCondition(name: 'filter', condition: {
          "range": {
            "updatedStamp": {
              "gte": startStr,
              "lte": endStr,
            }
          }
        });

        var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            page: 0,
            size: 1,
            source: [],
            mustConditions: [
              {
                "match_phrase": {"deviceId": deviceId}
              },
            ],
            sort: {'updatedStamp': 'desc'},
            conditions: [],
            queryConditions: [],
            boolConditions: [filterRange],
          ),
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
              double value = obj['p_source']['data'][field]?.toDouble() ?? 0;

              fetchedData.add({
                'date': dateRange['date'],
                'humidity': value,
              });
            } else {
              fetchedData.add({
                'date': dateRange['date'],
                'humidity': 0,
              });
            }
          } else {
            fetchedData.add({
              'date': dateRange['date'],
              'humidity': 0,
            });
          }
        } else {
          fetchedData.add({
            'date': dateRange['date'],
            'humidity': 0,
          });
        }
      }

      setState(() {
        humidityData = fetchedData;
      });
    } catch (e) {
      debugPrint('Error during API call: $e');
      setState(() {
        humidityData = [];
      });
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

class HumidityWeekWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return HumidityWeekWidget(
      config: HumidityWeekWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.water_drop_outlined);
  }

  @override
  String getPaletteName() {
    return "Humidity Week widget ";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return HumidityWeekWidgetConfig.fromJson(config);
    }
    return HumidityWeekWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Humidity week device field widget';
  }
}
