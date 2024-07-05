import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';

class ForecastWidget extends StatefulWidget {
  final DeviceFieldRangeGaugeWidgetConfig config;
  const ForecastWidget({super.key, required this.config});

  @override
  State<ForecastWidget> createState() => _ForecastWidgetState();
}

class _ForecastWidgetState extends BaseState<ForecastWidget> {
  bool isValidConfig = true;
  bool loading = false;
  late String deviceId;
  String field = "temperature";

  List<Map<String, dynamic>> forecastData = [];
  Map<String, dynamic> todayData = {};

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  Icon getTemperatureIcon(double temperature) {
    if (temperature < 30) {
      return Icon(Icons.ac_unit, size: 40, color: Colors.blue.shade400);
    } else if (temperature < 40) {
      return Icon(Icons.wb_cloudy_outlined,
          size: 40, color: Colors.lightBlue.shade400);
    } else if (temperature < 50) {
      return Icon(Icons.wb_sunny_outlined,
          size: 40, color: Colors.amber.shade400);
    } else if (temperature < 60) {
      return Icon(Icons.sunny_snowing, size: 40, color: Colors.orange.shade400);
    } else {
      return Icon(Icons.whatshot, size: 40, color: Colors.red.shade400);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4), // Border radius
              border: Border.all(
                color: Colors.white, // Border color
                width: 1, // Border width
              ),
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Text(
                      'Last 7 days Forecast',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          margin: const EdgeInsets.all(6.0),
                          child: Card(
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: getTemperatureIcon(
                                      double.tryParse(
                                              todayData['max'] ?? '0') ??
                                          0,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${double.tryParse(todayData['max'] ?? '0')! >= 0 ? '+' : ''}${todayData['max'] ?? '0'}° / ',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '${double.tryParse(todayData['min'] ?? '0')! >= 0 ? '+' : ''}${todayData['min'] ?? '0'}°',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      DateFormat('dd MMM, EEEE')
                                          .format(DateTime.now()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ...forecastData.map((data) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            margin: const EdgeInsets.all(6.0),
                            child: Card(
                              elevation: 8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: getTemperatureIcon(
                                        double.tryParse(data['max'] ?? '0') ??
                                            0,
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${double.tryParse(data['max'] ?? '0')! >= 0 ? '+' : ''}${data['max'] ?? '0'}° / ',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '${double.tryParse(data['min'] ?? '0')! >= 0 ? '+' : ''}${data['min'] ?? '0'}°',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        DateFormat('dd MMM, EEEE').format(
                                            DateTime.parse(data['date'])),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Future<void> load() async {
    if (!isValidConfig || loading) return;
    loading = true;

    try {
      DateTime now = DateTime.now();
      DateTime startOfToday = DateTime(now.year, now.month, now.day);

      List<Map<String, dynamic>> dateRanges = List.generate(7, (i) {
        DateTime startOfDay = startOfToday.subtract(Duration(days: i + 1));
        DateTime endOfDay = startOfDay
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));

        return {
          'start': startOfDay,
          'end': endOfDay,
          'date':
              '${startOfDay.year}-${startOfDay.month.toString().padLeft(2, '0')}-${startOfDay.day.toString().padLeft(2, '0')}',
        };
      });

      List<Map<String, dynamic>> fetchedData =
          await Future.wait(dateRanges.map((dateRange) async {
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
            size: 0,
            source: [],
            mustConditions: [
              {
                "match_phrase": {"deviceId": deviceId}
              },
              {
                "exists": {"field": "data.$field"}
              },
            ],
            conditions: [
              EqlCondition(name: 'aggs', condition: {
                "min": {
                  "min": {"field": "data.$field"}
                },
                "max": {
                  "max": {"field": "data.$field"}
                },
                "avg": {
                  "avg": {"field": "data.$field"}
                }
              })
            ],
            boolConditions: [filterRange],
          ),
        );

        if (validateResponse(qRes)) {
          Map<String, dynamic> json =
              qRes.body!.result! as Map<String, dynamic>;

          num min = json['aggregations']['min']['value'] ?? 0;
          num max = json['aggregations']['max']['value'] ?? 0;

          return {
            'date': dateRange['date'],
            'min': min.toStringAsFixed(2),
            'max': max.toStringAsFixed(2),
          };
        } else {
          return {
            'date': dateRange['date'],
            'min': '0',
            'max': '0',
          };
        }
      }));

      // Get today's data
      String startStrToday = startOfToday.toUtc().toIso8601String();
      String endStrToday = startOfToday
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1))
          .toUtc()
          .toIso8601String();

      EqlCondition filterRangeToday = EqlCondition(name: 'filter', condition: {
        "range": {
          "updatedStamp": {
            "gte": startStrToday,
            "lte": endStrToday,
          }
        }
      });

      var qResToday = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 0,
          source: [],
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
            {
              "exists": {"field": "data.$field"}
            },
          ],
          conditions: [
            EqlCondition(name: 'aggs', condition: {
              "min": {
                "min": {"field": "data.$field"}
              },
              "max": {
                "max": {"field": "data.$field"}
              }
            })
          ],
          boolConditions: [filterRangeToday],
        ),
      );

      if (validateResponse(qResToday)) {
        Map<String, dynamic> jsonToday =
            qResToday.body!.result! as Map<String, dynamic>;

        num minToday = jsonToday['aggregations']['min']['value'] ?? 0;
        num maxToday = jsonToday['aggregations']['max']['value'] ?? 0;

        todayData = {
          'min': minToday.toStringAsFixed(2),
          'max': maxToday.toStringAsFixed(2),
        };
      } else {
        todayData = {
          'min': '0',
          'max': '0',
        };
      }

      setState(() {
        forecastData = fetchedData;
      });
    } catch (e) {
      debugPrint('Error during API call: $e');
      setState(() {
        forecastData = [];
        todayData = {};
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
