import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/parameter_info_widget/parameter_info_widget.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class ParameterInfoWidget extends StatefulWidget {
  final ParameterInfoWidgetConfig config;
  const ParameterInfoWidget({
    super.key,
    required this.config,
  });
  @override
  State<ParameterInfoWidget> createState() => _ParameterInfoWidgetState();
}

class _ParameterInfoWidgetState extends BaseState<ParameterInfoWidget> {
  bool isValidConfig = false;
  late String title;
  late String deviceId;
  late String field;
  late String hintText;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig hintTextFont;
  double fieldValue = 0;

  @override
  void initState() {
    var config = widget.config;
    title = config.title;
    field = config.field;
    deviceId = config.deviceId;
    hintText = config.hintText;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    hintTextFont = FontConfig.fromJson(config.hintTextFont);

    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
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
                  Icons.info,
                  color: Color(0xFFA4C2E8),
                ),
                divider(horizontal: true, width: 5),
                Text(
                  fieldValue.toString() ?? "0.0",
                  style: TwinUtils.getTextStyle(valueFont),
                ),
              ],
            ),
            Text(
              hintText.isNotEmpty ? hintText : '--',
              style: TwinUtils.getTextStyle(hintTextFont),
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

        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;
        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            var value = obj['p_source']['data'][field];
            // debugPrint(value.toString());
            refresh(
              sync: () {
                fieldValue = value;
              },
            );
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

class ParameterInfoWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return ParameterInfoWidget(
      config: ParameterInfoWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.info);
  }

  @override
  String getPaletteName() {
    return "Parameter info widget ";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return ParameterInfoWidgetConfig.fromJson(config);
    }
    return ParameterInfoWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Paramter info widget';
  }
}
