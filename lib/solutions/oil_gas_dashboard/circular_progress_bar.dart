import 'package:flutter/material.dart';
import 'package:twinned_models/circle_progress_bar_widget/circle_progress_bar_widget.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularProgressWidget extends StatefulWidget {
  final CircularProgressBarWidgetConfig config;
  const CircularProgressWidget({super.key, required this.config});

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends BaseState<CircularProgressWidget> {
  late String title;
  late String field;
  late String deviceId;
  late Color bgColor;
  late Color fillColor;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late double maximum;
  String fieldName = '--';
  dynamic value;
  double? rawValue;
  bool isValidConfig = false;
  double? exactValue;

  @override
  void initState() {
    var config = widget.config;
    title = config.title;
    field = config.field;
    deviceId = config.deviceId;
    bgColor = Color(config.bgColor);
    fillColor = Color(config.fillColor);
    maximum = config.maximum;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);

    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: TwinUtils.getTextStyle(titleFont),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CircularPercentIndicator(
                radius: 130,
                lineWidth: 25,
                animation: true,
                percent: value ?? 0.0,
                circularStrokeCap: CircularStrokeCap.square,
                progressColor: fillColor,
                backgroundColor: bgColor,
                center: Text(
                  formatValue(exactValue),
                  style:
                      TwinUtils.getTextStyle(valueFont).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 100,
          source: ["data.$field"],
          mustConditions: [
            {
              "exists": {"field": "data.$field"}
            },
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            rawValue = double.tryParse(
                    obj['p_source']['data'][widget.config.field].toString()) ??
                0.0;
            exactValue = rawValue;

            // Convert rawValue to a percentage based on the maximum value
            if (rawValue != null && maximum > 0) {
              rawValue = (rawValue! / maximum).clamp(0.0, 1.0);
            }

            value = rawValue; // Update value with normalized percentage
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  String formatValue(double? value) {
    if (value == null) return '--';
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k'; // Converts 1500 to "1.5k"
    }
    return value.toStringAsFixed(1); // Converts 500 to "500.0"
  }

  @override
  void setup() {
    load();
  }
}
