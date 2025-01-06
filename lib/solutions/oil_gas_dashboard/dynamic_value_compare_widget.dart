import 'package:flutter/material.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_models/dynamic_value_compare_widget/dynamic_value_compare_widget.dart';

class DynamicValueCompareWidget extends StatefulWidget {
  final DynamicValueCompareWidgetConfig config;
  const DynamicValueCompareWidget({super.key, required this.config});

  @override
  State<DynamicValueCompareWidget> createState() =>
      _DynamicValueCompareWidgetState();
}

class _DynamicValueCompareWidgetState
    extends BaseState<DynamicValueCompareWidget> {
  late String field;
  late String deviceId;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig textFont;

  String fieldName = '--';
  bool isValidConfig = false;
  double? currentDayValue;
  double? previousDayValue;

  Widget verticalLine = Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0),
    child: Container(
      height: 35.0,
      width: 2.0,
      color: Colors.grey,
    ),
  );

  @override
  void initState() {
    super.initState();
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    textFont = FontConfig.fromJson(config.textFont);
    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    setup();
  }

  @override
@override
Widget build(BuildContext context) {
  double? percentageValue = calculatePercentageIncrease();
  
  return SizedBox(
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (percentageValue != null)
                Icon(
                  percentageValue >= 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: percentageValue >= 0 ? Colors.green : Colors.red,
                ),
              divider(horizontal: true, width: 4), 
              Text(
                percentageValue != null
                    ? '${percentageValue.toStringAsFixed(2)}%'
                    : '--',
                style: TwinUtils.getTextStyle(textFont).copyWith(
                  color: percentageValue != null && percentageValue >= 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            fieldName,
            style: TwinUtils.getTextStyle(titleFont),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentDayValue != null ? '$currentDayValue' : '--',
                    style: TwinUtils.getTextStyle(textFont),
                  ),
                  Text(
                    'Today',
                    style: TwinUtils.getTextStyle(textFont)
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              verticalLine,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previousDayValue != null ? '$previousDayValue' : '--',
                    style: TwinUtils.getTextStyle(textFont),
                  ),
                  Text(
                    'Yesterday',
                    style: TwinUtils.getTextStyle(textFont)
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  double? calculatePercentageIncrease() {
    if (currentDayValue != null &&
        previousDayValue != null &&
        previousDayValue != 0) {
      return ((currentDayValue! - previousDayValue!) / previousDayValue!) * 100;
    }
    return null;
  }

  Future<void> _load() async {
    if (!isValidConfig) return;
    if (loading) return;
    loading = true;

    // Get today's date
    DateTime today = DateTime.now();
    // Get yesterday's date
    DateTime yesterday = today.subtract(const Duration(days: 1));

    // Helper variables to store results
    String startOfDayStr, endOfDayStr;
    EqlCondition filterRange;

    try {
      // Fetch today's data
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      startOfDayStr = startOfDay.toUtc().toIso8601String();
      endOfDayStr = endOfDay.toUtc().toIso8601String();

      filterRange = EqlCondition(name: 'filter', condition: {
        "range": {
          "updatedStamp": {
            "gte": startOfDayStr,
            "lte": endOfDayStr,
          }
        }
      });

      var todayRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 1,
          source: [], // You can modify this if you need specific fields
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
          ],
          sort: {'updatedStamp': 'desc'},
          boolConditions: [filterRange],
        ),
      );

      if (validateResponse(todayRes)) {
        Map<String, dynamic> json =
            todayRes.body!.result as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          var data = values[0]['p_source']['data'];
          var modelId = values[0]['p_source']['modelId'];
          DeviceModel? deviceModel =
              await TwinUtils.getDeviceModel(modelId: modelId);

          fieldName = TwinUtils.getParameterLabel(field, deviceModel!);

          // Update the relevant details for the device
          currentDayValue = data[field]?.toDouble();
        }
      }

      // Fetch yesterday's data
      DateTime startOfDayYesterday =
          DateTime(yesterday.year, yesterday.month, yesterday.day);
      DateTime endOfDayYesterday =
          DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

      startOfDayStr = startOfDayYesterday.toUtc().toIso8601String();
      endOfDayStr = endOfDayYesterday.toUtc().toIso8601String();

      filterRange = EqlCondition(name: 'filter', condition: {
        "range": {
          "updatedStamp": {
            "gte": startOfDayStr,
            "lte": endOfDayStr,
          }
        }
      });

      var yesterdayRes =
          await TwinnedSession.instance.twin.queryDeviceHistoryData(
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
          boolConditions: [filterRange],
        ),
      );

      if (validateResponse(yesterdayRes)) {
        Map<String, dynamic> json =
            yesterdayRes.body!.result as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          var data = values[0]['p_source']['data'];
          previousDayValue = data[field]?.toDouble();
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}
