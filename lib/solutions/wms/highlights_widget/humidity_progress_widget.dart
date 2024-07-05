import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/humidity_progress_bar/humidity_progress_bar.dart';

class ProgressBarWidget extends StatefulWidget {
  final HumidityProgressBarWidgetConfig config;
  const ProgressBarWidget({super.key, required this.config});

  @override
  State<ProgressBarWidget> createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends BaseState<ProgressBarWidget> {
  bool loading = false;
  bool isValidConfig = false;
  late String deviceId;
  late String title;
  late String field;
  late Color backgroundColor;
  late Color valueColor;
  late FontConfig valueFont;
  late FontConfig titleFont;
  double percentValue = 0;
  double percentValueText = 0;

  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    valueColor = Color(config.valueColor);
    backgroundColor = Color(config.backgroundColor);
    valueFont = FontConfig.fromJson(config.valueFont);
    titleFont = FontConfig.fromJson(config.titleFont);
    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: TwinUtils.getTextStyle(titleFont),
            ),
            LinearPercentIndicator(
              animation: true,
              lineHeight: 20,
              animationDuration: 1000,
              percent: percentValue,
              progressColor: valueColor,
              backgroundColor: backgroundColor,
            ),
            Text(
              '${percentValueText}%',
              style: TwinUtils.getTextStyle(valueFont),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> load() async {
    if (!isValidConfig || loading) return;
    loading = true;

    await execute(() async {
      // Define the start and end of yesterday
      DateTime now = DateTime.now();
      DateTime startOfToday = DateTime(now.year, now.month, now.day);
      DateTime startOfYesterday =
          startOfToday.subtract(const Duration(days: 1));
      DateTime endOfYesterday =
          startOfToday.subtract(const Duration(seconds: 1));
      // debugPrint(now.toString());
      // debugPrint(startOfToday.toString());
      // debugPrint(startOfYesterday.toString());
      // debugPrint(endOfYesterday.toString());

      // Format the dates to match your query requirements
      String startOfYesterdayStr = startOfYesterday.toUtc().toIso8601String();
      String endOfYesterdayStr = endOfYesterday.toUtc().toIso8601String();
      // debugPrint(startOfYesterdayStr);
      // debugPrint(endOfYesterdayStr);

      EqlCondition filterRange = EqlCondition(name: 'filter', condition: {
        "range": {
          "updatedStamp": {
            "gte": startOfYesterdayStr,
            "lte": endOfYesterdayStr,
          }
        }
      });

      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 2000,
          source: [],
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
          ],
          sort: {'updatedStamp': 'desc'},
          conditions: [],
          queryConditions: [],
          boolConditions: [],
        ),
      );
      if (qRes.body != null &&
          qRes.body!.result != null &&
          validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (device == null) return;

        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;
        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            double value = obj['p_source']['data'][field];

            setState(() {
              // Set the raw value to be displayed
              percentValueText = value;
              // Normalize the value to be within the range of 0.0 to 1.0
              percentValue = (value / 100).clamp(0.0, 1.0);
              // Ensure the percentValue is in two decimal precision
              percentValue = double.parse(percentValue.toStringAsFixed(2));
            });
          }
        }
      }
    });
    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}
