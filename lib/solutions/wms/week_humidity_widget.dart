import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';

class HumidityWeekWidget extends StatefulWidget {
  final DeviceFieldRangeGaugeWidgetConfig config;
  const HumidityWeekWidget({super.key, required this.config});

  @override
  State<HumidityWeekWidget> createState() => _HumidityWeekWidgetState();
}

class _HumidityWeekWidgetState extends BaseState<HumidityWeekWidget> {
  bool loading = false;
  bool isValidConfig = true;
  late String deviceId;
  String field = "humidity";
  List<Map<String, dynamic>> humidityData = [];

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
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
        borderRadius: BorderRadius.circular(4), // Border radius
        border: Border.all(
          color: Colors.white, // Border color
          width: 1, // Border width
        ),
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  'Last 7 days Humidity Level',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: humidityData.map((data) {
                    bool isToday =
                        data['date'] == getFormattedDate(DateTime.now());

                    // Select the icon based on humidity level
                    IconData iconData;
                    if (data['humidity'] > 70) {
                      iconData = Icons.water_drop;
                    } else if (data['humidity'] > 60) {
                      iconData = Icons.cloud;
                    } else if (data['humidity'] > 50) {
                      iconData = Icons.air_outlined;
                    } else if (data['humidity'] > 40) {
                      iconData = Icons.grain;
                    } else if (data['humidity'] > 30) {
                      iconData = Icons.terrain;
                    } else {
                      iconData = Icons.wb_sunny;
                    }

                    return Container(
                      width: MediaQuery.of(context).size.width / 8,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 4),
                      child: Card(
                        color: isToday ? const Color(0XFF5596F6) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Humidity  ${data['humidity'].toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isToday
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
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
