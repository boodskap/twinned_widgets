import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/visibility_air_quality/visibility_air_quality.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class AirQualityWidget extends StatefulWidget {
  final VisibilityAirQualityWidgetConfig config;
  const AirQualityWidget({
    super.key,
    required this.config,
  });
  @override
  State<AirQualityWidget> createState() => _AirQualityWidgetState();
}

class _AirQualityWidgetState extends BaseState<AirQualityWidget> {
  bool isValidConfig = false;
  late String title;
  late String deviceId;
  late String field;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig subLabelFont;
  double airQualityValue = 0;
  bool loading = false;

  @override
  void initState() {
    var config = widget.config;
    title = config.title;
    field = config.field;
    deviceId = config.deviceId;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    subLabelFont = FontConfig.fromJson(config.subLabelFont);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.air,
                  color: Color(0xFFA4C2E8),
                ),
                divider(horizontal: true, width: 5),
                Text(
                  airQualityValue.toString() ?? "0.0",
                  style: TwinUtils.getTextStyle(valueFont),
                ),
              ],
            ),
            Text(
              'Unhealthy for Sensitive Groups',
              style: TwinUtils.getTextStyle(subLabelFont),
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
      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: ["data"],
          page: 0,
          size: 1,
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
            {
              "exists": {"field": "data.$field"}
            },
          ],
        ),
      );
      if (qRes.body != null &&
          qRes.body!.result != null &&
          validateResponse(qRes)) {
        // Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        // if (device == null) return;

        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;
        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            var value = obj['p_source']['data'][field];
            // debugPrint(value.toString());

            setState(() {
              airQualityValue = value;
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

class AirQualityWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return AirQualityWidget(
      config: VisibilityAirQualityWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.air);
  }

  @override
  String getPaletteName() {
    return "Air Quality widget ";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return VisibilityAirQualityWidgetConfig.fromJson(config);
    }
    return VisibilityAirQualityWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Air Quality widget';
  }
}
